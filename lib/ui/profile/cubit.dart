// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:geocoding/geocoding.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../data/models/coag_contact.dart';
import '../../data/models/contact_location.dart';
import '../../data/repositories/contacts.dart';

part 'cubit.g.dart';
part 'state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this.contactsRepository) : super(const ProfileState()) {
    _contactsSubscription =
        contactsRepository.getContactUpdates().listen((contact) {
      if (contact.coagContactId == contactsRepository.profileContactId) {
        emit(state.copyWith(
            status: ProfileStatus.success, profileContact: contact));
      }
    });
    // TODO: Does only doing this here and not in the parent constructor call above cause flicker?
    if (contactsRepository.profileContactId != null) {
      emit(state.copyWith(
          status: ProfileStatus.success,
          profileContact: contactsRepository
              .getContact(contactsRepository.profileContactId!)));
    }
    // TODO: Check current state of permissions here in addition to listening to stream update
    _permissionsSubscription = contactsRepository
        .isSystemContactAccessGranted()
        .listen(
            (isGranted) => emit(state.copyWith(permissionsGranted: isGranted)));
  }

  final ContactsRepository contactsRepository;
  late final StreamSubscription<CoagContact> _contactsSubscription;
  late final StreamSubscription<bool> _permissionsSubscription;

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
      // Reset but keep the permission status
      return emit(ProfileState(
          status: ProfileStatus.initial,
          profileContact: null,
          permissionsGranted: state.permissionsGranted));
    }

    await contactsRepository.updateProfileContact(contact.coagContactId);

    if (!isClosed) {
      emit(state.copyWith(
          status: ProfileStatus.success, profileContact: contact));
    }
  }

  Future<void> fetchCoordinates(int iAddress) async {
    final address =
        state.profileContact!.systemContact!.addresses[iAddress].address;
    // TODO: Also add some status indicator per address to show when unfetched, fetching, failed, fetched
    try {
      List<Location> locations = await locationFromAddress(address);
      // TODO: Expose options to pick from, instead of just using the first.
      final chosenLocation = locations[0];
      updateCoordinates(
          iAddress, chosenLocation.longitude, chosenLocation.latitude);
    } on NoResultFoundException catch (e) {
      // TODO: Proper error handling
      print('${e} ${address}');
    }
  }

  void updateCoordinates(int iAddress, num lng, num lat) {
    final address = state.profileContact!.systemContact!.addresses[iAddress];
    final updatedLocations = Map<int, ContactAddressLocation>.from(
        state.profileContact!.addressLocations);
    updatedLocations[iAddress] = ContactAddressLocation(
        coagContactId: state.profileContact!.coagContactId,
        longitude: lng.toDouble(),
        latitude: lat.toDouble(),
        name: (address.label == AddressLabel.custom)
            ? address.customLabel
            : address.label.name);

    final updatedContact =
        state.profileContact!.copyWith(addressLocations: updatedLocations);
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
    _contactsSubscription.cancel();
    _permissionsSubscription.cancel();
    return super.close();
  }
}
