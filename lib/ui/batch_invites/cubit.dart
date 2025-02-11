// Copyright 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cubit.g.dart';
part 'state.dart';

class BatchInvitesCubit extends Cubit<BatchInvitesState> {
  BatchInvitesCubit() : super(const BatchInvitesState());

  void generateInvites(String label, int amount, DateTime expiration) {
    // Generate PSK for batch
    // Create DHT record with as many subkeys with individual writers as amount specified
    // Write label and expiration to DHT main record / or first subkey
    // Each link contains DHT key, writer and PSK
    // Trigger share dialogue with comma separated links
  }
}
