// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../data/models/coag_contact.dart';
import '../../data/repositories/contacts.dart';

part 'cubit.g.dart';
part 'state.dart';

Iterable<Location> contactToLocations(CoagContact contact) =>
    contact.addressLocations.values.map((l) => Location(
        coagContactId: contact.coagContactId,
        longitude: l.longitude,
        latitude: l.latitude,
        label: contact.details!.displayName,
        subLabel: l.name));

class MapCubit extends HydratedCubit<MapState> {
  MapCubit(this.contactsRepository)
      : super(const MapState({}, MapStatus.initial)) {
    _contactsSuscription =
        contactsRepository.getContactUpdates().listen((contact) {
      emit(MapState([
        ...state.locations
            .where((l) => l.coagContactId != contact.coagContactId),
        ...contactToLocations(contact)
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
