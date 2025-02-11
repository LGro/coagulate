// Copyright 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:veilid/veilid.dart';
import 'package:veilid_support/veilid_support.dart';

part 'cubit.g.dart';
part 'state.dart';

// TODO: Refactor status to enum or switch to signal meter without options?
class VeilidStatusCubit extends Cubit<VeilidStatusState> {
  VeilidStatusCubit() : super(const VeilidStatusState('initial')) {
    timerPersistentStorageRefresh =
        Timer.periodic(const Duration(seconds: 5), (_) async => updateStatus());

    unawaited(updateStatus());
  }

  late final Timer? timerPersistentStorageRefresh;

  Future<void> updateStatus() async {
    final veilidState = await Veilid.instance.getVeilidState();
    final numConnectedNodes = veilidState.network.peers
        .where((p) =>
            p.peerStats.latency?.average != null &&
            p.peerStats.latency!.average < TimestampDuration.fromMillis(5000))
        .length;
    if (!isClosed) {
      return emit(VeilidStatusState('$numConnectedNodes connected'));
    }
  }

  @override
  Future<void> close() {
    timerPersistentStorageRefresh?.cancel();
    return super.close();
  }
}
