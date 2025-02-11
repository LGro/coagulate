// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../data/models/coag_contact.dart';
import '../../data/models/contact_location.dart';
import '../../data/repositories/contacts.dart';

part 'cubit.g.dart';
part 'state.dart';

class LocationsCubit extends Cubit<LocationsState> {
  LocationsCubit(this.contactsRepository) : super(const LocationsState()) {
    _contactsSuscription =
        contactsRepository.getContactStream().listen((idUpdatedContact) async {
      final profileContact = contactsRepository.getProfileContact();
      if (idUpdatedContact == profileContact?.coagContactId) {
        emit(LocationsState(
            temporaryLocations: _sort(profileContact!.temporaryLocations),
            circleMembersips: contactsRepository.getCircleMemberships()));
      }
    });
    emit(LocationsState(
        circleMembersips: contactsRepository.getCircleMemberships(),
        temporaryLocations: (contactsRepository.getProfileContact() == null)
            ? []
            : _sort(
                contactsRepository.getProfileContact()!.temporaryLocations)));
  }

  final ContactsRepository contactsRepository;
  late final StreamSubscription<String> _contactsSuscription;

  List<ContactTemporaryLocation> _sort(
          List<ContactTemporaryLocation> locations) =>
      locations.sortedBy((l) => l.start).asList();

  Future<void> removeLocation(ContactTemporaryLocation location) async {
    final profileContact = contactsRepository.getProfileContact();
    if (profileContact == null) {
      return;
    }
    await contactsRepository.updateProfileContactData(profileContact.copyWith(
        temporaryLocations: profileContact.temporaryLocations
            .where((l) => l != location)
            .asList()));
  }

  @override
  Future<void> close() {
    _contactsSuscription.cancel();
    return super.close();
  }

  Future<void> toggleCheckInExisting(ContactTemporaryLocation location) async {
    final profileContact = contactsRepository.getProfileContact();
    if (profileContact == null) {
      return;
    }
    // TODO: Test that this is responsive also when location is shared with many contacts
    await contactsRepository.updateProfileContactData(profileContact.copyWith(
        temporaryLocations: profileContact.temporaryLocations
            .map((l) => (l == location)
                ? l.copyWith(checkedIn: !l.checkedIn)
                : l.copyWith(checkedIn: false))
            .toList()));
  }
}
