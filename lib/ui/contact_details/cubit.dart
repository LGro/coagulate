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
      : super(ContactDetailsState(coagContactId, ContactDetailsStatus.success,
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
        emit(state.copyWith(
            coagContactId: c.coagContactId,
            status: ContactDetailsStatus.success,
            contact: c));
      }
    });
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

  // TODO: Figure out better way to set the shareprofile to null again
  // The solution is probably adding profile sharing filters and then switching this to a filter that doesn't let anything through?
  Future<void> unshare() async => contactsRepository
      .updateContact(state.contact!.copyWith(sharedProfile: ''));

  Future<void> delete(String coagContactId) async =>
      contactsRepository.removeContact(coagContactId);

  @override
  Future<void> close() {
    _contactsSuscription.cancel();
    _circlesSubscription.cancel();
    return super.close();
  }
}
