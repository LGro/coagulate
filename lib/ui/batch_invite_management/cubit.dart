// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../data/models/batch_invites.dart';

part 'cubit.g.dart';
part 'state.dart';

/// Create DHT record with first subkey for general info and then the
/// specified number of subkeys with an individual writer key pair each.
Future<Batch> createBatch(
    int numSubKeys, String label, DateTime expiration) async {
  final cryptoSystem = await Veilid.instance.bestCryptoSystem();
  final routingContext = await Veilid.instance.routingContext();

  // Generate writer key pairs for owner and subkeys
  final ownerWriter = await cryptoSystem.generateKeyPair();
  final subkeyWriters = await Future.wait(
      List.generate(numSubKeys, (_) async => cryptoSystem.generateKeyPair()));

  // Create record with individual subkey writers
  final record = await routingContext.createDHTRecord(
      DHTSchema.smpl(
          oCnt: 1,
          members: subkeyWriters
              .map((w) => DHTSchemaMember(mKey: w.key, mCnt: 1))
              .toList()),
      owner: ownerWriter);

  // DHT record content crypto
  final psk = await cryptoSystem.randomSharedSecret();
  final pskCrypto =
      await VeilidCryptoPrivate.fromSharedSecret(cryptoSystem.kind(), psk);

  // Write general info to first subkey with owner writer key pair
  final info = BatchInviteInfoSchema(label, expiration);
  await routingContext.openDHTRecord(record.key, writer: ownerWriter);
  await routingContext.setDHTValue(record.key, 0,
      await pskCrypto.encrypt(utf8.encode(jsonEncode(info.toJson()))),
      writer: ownerWriter);
  await routingContext.closeDHTRecord(record.key);

  return Batch(
      label: label,
      expiration: expiration,
      dhtRecordKey: record.key,
      writer: ownerWriter,
      subkeyWriters: subkeyWriters,
      psk: psk);
}

Future<Batch> updateBatchWithPopulatedSubkeyCount(Batch batch) async {
  var numPopulatedSubkeys = 0;

  final crypto = await VeilidCryptoPrivate.fromSharedSecret(
      batch.dhtRecordKey.kind, batch.psk);

  for (var subkey = 1; subkey <= batch.subkeyWriters.length; subkey++) {
    final record = await DHTRecordPool.instance.openRecordRead(
        batch.dhtRecordKey,
        debugName: 'coag::read',
        crypto: crypto);
    try {
      final content = await record.get(
          crypto: crypto,
          refreshMode: DHTRecordRefreshMode.network,
          subkey: subkey);
      if (content?.isNotEmpty ?? false) {
        numPopulatedSubkeys++;
      }
    } finally {
      await record.close();
    }
  }

  return batch.copyWith(numPopulatedSubkeys: numPopulatedSubkeys);
}

class BatchInvitesCubit extends Cubit<BatchInvitesState> {
  BatchInvitesCubit() : super(const BatchInvitesState()) {
    unawaited(initialize());
  }

  Future<void> initialize() async {
    //  TODO: Load from persistent storage
    final batches = <String, Batch>{};
    emit(BatchInvitesState(batches: batches));
    await updateBatchesWithPopulatedSubkeyCount();
  }

  // TODO: How long does this take? Do we need a loading spinner?
  Future<void> generateInvites(
      String label, int amount, DateTime expiration) async {
    final newBatch = await createBatch(amount, label, expiration);

    // TODO: Persist batch

    if (!isClosed) {
      final updatedBatches = {...state.batches};
      updatedBatches[Uuid().v4()] = newBatch;
      emit(state.copyWith(batches: updatedBatches));
    }
  }

  Future<void> updateBatchesWithPopulatedSubkeyCount() async {
    // TODO: Is this prone to overriding a batch that was created while an update was running?
    for (final batch in state.batches.entries) {
      final updatedBatch =
          await updateBatchWithPopulatedSubkeyCount(batch.value);

      if (isClosed) {
        return;
      }

      final updatedBatches = {...state.batches};
      updatedBatches[batch.key] = updatedBatch;
      emit(state.copyWith(batches: updatedBatches));
    }
  }
}
