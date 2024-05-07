// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:location/location.dart';

import '../../../data/models/contact_location.dart';
import '../../../data/repositories/contacts.dart';

part 'cubit.g.dart';
part 'state.dart';

class CheckInCubit extends Cubit<CheckInState> {
  CheckInCubit(this.contactsRepository)
      : super(const CheckInState(checkingIn: false));

  final ContactsRepository contactsRepository;

  Future<void> checkIn(
      {required String name,
      required String details,
      required DateTime end}) async {
    emit(const CheckInState(checkingIn: true));

    final location = await Location().getLocation();

    if (location.longitude == null || location.latitude == null) {
      //TODO: Emit failure stte
      return;
    }

    final profileContact = await contactsRepository.getProfileContact();
    if (profileContact == null) {
      return;
    }
    await contactsRepository
        .updateContact(profileContact.copyWith(temporaryLocations: [
      ...profileContact.temporaryLocations
          .map((l) => l.copyWith(checkedIn: false)),
      ContactTemporaryLocation(
          coagContactId: contactsRepository.profileContactId!,
          longitude: location.longitude!,
          latitude: location.latitude!,
          start: DateTime.now(),
          // TODO: Get the remaining details from a user input form
          name: name,
          details: details,
          end: end,
          checkedIn: true)
    ]));
    // Make sure to regenerate the sharing profiles and update DHT sharing records
    await contactsRepository.updateProfileContact(profileContact.coagContactId);
    if (!isClosed) {
      emit(const CheckInState(checkingIn: false));
    }
  }
}
