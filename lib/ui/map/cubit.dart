// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../data/models/contact_location.dart';
import '../../data/repositories/contacts.dart';

part 'cubit.g.dart';
part 'state.dart';

Iterable<Location> addressLocationsToLocations(
        Iterable<ContactAddressLocation> addressLocations,
        String label,
        String? coagContactId) =>
    addressLocations.map((l) => Location(
        coagContactId: coagContactId,
        longitude: l.longitude,
        latitude: l.latitude,
        label: label,
        subLabel: l.name,
        details: '',
        marker: MarkerType.address));

Location temporaryLocationToLocation(
        String label, ContactTemporaryLocation l, String? coagContactId) =>
    Location(
        coagContactId: coagContactId,
        label: label,
        subLabel: l.name,
        longitude: l.longitude,
        latitude: l.latitude,
        details: '${DateFormat("yyyy-MM-dd HH:mm").format(l.start)} - '
            '${DateFormat("yyyy-MM-dd HH:mm").format(l.end)}'
            '\nDetails: ${l.details}',
        marker: MarkerType.temporary);

class MapCubit extends Cubit<MapState> {
  MapCubit(this.contactsRepository)
      : super(const MapState([], MapStatus.initial)) {
    _contactsSuscription =
        contactsRepository.getContactStream().listen((coagContactId) {
      final contact = contactsRepository.getContact(coagContactId);
      if (contact == null) {
        return;
      }
      emit(MapState([
        ...state.locations.where((l) => l.coagContactId != coagContactId),
        ...addressLocationsToLocations(contact.addressLocations.values,
            contact.name, contact.coagContactId),
        ...contact.temporaryLocations
            .where((l) => l.end.isAfter(DateTime.now()))
            .map((l) => temporaryLocationToLocation(
                contact.name, l, contact.coagContactId))
      ], MapStatus.success,
          mapboxApiToken:
              String.fromEnvironment('COAGULATE_MAPBOX_PUBLIC_TOKEN')));
    });

    final profileInfo = contactsRepository.getProfileInfo();
    final contacts = contactsRepository.getContacts().values.toList();

    emit(MapState([
      // TODO: Localize "me"
      ...addressLocationsToLocations(
          profileInfo.addressLocations.values, 'Me', null),
      ...profileInfo.temporaryLocations
          .where((l) => l.end.isAfter(DateTime.now()))
          .map((l) => temporaryLocationToLocation('Me', l, null)),
      ...contacts
          .map((c) => [
                ...addressLocationsToLocations(
                    c.addressLocations.values, c.name, c.coagContactId),
                ...c.temporaryLocations
                    .where((l) => l.end.isAfter(DateTime.now()))
                    .map((l) =>
                        temporaryLocationToLocation(c.name, l, c.coagContactId))
              ])
          .flattened
    ], MapStatus.success));
  }

  final ContactsRepository contactsRepository;
  late final StreamSubscription<String> _contactsSuscription;

  @override
  Future<void> close() {
    _contactsSuscription.cancel();
    return super.close();
  }
}
