// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../data/models/coag_contact.dart';
import '../../data/repositories/contacts.dart';

part 'cubit.g.dart';
part 'state.dart';

class ContactDetailsCubit extends Cubit<ContactDetailsState> {
  ContactDetailsCubit(this.contactsRepository, String coagContactId)
      : super(ContactDetailsState(ContactDetailsStatus.success,
            contactsRepository.getContact(coagContactId),
            circles:
                (contactsRepository.getCircleMemberships()[coagContactId] ?? [])
                    .map((id) => contactsRepository.getCircles()[id])
                    .nonNulls
                    .toList())) {
    _circlesSubscription = contactsRepository.getCirclesUpdates().listen((c) {
      if (!isClosed) {
        emit(state.copyWith(
            circles:
                (contactsRepository.getCircleMemberships()[coagContactId] ?? [])
                    .map((id) => contactsRepository.getCircles()[id])
                    .nonNulls
                    .toList()));
      }
    });
    _contactsSuscription = contactsRepository.getContactUpdates().listen((c) {
      if (c.coagContactId == coagContactId && !isClosed) {
        emit(state.copyWith(status: ContactDetailsStatus.success, contact: c));
      }
    });

    // Attempt to share straight await, when a contact details page is visited
    final profileContact = contactsRepository.getProfileContact();
    if (profileContact != null) {
      unawaited(share(profileContact));
    }
  }

  final ContactsRepository contactsRepository;
  late final StreamSubscription<CoagContact> _contactsSuscription;
  late final StreamSubscription<void> _circlesSubscription;

  // TODO: Use a method from repo level instead
  Future<void> share(CoagContact profileToShare) async {
    final sharedProfile = json.encode(removeNullOrEmptyValues(
        filterAccordingToSharingProfile(
                profile: profileToShare,
                settings: contactsRepository.getProfileSharingSettings(),
                activeCircles: contactsRepository
                        .getCircleMemberships()[state.contact.coagContactId] ??
                    [],
                shareBackSettings: state.contact.dhtSettingsForReceiving)
            .toJson()));
    final updatedContact = state.contact.copyWith(sharedProfile: sharedProfile);

    await contactsRepository.updateContact(updatedContact);
  }

  Future<void> delete(String coagContactId) async =>
      contactsRepository.removeContact(coagContactId);

  @override
  Future<void> close() {
    _contactsSuscription.cancel();
    _circlesSubscription.cancel();
    return super.close();
  }
}
