// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../data/repositories/contacts.dart';
import '../../data/models/coag_contact.dart';
import '../../data/models/contact_location.dart';

part 'cubit.g.dart';
part 'state.dart';

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
    // TODO: Subscribe to
    // contactsRepository.getUpdateStatus()
    emit(MapState(
        contactsRepository.coagContacts.values
            .expand((c) => _contactToLocations(c))
            .toList(),
        MapStatus.success,
        mapboxApiToken:
            String.fromEnvironment('COAGULATE_MAPBOX_PUBLIC_TOKEN')));
  }

  final ContactsRepository contactsRepository;

  @override
  MapState fromJson(Map<String, dynamic> json) => MapState.fromJson(json);

  @override
  Map<String, dynamic> toJson(MapState state) => state.toJson();
}
