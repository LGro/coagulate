// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:veilid/veilid.dart';
import '../../data/repositories/contacts.dart';

part 'cubit.g.dart';
part 'state.dart';

class RestoreCubit extends Cubit<RestoreState> {
  RestoreCubit(this.contactsRepository) : super(const RestoreState());

  ContactsRepository contactsRepository;

  Future<void> restore(Typed<FixedEncodedString43> recordKey,
      FixedEncodedString43 secret) async {
    emit(const RestoreState(status: RestoreStatus.create));

    final result = await contactsRepository.restore(recordKey, secret);

    if (!isClosed) {
      emit(RestoreState(
          status: result ? RestoreStatus.success : RestoreStatus.failure));
    }
  }
}
