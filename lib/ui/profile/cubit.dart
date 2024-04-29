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
    _contactsSubscription =
        contactsRepository.getContactUpdates().listen((contact) {
      if (state.profileContact != null &&
          contact.coagContactId == state.profileContact!.coagContactId) {
        emit(state.copyWith(
            status: ProfileStatus.success, profileContact: contact));
      }
    });
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
  Future<void> fetchCoordinates(int iAddress, String labelName) async {
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
      updateCoordinates(iAddress, labelName, chosenLocation.longitude,
          chosenLocation.latitude);
    } on NoResultFoundException catch (e) {
      // TODO: Proper error handling
      print('${e} ${address}');
    }
  }

  void updateCoordinates(int iAddress, String name, num lng, num lat) {
    final updatedLocations = state.profileContact!.addressLocations;
    updatedLocations[iAddress] = ContactAddressLocation(
        coagContactId: state.profileContact!.coagContactId,
        longitude: lng.toDouble(),
        latitude: lat.toDouble(),
        name: name);

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
