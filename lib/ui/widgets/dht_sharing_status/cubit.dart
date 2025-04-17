// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
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

class DhtSharingStatusCubit extends Cubit<DhtSharingStatusState>
    with WidgetsBindingObserver {
  DhtSharingStatusCubit({required this.recordKeys})
      : super(const DhtSharingStatusState('initial')) {
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
    unawaited(updateStatus());
  }

  final Iterable<Typed<FixedEncodedString43>> recordKeys;
  late final Timer? timerPersistentStorageRefresh;

  void _startTimer() {
    timerPersistentStorageRefresh =
        Timer.periodic(const Duration(seconds: 5), (_) async => updateStatus());
  }

  void _stopTimer() => timerPersistentStorageRefresh?.cancel();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App is in the foreground
      _startTimer();
    } else if (state == AppLifecycleState.paused) {
      // App is in the background
      _stopTimer();
    }
  }

  Future<void> updateStatus() async {
    final numSubkeys = recordKeys.length * 32;
    try {
      final offlineSubkeysPerContact = await Future.wait(recordKeys.map(
          (k) async =>
              getRecordReport(k).then((r) => r?.offlineSubkeys.length)));

      final numUnknown =
          offlineSubkeysPerContact.where((n) => n == null).length;

      final numOfflineSubkeys =
          offlineSubkeysPerContact.whereType<int>().fold(0, (a, b) => a + b);

      if (!isClosed) {
        // TODO: Move rendering to widget
        // Beware division by zero o.O
        if (numSubkeys == 0) {
          return emit(const DhtSharingStatusState(''));
        }
        return emit(DhtSharingStatusState(
            '${((1 - (numOfflineSubkeys / numSubkeys)) * 100).round()}% synced / '
            '${((numUnknown / numSubkeys) * 100).round()}% unknown / '
            '$numSubkeys subkeys total'));
      }
    } on VeilidAPIExceptionTryAgain {
      return;
    }
  }

  @override
  Future<void> close() {
    _stopTimer();
    WidgetsBinding.instance.removeObserver(this);
    return super.close();
  }
}
