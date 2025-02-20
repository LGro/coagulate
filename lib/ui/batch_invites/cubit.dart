// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:veilid_support/veilid_support.dart';

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
  final record = await routingContext.createDHTRecord(DHTSchema.smpl(
      oCnt: 1,
      members: subkeyWriters
          .map((w) => DHTSchemaMember(mKey: w.key, mCnt: 1))
          .toList()));

  // DHT record content crypto
  final psk = await cryptoSystem.randomSharedSecret();
  final pskCrypto = await VeilidCryptoPrivate.fromTypedKey(
      TypedSecret(kind: cryptoSystem.kind(), value: psk), 'Coagulate Share');

  // Write general info to first subkey with owner writer key pair
  // TODO: Specify schema for this
  final info = {
    'label': label,
    'expires': DateFormat('yyyy-MM-dd').format(expiration),
  };
  await routingContext.openDHTRecord(record.key, writer: ownerWriter);
  await routingContext.setDHTValue(
      record.key, 0, await pskCrypto.encrypt(utf8.encode(jsonEncode(info))),
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

class BatchInvitesCubit extends Cubit<BatchInvitesState> {
  BatchInvitesCubit() : super(const BatchInvitesState());

  // TODO: How long does this take? Do we need a loading spinner?
  Future<void> generateInvites(
      String label, int amount, DateTime expiration) async {
    final batch = await createBatch(amount, label, expiration);
    if (!isClosed) {
      emit(state.copyWith(batches: [...state.batches, batch]));
    }
  }
}
