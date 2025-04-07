// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../data/models/coag_contact.dart';
import '../../data/models/contact_location.dart';
import '../../data/repositories/contacts.dart';

part 'cubit.g.dart';
part 'state.dart';

// For search, nominatim.openstreetmap.org allows basic use for free
// we could host our own if needed
// GET https://nominatim.openstreetmap.org/search?format=json&q=<search query>

class OsmLocation {
  OsmLocation(
      {required this.lat, required this.lon, required this.displayName});

  factory OsmLocation.fromJson(Map<String, dynamic> json) => OsmLocation(
        lat: double.parse(json['lat'] as String),
        lon: double.parse(json['lon'] as String),
        displayName: json['display_name'] as String,
      );

  final double lat;
  final double lon;
  final String displayName;
}

Future<List<OsmLocation>> fetchOsmLocations(String query) async {
  final url = Uri(
      scheme: 'https',
      host: 'nominatim.openstreetmap.org',
      path: '/search',
      queryParameters: {'format': 'json', 'q': query});

  // TODO: Add current app version instead of testing
  final response = await http
      .get(url, headers: {'User-Agent': 'social.coagulate.app / testing'});

  // TODO: Handle decoding errors
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body) as List<Map<String, dynamic>>;
    return data.map(OsmLocation.fromJson).toList();
  } else {
    throw Exception('Failed to load locations');
  }
}

Iterable<Location> addressLocationsToLocations(
        Iterable<ContactAddressLocation> addressLocations,
        String label,
        String? coagContactId,
        List<int>? picture) =>
    addressLocations.map((l) => Location(
        coagContactId: coagContactId,
        longitude: l.longitude,
        latitude: l.latitude,
        label: label,
        subLabel: l.name,
        details: '',
        picture: picture,
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
        details: l.details,
        picture: picture,
        start: l.start,
        end: l.end,
        marker: MarkerType.temporary);

class MapCubit extends Cubit<MapState> {
  MapCubit(this.contactsRepository)
      : super(const MapState([], MapStatus.initial)) {
    _profileInfoSubscription =
        contactsRepository.getProfileInfoStream().listen((_) => refresh());
    _contactsSubscription =
        contactsRepository.getContactStream().listen((coagContactId) {
      final contact = contactsRepository.getContact(coagContactId);
      if (contact == null) {
        return;
      }
      // TODO: Just refresh() instead?
      emit(MapState([
        ...state.locations.where((l) => l.coagContactId != coagContactId),
        ...addressLocationsToLocations(contact.addressLocations.values,
            contact.name, contact.coagContactId, contact.details?.picture),
        ...filterTemporaryLocations(contact.temporaryLocations).entries.map(
            (l) => temporaryLocationToLocation(contact.name, l.value,
                coagContactId: contact.coagContactId,
                locationId: l.key,
                picture: contact.details?.picture))
      ], MapStatus.success));
    });

    refresh();
  }

  final ContactsRepository contactsRepository;
  late final StreamSubscription<String> _contactsSubscription;
  late final StreamSubscription<ProfileInfo> _profileInfoSubscription;

  void refresh() {
    final profileInfo = contactsRepository.getProfileInfo();
    final contacts = contactsRepository.getContacts().values.toList();

    emit(MapState([
      // TODO: Localize "me"
      ...addressLocationsToLocations(
          profileInfo?.addressLocations.values ?? [], 'Me', null, null),
      ...filterTemporaryLocations(profileInfo?.temporaryLocations ?? {})
          .entries
          .map((l) => temporaryLocationToLocation('Me', l.value,
              locationId: l.key,
              picture: profileInfo?.pictures.values.firstOrNull)),
      ...contacts
          .map((c) => [
                ...addressLocationsToLocations(c.addressLocations.values,
                    c.name, c.coagContactId, c.details?.picture),
                ...filterTemporaryLocations(c.temporaryLocations).entries.map(
                    (l) => temporaryLocationToLocation(c.name, l.value,
                        coagContactId: c.coagContactId,
                        locationId: l.key,
                        picture: c.details?.picture))
              ])
          .flattened
    ], MapStatus.success));
  }

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
    _contactsSubscription.cancel();
    _profileInfoSubscription.cancel();
    return super.close();
  }
}
