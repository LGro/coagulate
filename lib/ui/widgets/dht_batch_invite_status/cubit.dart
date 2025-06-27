// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../../data/models/batch_invites.dart';
import '../../batch_invite_management/cubit.dart';

part 'cubit.g.dart';
part 'state.dart';

class DhtBatchInviteStatusCubit extends Cubit<DhtBatchInviteStatusState>
    with WidgetsBindingObserver {
  DhtBatchInviteStatusCubit({required this.batch})
      : super(const DhtBatchInviteStatusState('initial')) {
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
    unawaited(updateStatus());
  }

  final Batch batch;
  late final Timer? timerPersistentStorageRefresh;

  void _startTimer() {
    timerPersistentStorageRefresh = Timer.periodic(
        const Duration(seconds: 15), (_) async => updateStatus());
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
    final subkeyIndices =
        List.generate(batch.subkeyWriters.length, (i) => i + 1);
    final subkeyNames = Map<int, String?>.fromEntries(
        subkeyIndices.map((i) => MapEntry(i, null)));
    try {
      final crypto = await VeilidCryptoPrivate.fromSharedSecret(
          batch.dhtRecordKey.kind, batch.psk);
      final record = await DHTRecordPool.instance.openRecordRead(
          batch.dhtRecordKey,
          crypto: crypto,
          debugName: 'coag::read::batch');
      for (final i in subkeyIndices) {
        try {
          final subkeyContent = await record.get(
              crypto: crypto,
              refreshMode: DHTRecordRefreshMode.network,
              subkey: i);
          final subkeyJson =
              jsonDecode(utf8.decode(subkeyContent!)) as Map<String, dynamic>;
          final subkeyInfo = BatchSubkeySchema.fromJson(subkeyJson);
          subkeyNames[i] = subkeyInfo.name;
        } catch (e) {
          subkeyNames[i] = '$e';
        }
      }
      await record.close();
    } on DHTExceptionNotAvailable catch (e) {
      if (!isClosed) {
        return emit(DhtBatchInviteStatusState('disconnected $e'));
      }
    } on VeilidAPIExceptionTryAgain catch (e) {
      if (!isClosed) {
        return emit(DhtBatchInviteStatusState('disconnected $e'));
      }
    }
    emit(DhtBatchInviteStatusState('finished', subkeyNames: subkeyNames));
  }

  @override
  Future<void> close() {
    _stopTimer();
    WidgetsBinding.instance.removeObserver(this);
    return super.close();
  }
}
