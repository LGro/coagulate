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
  ContactDetailsCubit(this.contactsRepository, CoagContact contact)
      : super(ContactDetailsState(
            contact.coagContactId, ContactDetailsStatus.success,
            contact: contact)) {
    _contactsSuscription = contactsRepository.getContactUpdates().listen((c) {
      if (c.coagContactId == contact.coagContactId) {
        emit(ContactDetailsState(c.coagContactId, ContactDetailsStatus.success,
            contact: contact));
      }
    });
  }

  final ContactsRepository contactsRepository;
  late final StreamSubscription<CoagContact> _contactsSuscription;

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
    // contactsRepository.coagContacts.remove(coagContactId);
  }

  @override
  Future<void> close() {
    _contactsSuscription.cancel();
    return super.close();
  }
}
