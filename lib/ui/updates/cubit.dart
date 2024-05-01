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
    _contactsSuscription = contactsRepository.getContactUpdates().listen(
        (contact) => emit(UpdatesState(UpdatesStatus.success,
            updates: contactsRepository.updates.reversed)));
    emit(UpdatesState(UpdatesStatus.success,
        updates: contactsRepository.updates.reversed));
  }

  final ContactsRepository contactsRepository;
  late final StreamSubscription<CoagContact> _contactsSuscription;

  Future<void> refresh() => contactsRepository.updateAndWatchReceivingDHT();

  @override
  UpdatesState fromJson(Map<String, dynamic> json) =>
      UpdatesState.fromJson(json);

  @override
  Map<String, dynamic> toJson(UpdatesState state) => state.toJson();

  @override
  Future<void> close() {
    _contactsSuscription.cancel();
    return super.close();
  }
}
