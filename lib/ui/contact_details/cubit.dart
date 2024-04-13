// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:convert';

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
    // TODO: Is there an emit.forEach in Cubits like with Blocs?
    _contactUpdatesSubscription =
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
  late final StreamSubscription<String> _contactUpdatesSubscription;

  @override
  ContactDetailsState fromJson(Map<String, dynamic> json) =>
      ContactDetailsState.fromJson(json);

  @override
  Map<String, dynamic> toJson(ContactDetailsState state) => state.toJson();

  // TODO: Use a method from repo level instead
  Future<void> share(CoagContact profileToShare) async {
    final sharedProfile = json.encode(removeNullOrEmptyValues(
        filterAccordingToSharingProfile(profileToShare).toJson()));
    final updatedContact =
        state.contact!.copyWith(sharedProfile: sharedProfile);

    await contactsRepository.updateContact(updatedContact);
  }

  // TODO: Figure out better way to set the shareprofile to null again
  // The solution is probably adding profile sharing filters and then switching this to a filter that doesn't let anything through?
  Future<void> unshare() async => contactsRepository
      .updateContact(state.contact!.copyWith(sharedProfile: ''));

  void delete(String coagContactId) {
    // FIXME: This is hacky and should be in the repo
    contactsRepository.coagContacts.remove(coagContactId);
  }

  @override
  Future<void> close() {
    _contactUpdatesSubscription.cancel();
    return super.close();
  }
}
