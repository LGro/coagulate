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

Location temporaryLocationToLocation(String label, ContactTemporaryLocation l,
        {String? coagContactId, String? locationId, List<int>? picture}) =>
    Location(
        coagContactId: coagContactId,
        locationId: locationId,
        label: label,
        subLabel: l.name,
        longitude: l.longitude,
        latitude: l.latitude,
        // TODO: Format on page, keep data raw here
        details: '${DateFormat("yyyy-MM-dd HH:mm").format(l.start)} - '
            '${DateFormat("yyyy-MM-dd HH:mm").format(l.end)}'
            '\n${l.details}',
        picture: picture,
        marker: MarkerType.temporary);

class MapCubit extends Cubit<MapState> {
  MapCubit(this.contactsRepository)
      : super(const MapState([], MapStatus.initial)) {
    _contactsSubscription =
        contactsRepository.getContactStream().listen((coagContactId) {
      final contact = contactsRepository.getContact(coagContactId);
      if (contact == null) {
        return;
      }
      emit(MapState([
        ...state.locations.where((l) => l.coagContactId != coagContactId),
        ...addressLocationsToLocations(contact.addressLocations.values,
            contact.name, contact.coagContactId),
        ...filterTemporaryLocations(contact.temporaryLocations).entries.map(
            (l) => temporaryLocationToLocation(contact.name, l.value,
                coagContactId: contact.coagContactId,
                locationId: l.key,
                picture: contact.details?.picture))
      ], MapStatus.success,
          mapboxApiToken:
              String.fromEnvironment('COAGULATE_MAPBOX_PUBLIC_TOKEN')));
    });

    final profileInfo = contactsRepository.getProfileInfo();
    final contacts = contactsRepository.getContacts().values.toList();

    emit(MapState([
      // TODO: Localize "me"
      ...addressLocationsToLocations(
          profileInfo?.addressLocations.values ?? [], 'Me', null),
      ...filterTemporaryLocations(profileInfo?.temporaryLocations ?? {})
          .entries
          .map((l) => temporaryLocationToLocation('Me', l.value,
              locationId: l.key,
              picture: profileInfo?.pictures.values.firstOrNull)),
      ...contacts
          .map((c) => [
                ...addressLocationsToLocations(
                    c.addressLocations.values, c.name, c.coagContactId),
                ...filterTemporaryLocations(c.temporaryLocations).entries.map(
                    (l) => temporaryLocationToLocation(c.name, l.value,
                        coagContactId: c.coagContactId,
                        locationId: l.key,
                        picture: c.details?.picture))
              ])
          .flattened
    ], MapStatus.success));
  }

  final ContactsRepository contactsRepository;
  late final StreamSubscription<String> _contactsSubscription;

  @override
  Future<void> close() {
    _contactsSubscription.cancel();
    return super.close();
  }
}
