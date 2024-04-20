// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../data/models/coag_contact.dart';
import '../../data/repositories/contacts.dart';

part 'cubit.g.dart';
part 'state.dart';

class ProfileCubit extends HydratedCubit<ProfileState> {
  ProfileCubit(this.contactsRepository) : super(const ProfileState()) {
    _contactsSuscription =
        contactsRepository.getContactUpdates().listen((contact) {
      if (state.profileContact != null &&
          contact.systemContact?.id == state.profileContact!.id) {
        emit(ProfileState(
            status: ProfileStatus.success,
            profileContact: contact.systemContact));
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
        : await FlutterContacts.getContact(systemContactId);

    emit(state.copyWith(
        status:
            (contact == null) ? ProfileStatus.initial : ProfileStatus.success,
        profileContact: contact));

    if (contact != null) {
      // TODO: add more details, locations etc.
      await contactsRepository.updateProfileContact(
          // TODO: Switch to full blown CoagContact for profile contact and get rid of this hack
          contactsRepository.getCoagContactIdForSystemContactId(contact.id)!);
    }
  }

  @override
  ProfileState fromJson(Map<String, dynamic> json) =>
      ProfileState.fromJson(json);

  @override
  Map<String, dynamic> toJson(ProfileState state) => state.toJson();

  // TODO: Switch to address index instead of labelName
  Future<void> fetchCoordinates(String labelName) async {
    String? address;
    for (Address a in state.profileContact!.addresses) {
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
      Map<String, (num, num)> updatedLocCoords = {};
      if (state.locationCoordinates != null) {
        updatedLocCoords = state.locationCoordinates!;
      }
      updatedLocCoords[labelName] =
          (locations[0].longitude, locations[0].latitude);
      emit(state.copyWith(locationCoordinates: updatedLocCoords));
    } on NoResultFoundException catch (e) {
      // TODO: Proper error handling
      print('${e} ${address}');
    }
  }

  void updateCoordinates(String name, num lng, num lat) {
    Map<String, (num, num)> updatedLocCoords = {};
    if (state.locationCoordinates != null) {
      updatedLocCoords = state.locationCoordinates!;
    }
    updatedLocCoords[name] = (lng, lat);
    emit(state.copyWith(locationCoordinates: updatedLocCoords));
  }

  @override
  Future<void> close() {
    _contactsSuscription.cancel();
    return super.close();
  }
}
