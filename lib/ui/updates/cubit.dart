// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../data/models/contact_update.dart';
import '../../data/repositories/contacts.dart';
import '../utils.dart';

part 'state.dart';
part 'cubit.g.dart';

class UpdatesCubit extends Cubit<UpdatesState> {
  UpdatesCubit(this.contactsRepository)
      : super(const UpdatesState(UpdatesStatus.initial)) {
    _updatesSubscription = contactsRepository.getUpdatesStream().listen((_) =>
        emit(UpdatesState(UpdatesStatus.success,
            updates: contactsRepository.getContactUpdates().reversed.where(
                (u) => contactUpdateSummary(u.oldContact, u.newContact)
                    .isNotEmpty))));
    emit(UpdatesState(UpdatesStatus.success,
        updates: contactsRepository.getContactUpdates().reversed.where((u) =>
            contactUpdateSummary(u.oldContact, u.newContact).isNotEmpty)));
  }

  final ContactsRepository contactsRepository;
  late final StreamSubscription<ContactUpdate> _updatesSubscription;

  Future<bool> refresh() => contactsRepository.updateAndWatchReceivingDHT();

  @override
  Future<void> close() {
    _updatesSubscription.cancel();
    return super.close();
  }
}
