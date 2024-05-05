// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../data/models/coag_contact.dart';
import '../../data/models/contact_update.dart';
import '../../data/repositories/contacts.dart';

part 'state.dart';
part 'cubit.g.dart';

class UpdatesCubit extends Cubit<UpdatesState> {
  UpdatesCubit(this.contactsRepository)
      : super(const UpdatesState(UpdatesStatus.initial)) {
    _contactsSubscription = contactsRepository.getContactUpdates().listen(
        (contact) => emit(UpdatesState(UpdatesStatus.success,
            updates: contactsRepository.updates.reversed)));
    emit(UpdatesState(UpdatesStatus.success,
        updates: contactsRepository.updates.reversed));
  }

  final ContactsRepository contactsRepository;
  late final StreamSubscription<CoagContact> _contactsSubscription;

  Future<void> refresh() => contactsRepository.updateAndWatchReceivingDHT();

  @override
  Future<void> close() {
    _contactsSubscription.cancel();
    return super.close();
  }
}
