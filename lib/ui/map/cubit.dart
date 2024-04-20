// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../data/models/coag_contact.dart';
import '../../data/models/contact_location.dart';
import '../../data/repositories/contacts.dart';

part 'cubit.g.dart';
part 'state.dart';

// Just for testing purposes while no contacts share their locations
CoagContact _populateWithDummyLocations(CoagContact contact) =>
    contact.copyWith(
        locations: contact.details!.addresses
            .map((a) => AddressLocation(
                coagContactId: contact.coagContactId,
                longitude: Random().nextDouble() / 2 * 50,
                latitude: Random().nextDouble() / 2 * 50,
                name: a.label.name))
            .toList());

Iterable<Location> _contactToLocations(CoagContact contact) =>
    contact.locations.whereType<AddressLocation>().map((cl) => Location(
        coagContactId: contact.coagContactId,
        longitude: cl.longitude,
        latitude: cl.latitude,
        label: contact.details!.displayName,
        subLabel: contact.details!.addresses
            .firstWhere((a) => a.label.name == cl.name)
            .label
            .name));

class MapCubit extends HydratedCubit<MapState> {
  MapCubit(this.contactsRepository)
      : super(const MapState({}, MapStatus.initial)) {
    _contactsSuscription =
        contactsRepository.getContactUpdates().listen((contact) {
      emit(MapState([
        ...state.locations
            .where((l) => l.coagContactId != contact.coagContactId),
        ..._contactToLocations(contact)
      ], MapStatus.success,
          mapboxApiToken:
              String.fromEnvironment('COAGULATE_MAPBOX_PUBLIC_TOKEN')));
    });
  }

  final ContactsRepository contactsRepository;
  late final StreamSubscription<CoagContact> _contactsSuscription;

  @override
  MapState fromJson(Map<String, dynamic> json) => MapState.fromJson(json);

  @override
  Map<String, dynamic> toJson(MapState state) => state.toJson();

  @override
  Future<void> close() {
    _contactsSuscription.cancel();
    return super.close();
  }
}
