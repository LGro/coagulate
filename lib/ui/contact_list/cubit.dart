// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../data/models/coag_contact.dart';
import '../../data/repositories/contacts.dart';

part 'cubit.g.dart';
part 'state.dart';

class ContactListCubit extends HydratedCubit<ContactListState> {
  ContactListCubit(this.contactsRepository, String coagContactId)
      : super(ContactListState(coagContactId, ContactListStatus.initial)) {
    // TODO: Is there an emit.forEach in Cubits like with Blocs?
    contactsRepository.getUpdateStatus().listen((event) {
      if (event.contains(coagContactId)) {
        emit(ContactListState(coagContactId, ContactListStatus.success,
            contact: contactsRepository.coagContacts[coagContactId]));
      }
    });

    emit(ContactListState(coagContactId, ContactListStatus.success,
        contact: contactsRepository.coagContacts[coagContactId]));
  }

  final ContactsRepository contactsRepository;

  @override
  ContactListState fromJson(Map<String, dynamic> json) =>
      ContactListState.fromJson(json);

  @override
  Map<String, dynamic> toJson(ContactListState state) => state.toJson();

  Future<void> shareWith(String coagContactId, String sharedProfile) async {
    final updatedContact =
        state.contact!.copyWith(sharedProfile: sharedProfile);

    // Already emit before update trickles down via repository?
    // emit(ContactListState(coagContactId, ContactListStatus.success,
    //     contact: updatedContact));

    // TODO: Do we really need to await here?
    await contactsRepository.updateContact(updatedContact);
  }

  Future<void> unshareWith(String coagContactId) async =>
      shareWith(coagContactId, '');
}
