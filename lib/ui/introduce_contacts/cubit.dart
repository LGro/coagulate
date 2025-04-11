// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../data/models/coag_contact.dart';
import '../../data/repositories/contacts.dart';

part 'cubit.g.dart';
part 'state.dart';

class IntroduceContactsCubit extends Cubit<IntroduceContactsState> {
  IntroduceContactsCubit(this.contactsRepository)
      : super(IntroduceContactsState(IntroduceContactsStatus.initial,
            contacts: contactsRepository.getContacts().values.asList())) {
    _contactsSubscription = contactsRepository.getContactStream().listen((_) {
      if (!isClosed) {
        emit(IntroduceContactsState(IntroduceContactsStatus.success,
            contacts: contactsRepository.getContacts().values.asList()));
      }
    });
  }

  ContactsRepository contactsRepository;
  late final StreamSubscription<String> _contactsSubscription;

  Future<bool> introduce(
          {required String contactIdA,
          required String nameA,
          required String contactIdB,
          required String nameB,
          String? message}) async =>
      contactsRepository.introduce(
          contactIdA: contactIdA,
          nameA: nameA,
          contactIdB: contactIdB,
          nameB: nameB,
          message: message);

  @override
  Future<void> close() {
    _contactsSubscription.cancel();
    return super.close();
  }
}
