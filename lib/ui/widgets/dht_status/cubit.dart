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

// TODO: Refactor status to enum
class DhtStatusCubit extends Cubit<DhtStatusState> with WidgetsBindingObserver {
  DhtStatusCubit({required this.recordKey})
      : super(const DhtStatusState('initial')) {
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
    unawaited(updateStatus());
  }

  final Typed<FixedEncodedString43> recordKey;
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
    try {
      final report = await DHTRecordPool.instance
          .openRecordRead(recordKey, debugName: 'coag::read::stats')
          .then((record) async {
        final report = await record.routingContext.inspectDHTRecord(recordKey);
        await record.close();
        return report;
      });

      if (!isClosed) {
        if (report.offlineSubkeys.isEmpty) {
          return emit(const DhtStatusState('synced'));
        } else {
          return emit(const DhtStatusState('pending'));
        }
      }
    } on VeilidAPIExceptionTryAgain catch (e) {
      if (!isClosed) {
        return emit(DhtStatusState('disconnected $e'));
      }
    }
  }

  @override
  Future<void> close() {
    _stopTimer();
    WidgetsBinding.instance.removeObserver(this);
    return super.close();
  }
}
