// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../data/models/coag_contact.dart';
import '../../data/repositories/contacts.dart';

part 'cubit.g.dart';
part 'state.dart';

class ContactDetailsCubit extends HydratedCubit<ContactDetailsState> {
  ContactDetailsCubit(this.contactsRepository, String coagContactId)
      : super(
            ContactDetailsState(coagContactId, ContactDetailsStatus.initial)) {
    // TODO: Subscribe to
    // contactsRepository.getUpdateStatus()
    emit(ContactDetailsState(coagContactId, ContactDetailsStatus.success,
        contact: contactsRepository.coagContacts[coagContactId]));
  }

  final ContactsRepository contactsRepository;

  @override
  ContactDetailsState fromJson(Map<String, dynamic> json) =>
      ContactDetailsState.fromJson(json);

  @override
  Map<String, dynamic> toJson(ContactDetailsState state) => state.toJson();

  Future<void> shareWith(String coagContactId, String sharedProfile) async {
    final updatedContact =
        state.contact!.copyWith(sharedProfile: sharedProfile);

    // Already emit before update trickles down via repository?
    // emit(ContactDetailsState(coagContactId, ContactDetailsStatus.success,
    //     contact: updatedContact));

    // TODO: Do we really need to await here?
    await contactsRepository.updateContact(updatedContact);
  }

  Future<void> unshareWith(String coagContactId) async =>
      shareWith(coagContactId, '');
}
