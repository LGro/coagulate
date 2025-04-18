// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:veilid/veilid.dart';
import '../../data/repositories/contacts.dart';

part 'cubit.g.dart';
part 'state.dart';

class BackupCubit extends Cubit<BackupState> {
  BackupCubit(this.contactsRepository) : super(const BackupState());

  ContactsRepository contactsRepository;

  Future<void> backup() async {
    emit(const BackupState(status: BackupStatus.create));

    final result = await contactsRepository.backup();

    if (!isClosed) {
      if (result == null) {
        emit(const BackupState(status: BackupStatus.failure));
      } else {
        emit(BackupState(
            status: BackupStatus.success,
            dhtRecordKey: result.$1,
            secret: result.$2));
      }
    }
  }
}
