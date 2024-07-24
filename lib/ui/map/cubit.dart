// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../data/models/coag_contact.dart';
import '../../data/models/contact_location.dart';
import '../../data/repositories/contacts.dart';

part 'cubit.g.dart';
part 'state.dart';

Iterable<Location> contactToLocations(CoagContact contact) =>
    contact.addressLocations.values.map((l) => Location(
        coagContactId: contact.coagContactId,
        longitude: l.longitude,
        latitude: l.latitude,
        label:
            contact.details?.displayName ?? contact.systemContact!.displayName,
        subLabel: l.name,
        details: '',
        marker: MarkerType.address));

Location temporaryLocationToLocation(
        CoagContact contact, ContactTemporaryLocation l) =>
    Location(
        coagContactId: contact.coagContactId,
        label: contact.details?.displayName ??
            contact.systemContact?.displayName ??
            'unknown',
        subLabel: l.name,
        longitude: l.longitude,
        latitude: l.latitude,
        details: '${l.start} - ${l.end}\nDetails: ${l.details}',
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
        ...contactToLocations(contact),
        ...contact.temporaryLocations
            .where((l) => l.end.isAfter(DateTime.now()))
            .map((l) => temporaryLocationToLocation(contact, l))
      ], MapStatus.success,
          mapboxApiToken:
              String.fromEnvironment('COAGULATE_MAPBOX_PUBLIC_TOKEN')));
    });

    emit(MapState(
        contactsRepository
            .getContacts()
            .values
            .map((c) => [
                  ...contactToLocations(c),
                  ...c.temporaryLocations
                      .where((l) => l.end.isAfter(DateTime.now()))
                      .map((l) => temporaryLocationToLocation(c, l))
                ])
            .flattened,
        MapStatus.success));
  }

  final ContactsRepository contactsRepository;
  late final StreamSubscription<String> _contactsSuscription;

  @override
  Future<void> close() {
    _contactsSuscription.cancel();
    return super.close();
  }
}
