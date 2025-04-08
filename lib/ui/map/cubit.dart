// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';

import '../../data/models/coag_contact.dart';
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

class MapCubit extends Cubit<MapState> {
  MapCubit(this.contactsRepository)
      : super(const MapState(status: MapStatus.initial)) {
    _profileInfoSubscription =
        contactsRepository.getProfileInfoStream().listen((_) => refresh());
    _circlesSubscription =
        contactsRepository.getCirclesStream().listen((_) => refresh());
    // TODO: Does it help the performance significantly to only update the affected contact's data?
    _contactsSubscription = contactsRepository
        .getContactStream()
        .listen((coagContactId) => refresh());

    refresh();
  }

  final ContactsRepository contactsRepository;
  late final StreamSubscription<void> _circlesSubscription;
  late final StreamSubscription<String> _contactsSubscription;
  late final StreamSubscription<ProfileInfo> _profileInfoSubscription;

  void refresh() {
    final profileInfo = contactsRepository.getProfileInfo();
    final circleMemberships = contactsRepository.getCircleMemberships();
    final circles = contactsRepository.getCircles();
    final contacts = contactsRepository.getContacts().values;

    emit(MapState(
        status: MapStatus.success,
        profileInfo: profileInfo,
        contacts: contacts.toList(),
        circleMemberships: circleMemberships,
        circles: circles));
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
    _circlesSubscription.cancel();
    _contactsSubscription.cancel();
    _profileInfoSubscription.cancel();
    return super.close();
  }
}
