// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/contact_location.dart';
import '../../../data/repositories/contacts.dart';

part 'cubit.g.dart';
part 'state.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  ScheduleCubit(this.contactsRepository)
      : super(ScheduleState(
            checkingIn: false,
            circles: contactsRepository.getCircles(),
            circleMemberships: contactsRepository.getCircleMemberships()));

  final ContactsRepository contactsRepository;

  Future<void> schedule({
    required String name,
    required String details,
    required DateTime start,
    required DateTime end,
    required LatLng coordinates,
    required List<String> circles,
  }) async {
    emit(state.copyWith(checkingIn: true));

    final profileInfo = contactsRepository.getProfileInfo();
    if (profileInfo == null) {
      return;
    }

    await contactsRepository.setProfileInfo(profileInfo.copyWith(
        temporaryLocations: Map.fromEntries([
      ...profileInfo.temporaryLocations.entries
          .map((l) => MapEntry(l.key, l.value.copyWith(checkedIn: false))),
      MapEntry(
          Uuid().v4(),
          ContactTemporaryLocation(
              longitude: coordinates.longitude,
              latitude: coordinates.latitude,
              start: start,
              name: name,
              details: details,
              end: end,
              circles: circles))
    ])));

    if (!isClosed) {
      emit(state.copyWith(checkingIn: false));
    }
  }
}
