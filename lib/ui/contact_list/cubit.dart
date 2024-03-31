// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../data/models/coag_contact.dart';
import '../../data/repositories/contacts.dart';

part 'cubit.g.dart';
part 'state.dart';

// TODO: Figure out sorting of the contacts
class ContactListCubit extends HydratedCubit<ContactListState> {
  ContactListCubit(this.contactsRepository)
      : super(const ContactListState(ContactListStatus.initial)) {
    // TODO: Is there an emit.forEach in Cubits like with Blocs?
    contactsRepository.getUpdateStatus().listen((event) {
      // TODO: Is there something smarter than always replacing the full state?
      emit(ContactListState(ContactListStatus.success,
          contacts: contactsRepository.coagContacts.values));
    });

    emit(ContactListState(ContactListStatus.success,
        contacts: contactsRepository.coagContacts.values));
  }

  final ContactsRepository contactsRepository;

  @override
  ContactListState fromJson(Map<String, dynamic> json) =>
      ContactListState.fromJson(json);

  @override
  Map<String, dynamic> toJson(ContactListState state) => state.toJson();
}
