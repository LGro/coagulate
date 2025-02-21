// Copyright 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:veilid_support/veilid_support.dart';

part 'cubit.g.dart';
part 'state.dart';

Future<DHTRecordReport?> getRecordReport(
    Typed<FixedEncodedString43> recordKey) async {
  try {
    return DHTRecordPool.instance
        .openRecordRead(recordKey, debugName: 'coag::read::stats')
        .then((record) async {
      final report = await record.routingContext.inspectDHTRecord(recordKey);
      await record.close();
      return report;
    });
  } on VeilidAPIExceptionTryAgain catch (e) {
    return null;
  }
}

class DhtSharingStatusCubit extends Cubit<DhtSharingStatusState> {
  DhtSharingStatusCubit({required this.recordKeys})
      : super(const DhtSharingStatusState('initial')) {
    timerPersistentStorageRefresh =
        Timer.periodic(const Duration(seconds: 5), (_) async => updateStatus());
    unawaited(updateStatus());
  }

  final Iterable<Typed<FixedEncodedString43>> recordKeys;
  late final Timer? timerPersistentStorageRefresh;

  Future<void> updateStatus() async {
    final numSubkeys = recordKeys.length * 32;

    final offlineSubkeysPerContact = await Future.wait(recordKeys.map(
        (k) async => getRecordReport(k).then((r) => r?.offlineSubkeys.length)));

    final numUnknown = offlineSubkeysPerContact.where((n) => n == null).length;

    final numOfflineSubkeys =
        offlineSubkeysPerContact.whereType<int>().fold(0, (a, b) => a + b);

    if (!isClosed) {
      // TODO: Move rendering to widget
      return emit(DhtSharingStatusState(
          '${((1 - (numOfflineSubkeys / numSubkeys)) * 100).round()}% synced / '
          '${((numUnknown / numSubkeys) * 100).round()}% unknown / '
          '$numSubkeys subkeys total'));
    }
  }

  @override
  Future<void> close() {
    timerPersistentStorageRefresh?.cancel();
    return super.close();
  }
}
