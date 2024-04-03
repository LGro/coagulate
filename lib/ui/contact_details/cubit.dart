// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../data/models/coag_contact.dart';
import '../../data/repositories/contacts.dart';

part 'cubit.g.dart';
part 'state.dart';

// TODO: Add sharing profile and filter
CoagContactDHTSchemaV1 _filterAccordingToSharingProfile(CoagContact contact) =>
    CoagContactDHTSchemaV1(
      coagContactId: contact.coagContactId,
      details: contact.details!,
      locations: contact.locations,
      // TODO: Ensure these are populated by the time this is called
      shareBackDHTKey: contact.dhtSettingsForReceiving?.key,
      shareBackDHTWriter: contact.dhtSettingsForReceiving?.writer,
      shareBackPubKey: contact.dhtSettingsForReceiving?.pubKey,
    );

Map<String, dynamic> _removeNullOrEmptyValues(Map<String, dynamic> json) {
  // TODO: implement me; or implement custom schema for sharing payload
  return json;
}

class ContactDetailsCubit extends HydratedCubit<ContactDetailsState> {
  ContactDetailsCubit(this.contactsRepository, String coagContactId)
      : super(
            ContactDetailsState(coagContactId, ContactDetailsStatus.initial)) {
    // TODO: Is there an emit.forEach in Cubits like with Blocs?
    contactsRepository.getUpdateStatus().listen((event) {
      if (event.contains(coagContactId)) {
        emit(ContactDetailsState(coagContactId, ContactDetailsStatus.success,
            contact: contactsRepository.coagContacts[coagContactId]));
      }
    });

    emit(ContactDetailsState(coagContactId, ContactDetailsStatus.success,
        contact: contactsRepository.coagContacts[coagContactId]));
  }

  final ContactsRepository contactsRepository;

  @override
  ContactDetailsState fromJson(Map<String, dynamic> json) =>
      ContactDetailsState.fromJson(json);

  @override
  Map<String, dynamic> toJson(ContactDetailsState state) => state.toJson();

  Future<void> share(CoagContact profileToShare) async {
    final sharedProfile = json.encode(_removeNullOrEmptyValues(
        _filterAccordingToSharingProfile(profileToShare).toJson()));
    final updatedContact =
        state.contact!.copyWith(sharedProfile: sharedProfile);

    // TODO: Do we really need to await here?
    await contactsRepository.updateContact(updatedContact);
  }

  // FIXME: Passing null to copyWith won't override the sharedProfile with null
  Future<void> unshare() async => contactsRepository
      .updateContact(state.contact!.copyWith(sharedProfile: null));
}
