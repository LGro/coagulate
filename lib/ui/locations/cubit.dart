// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
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
          temporaryLocations: profileInfo.temporaryLocations,
          circleMembersips: contactsRepository.getCircleMemberships()));
    });
    emit(LocationsState(
        circleMembersips: contactsRepository.getCircleMemberships(),
        temporaryLocations:
            contactsRepository.getProfileInfo()?.temporaryLocations ?? {}));
  }

  final ContactsRepository contactsRepository;
  late final StreamSubscription<ProfileInfo> _profileInfoSubscription;

  List<ContactTemporaryLocation> _sort(
          List<ContactTemporaryLocation> locations) =>
      locations.sortedBy((l) => l.start);

  Future<void> removeLocation(String locationId) async {
    final profileInfo = contactsRepository.getProfileInfo();
    if (profileInfo == null) {
      return;
    }
    await contactsRepository.setProfileInfo(profileInfo.copyWith(
        temporaryLocations: {...profileInfo.temporaryLocations}
          ..remove(locationId)));
  }

  @override
  Future<void> close() {
    _profileInfoSubscription.cancel();
    return super.close();
  }

  Future<void> toggleCheckInExisting(String locationId) async {
    final profileInfo = contactsRepository.getProfileInfo();
    if (profileInfo == null) {
      return;
    }
    // TODO: Test that this is responsive also when location is shared with many contacts
    await contactsRepository.setProfileInfo(profileInfo.copyWith(
        temporaryLocations: Map.fromEntries(profileInfo
            .temporaryLocations.entries
            .map((l) => (l.key == locationId)
                ? MapEntry(
                    l.key, l.value.copyWith(checkedIn: !l.value.checkedIn))
                : MapEntry(l.key, l.value.copyWith(checkedIn: false))))));
  }
}
