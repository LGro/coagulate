// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../data/models/contact_location.dart';
import '../../data/repositories/contacts.dart';

part 'cubit.g.dart';
part 'state.dart';

class LocationsCubit extends Cubit<LocationsState> {
  LocationsCubit(this.contactsRepository) : super(const LocationsState());

  final ContactsRepository contactsRepository;

  void addRandomLocation() {
    emit(LocationsState(temporaryLocations: [
      ...state.temporaryLocations,
      ContactTemporaryLocation(
          coagContactId: contactsRepository.profileContactId!,
          longitude: Random().nextDouble() * 10,
          latitude: Random().nextDouble() * 10,
          name: 'random location',
          start: DateTime.now(),
          end: DateTime.now().add(Duration(hours: 2)),
          details: '')
    ]));
  }
}
