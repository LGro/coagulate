// Copyright 2024 Lukas Grossberger
import 'package:equatable/equatable.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';

part 'profile_contact_cubit.g.dart';
part 'profile_contact_state.dart';

// TODO: Add contact refresh as listener via
//       FlutterContacts.addListener(() => print('Contact DB changed'));

class ProfileContactCubit extends HydratedCubit<ProfileContactState> {
  ProfileContactCubit() : super(ProfileContactState());

  void promptCreate() {
    emit(state.copyWith(status: ProfileContactStatus.create));
  }

  void promptPick() {
    emit(state.copyWith(status: ProfileContactStatus.pick));
  }

  void setContact(Contact? contact) {
    emit(state.copyWith(
        status: (contact == null)
            ? ProfileContactStatus.initial
            : ProfileContactStatus.success,
        profileContact: contact));
  }

  Future<void> updateContact() async {
    if (state.profileContact != null) {
      setContact(await FlutterContacts.getContact(state.profileContact!.id));
    }
  }

  @override
  ProfileContactState fromJson(Map<String, dynamic> json) =>
      ProfileContactState.fromJson(json);

  @override
  Map<String, dynamic> toJson(ProfileContactState state) => state.toJson();

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
}
