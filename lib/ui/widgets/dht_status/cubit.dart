// Copyright 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../../data/models/coag_contact.dart';
import '../../../data/providers/distributed_storage/dht.dart';
import '../../../data/repositories/contacts.dart';

part 'cubit.g.dart';
part 'state.dart';

// TODO: Refactor status to enum
class DhtStatusCubit extends Cubit<DhtStatusState> {
  DhtStatusCubit({required this.dhtSettings})
      : super(const DhtStatusState('initial')) {
    timerPersistentStorageRefresh =
        Timer.periodic(const Duration(seconds: 5), (_) async => updateStatus());
    unawaited(updateStatus());
  }

  final ContactDHTSettings dhtSettings;
  late final Timer? timerPersistentStorageRefresh;

  Future<void> updateStatus() async {
    // Ensure record is opened
    final distributedStorage = VeilidDhtStorage();
    try {
      await distributedStorage.readRecord(
          recordKey: dhtSettings.key,
          psk: dhtSettings.psk,
          keyPair: await getAppUserKeyPair());
    } on VeilidAPIExceptionTryAgain {
      try {
        await distributedStorage.readRecord(
            recordKey: dhtSettings.key,
            psk: dhtSettings.psk,
            keyPair: await getAppUserKeyPair(),
            refreshMode: DHTRecordRefreshMode.network);
      } on VeilidAPIExceptionTryAgain catch (e) {
        if (!isClosed) {
          return emit(DhtStatusState('disconnected $e'));
        }
      }
    }

    // Inspect record status
    final report = await Veilid.instance.routingContext().then((rc) =>
        rc.inspectDHTRecord(
            Typed<FixedEncodedString43>.fromString(dhtSettings.key)));

    if (isClosed) {
      return;
    }

    if (report.offlineSubkeys.isEmpty) {
      return emit(const DhtStatusState('synced'));
    } else {
      return emit(const DhtStatusState('pending'));
    }
  }

  @override
  Future<void> close() {
    timerPersistentStorageRefresh?.cancel();
    return super.close();
  }
}
