// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/coag_contact.dart';
import '../../data/models/contact_introduction.dart';
import '../../data/repositories/contacts.dart';

part 'state.dart';
part 'cubit.g.dart';

class IntroductionsCubit extends Cubit<IntroductionsState> {
  IntroductionsCubit(this.contactsRepository)
      : super(IntroductionsState(contacts: contactsRepository.getContacts())) {
    _contactsSubscription =
        contactsRepository.getContactStream().listen((idUpdatedContact) {
      if (!isClosed) {
        emit(IntroductionsState(contacts: contactsRepository.getContacts()));
      }
    });
  }

  final ContactsRepository contactsRepository;
  late final StreamSubscription<String> _contactsSubscription;

  Future<String?> accept(
          CoagContact introducer, ContactIntroduction introduction) async =>
      contactsRepository.acceptIntroduction(introducer, introduction);

  @override
  Future<void> close() {
    _contactsSubscription.cancel();
    return super.close();
  }
}
