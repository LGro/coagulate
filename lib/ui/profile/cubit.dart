// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:equatable/equatable.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cubit.g.dart';
part 'state.dart';

// TODO: Add contact refresh as listener via
//       FlutterContacts.addListener(() => print('Contact DB changed'));

class ProfileCubit extends HydratedCubit<ProfileState> {
  ProfileCubit() : super(ProfileState());

  void promptCreate() {
    emit(state.copyWith(status: ProfileStatus.create));
  }

  void promptPick() {
    emit(state.copyWith(status: ProfileStatus.pick));
  }

  void setContact(Contact? contact) {
    emit(state.copyWith(
        status:
            (contact == null) ? ProfileStatus.initial : ProfileStatus.success,
        profileContact: contact));
  }

  Future<void> updateContact() async {
    if (state.profileContact != null) {
      setContact(await FlutterContacts.getContact(state.profileContact!.id));
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
}
