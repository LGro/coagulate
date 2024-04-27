// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../data/models/coag_contact.dart';
import '../../data/models/contact_location.dart';
import '../../data/repositories/contacts.dart';

part 'cubit.g.dart';
part 'state.dart';

class ProfileCubit extends HydratedCubit<ProfileState> {
  ProfileCubit(this.contactsRepository) : super(const ProfileState()) {
    _contactsSuscription =
        contactsRepository.getContactUpdates().listen((contact) {
      if (state.profileContact != null &&
          contact.coagContactId == state.profileContact!.coagContactId) {
        emit(ProfileState(
            status: ProfileStatus.success, profileContact: contact));
      }
    });
  }

  final ContactsRepository contactsRepository;
  late final StreamSubscription<CoagContact> _contactsSuscription;

  void promptCreate() {
    emit(state.copyWith(status: ProfileStatus.create));
  }

  void promptPick() {
    emit(state.copyWith(status: ProfileStatus.pick));
  }

  Future<void> setContact(String? systemContactId) async {
    final contact = (systemContactId == null)
        ? null
        : contactsRepository.getCoagContactForSystemContactId(systemContactId);

    if (contact == null) {
      return emit(const ProfileState(status: ProfileStatus.initial));
    }

    await contactsRepository.updateProfileContact(contact.coagContactId);
    emit(
        state.copyWith(status: ProfileStatus.success, profileContact: contact));
  }

  @override
  ProfileState fromJson(Map<String, dynamic> json) =>
      ProfileState.fromJson(json);

  @override
  Map<String, dynamic> toJson(ProfileState state) => state.toJson();

  // TODO: Switch to address index instead of labelName
  Future<void> fetchCoordinates(String labelName) async {
    String? address;
    for (final a in state.profileContact!.systemContact!.addresses) {
      if (a.label.name == labelName) {
        address = a.address;
        break;
      }
    }
    // TODO: Also add some status indicator per address to show when unfetched, fetching, failed, fetched
    if (address == null) {
      // TODO: log / emit failure status, this shouldn't happen
      return;
    }
    try {
      List<Location> locations = await locationFromAddress(address);
      // TODO: Expose options to pick from, instead of just using the first.
      final chosenLocation = locations[0];
      updateCoordinates(
          labelName, chosenLocation.longitude, chosenLocation.latitude);
    } on NoResultFoundException catch (e) {
      // TODO: Proper error handling
      print('${e} ${address}');
    }
  }

  void updateCoordinates(String name, num lng, num lat) {
    final newLocation = AddressLocation(
        coagContactId: state.profileContact!.coagContactId,
        longitude: lng.toDouble(),
        latitude: lat.toDouble(),
        name: name);
    // If location name exists, update
    var updatedLocations = state.profileContact!.locations
        .map((l) => (l is AddressLocation && l.name == name) ? newLocation : l);
    // Otherwise, add new
    if (updatedLocations.isEmpty ||
        updatedLocations.toList() == state.profileContact!.locations.toList()) {
      updatedLocations = [...updatedLocations, newLocation];
    }

    final updatedContact =
        state.profileContact!.copyWith(locations: updatedLocations.toList());
    // TODO: Can we ensure somehow that we don't need to remember doing both steps but just push the update to the profile contact?
    // Also, ensure that the profile contact update really only happens after updateContact finished
    unawaited(contactsRepository.updateContact(updatedContact).then((_) =>
        contactsRepository
            .updateProfileContact(state.profileContact!.coagContactId)));

    // Already emit what should also come in a bit later via the updated contacts repo
    emit(state.copyWith(profileContact: updatedContact));
  }

  @override
  Future<void> close() {
    _contactsSuscription.cancel();
    return super.close();
  }
}
