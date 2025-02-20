// Copyright 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:veilid_support/veilid_support.dart';

part 'cubit.g.dart';
part 'state.dart';

// TODO: Refactor status to enum
class DhtStatusCubit extends Cubit<DhtStatusState> {
  DhtStatusCubit({required this.recordKey})
      : super(const DhtStatusState('initial')) {
    timerPersistentStorageRefresh =
        Timer.periodic(const Duration(seconds: 5), (_) async => updateStatus());
    unawaited(updateStatus());
  }

  final Typed<FixedEncodedString43> recordKey;
  late final Timer? timerPersistentStorageRefresh;

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
    timerPersistentStorageRefresh?.cancel();
    return super.close();
  }
}
