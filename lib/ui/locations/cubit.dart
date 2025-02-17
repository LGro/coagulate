// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

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
    _profileInfoSubscription =
        contactsRepository.getProfileInfoStream().listen((profileInfo) async {
      emit(LocationsState(
          temporaryLocations: _sort(profileInfo.temporaryLocations),
          circleMembersips: contactsRepository.getCircleMemberships()));
    });
    emit(LocationsState(
        circleMembersips: contactsRepository.getCircleMemberships(),
        temporaryLocations:
            _sort(contactsRepository.getProfileInfo().temporaryLocations)));
  }

  final ContactsRepository contactsRepository;
  late final StreamSubscription<ProfileInfo> _profileInfoSubscription;

  List<ContactTemporaryLocation> _sort(
          List<ContactTemporaryLocation> locations) =>
      locations.sortedBy((l) => l.start).asList();

  Future<void> removeLocation(ContactTemporaryLocation location) async {
    final profileInfo = contactsRepository.getProfileInfo();
    await contactsRepository.setProfileInfo(profileInfo.copyWith(
        temporaryLocations: profileInfo.temporaryLocations
            .where((l) => l != location)
            .asList()));
  }

  @override
  Future<void> close() {
    _profileInfoSubscription.cancel();
    return super.close();
  }

  Future<void> toggleCheckInExisting(ContactTemporaryLocation location) async {
    final profileInfo = contactsRepository.getProfileInfo();
    // TODO: Test that this is responsive also when location is shared with many contacts
    await contactsRepository.setProfileInfo(profileInfo.copyWith(
        temporaryLocations: profileInfo.temporaryLocations
            .map((l) => (l == location)
                ? l.copyWith(checkedIn: !l.checkedIn)
                : l.copyWith(checkedIn: false))
            .toList()));
  }
}
