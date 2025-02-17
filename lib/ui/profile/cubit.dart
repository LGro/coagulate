// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:geocoding/geocoding.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/coag_contact.dart';
import '../../data/models/contact_location.dart';
import '../../data/models/profile_sharing_settings.dart';
import '../../data/repositories/contacts.dart';

part 'cubit.g.dart';
part 'state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this.contactsRepository)
      : super(ProfileState(profileInfo: contactsRepository.getProfileInfo())) {
    _circlesSubscription = contactsRepository.getCirclesStream().listen((_) {
      emit(state.copyWith(
          circles: contactsRepository.getCircles(),
          circleMemberships: contactsRepository.getCircleMemberships()));
    });
    _profileInfoSubscription =
        contactsRepository.getProfileInfoStream().listen((profileInfo) {
      emit(state.copyWith(
          status: ProfileStatus.success,
          profileInfo: profileInfo,
          circles: contactsRepository.getCircles(),
          circleMemberships: contactsRepository.getCircleMemberships()));
    });
    final profileInfo = contactsRepository.getProfileInfo();
    emit(state.copyWith(
      status: ProfileStatus.success,
      profileInfo: profileInfo,
      circles: contactsRepository.getCircles(),
      circleMemberships: contactsRepository.getCircleMemberships(),
    ));

    // TODO: Check current state of permissions here in addition to listening to stream update
    _permissionsSubscription = contactsRepository
        .isSystemContactAccessGranted()
        .listen(
            (isGranted) => emit(state.copyWith(permissionsGranted: isGranted)));
  }

  final ContactsRepository contactsRepository;
  late final StreamSubscription<ProfileInfo> _profileInfoSubscription;
  late final StreamSubscription<bool> _permissionsSubscription;
  late final StreamSubscription<void> _circlesSubscription;

  Future<void> fetchCoordinates(int iAddress) async {
    final address =
        state.profileInfo.details.addresses.elementAtOrNull(iAddress)?.address;

    if (address == null) {
      return;
    }

    // TODO: Also add some status indicator per address to show when unfetched, fetching, failed, fetched
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isEmpty) {
        return;
      }
      // TODO: Expose options to pick from, instead of just using the first.
      final chosenLocation = locations[0];
      updateCoordinates(
          iAddress, chosenLocation.longitude, chosenLocation.latitude);
    } on NoResultFoundException catch (e) {
      // TODO: Proper error handling with corresponding error state
      print('${e} ${address}');
    }
  }

  void updateCoordinates(int iAddress, num lng, num lat) {
    final address =
        state.profileInfo.details.addresses.elementAtOrNull(iAddress);

    if (address == null) {
      return;
    }

    final updatedLocations = Map<int, ContactAddressLocation>.from(
        state.profileInfo.addressLocations);
    updatedLocations[iAddress] = ContactAddressLocation(
        longitude: lng.toDouble(),
        latitude: lat.toDouble(),
        name: (address.label == AddressLabel.custom)
            ? address.customLabel
            : address.label.name);

    final updatedInfo =
        state.profileInfo.copyWith(addressLocations: updatedLocations);

    unawaited(contactsRepository.setProfileInfo(updatedInfo));

    // Already emit what should also come in a bit later via the updated contacts repo
    if (!isClosed) {
      emit(state.copyWith(profileInfo: updatedInfo));
    }
  }

  /// For circle ID and label pairs, add the new ones to the contacts repository
  Future<void> createCirclesIfNotExist(List<(String, String)> circles) async {
    final storedCircles = contactsRepository.getCircles();
    for (final (id, label) in circles) {
      if (!storedCircles.containsKey(id)) {
        storedCircles[id] = label;
        await contactsRepository.addCircle(id, label);
      }
    }
  }

  Future<void> updateDetails(ContactDetails details) async => contactsRepository
      .setProfileInfo(state.profileInfo.copyWith(details: details));

  // TODO: Trigger a cleanup of the available labels somewhere, doesn't need to be here
  Future<void> updateDetailSharingCircles(
      {required Map<String, List<String>> detailSharingSettings,
      required String key,
      required List<(String, String, bool)> circlesWithSelection,
      required ProfileSharingSettings Function(
              Map<String, List<String>> detailSharingSettings)
          updateSharingSettings}) async {
    final _settingsCopy = {...detailSharingSettings};
    // NOTE: Actually, we require only a list of IDs, move this to call context?
    _settingsCopy[key] =
        circlesWithSelection.where((e) => e.$3).map((c) => c.$1).toList();
    final updatedProfileInfo = state.profileInfo
        .copyWith(sharingSettings: updateSharingSettings(_settingsCopy));
    await contactsRepository.setProfileInfo(updatedProfileInfo);
    // TODO: Handle via update subscription instead of updating the state ourselves here?
    if (!isClosed) {
      emit(state.copyWith(profileInfo: updatedProfileInfo));
    }
  }

  Future<void> updateAvatar(String circleId, Uint8List picture) async {
    final pictures = {...state.profileInfo.pictures};
    pictures[circleId] = picture;

    await contactsRepository
        .setProfileInfo(state.profileInfo.copyWith(pictures: pictures));
  }

  Future<void> removeAvatar(String circleId) async {
    final pictures = {...state.profileInfo.pictures}..remove(circleId);
    await contactsRepository
        .setProfileInfo(state.profileInfo.copyWith(pictures: pictures));
  }

  Future<void> updateName(
      String name, List<(String, String, bool)> circlesWithSelection,
      {String? id}) async {
    final names = {...state.profileInfo.details.names};
    id ??= Uuid().v4();
    names[id] = name;

    await updateDetails(state.profileInfo.details.copyWith(names: names));

    await createCirclesIfNotExist(
        circlesWithSelection.map((e) => (e.$1, e.$2)).toList());

    await updateDetailSharingCircles(
        detailSharingSettings: state.profileInfo.sharingSettings.names,
        key: id,
        circlesWithSelection: circlesWithSelection,
        updateSharingSettings: (settings) =>
            state.profileInfo.sharingSettings.copyWith(names: settings));
  }

  Future<void> updatePhone(
      Phone detail, List<(String, String, bool)> circlesWithSelection,
      {int? i}) async {
    final details = [...state.profileInfo.details.phones];
    if (i == null) {
      i = details.length;
      details.add(detail);
    } else {
      details[i] = detail;
    }

    await updateDetails(state.profileInfo.details.copyWith(phones: details));

    await createCirclesIfNotExist(
        circlesWithSelection.map((e) => (e.$1, e.$2)).toList());

    await updateDetailSharingCircles(
        detailSharingSettings: state.profileInfo.sharingSettings.phones,
        key: (detail.label.name != 'custom')
            ? detail.label.name
            : detail.customLabel,
        circlesWithSelection: circlesWithSelection,
        updateSharingSettings: (settings) =>
            state.profileInfo.sharingSettings.copyWith(phones: settings));
  }

  Future<void> updateEmail(
      Email detail, List<(String, String, bool)> circlesWithSelection,
      {int? i}) async {
    final details = [...state.profileInfo.details.emails];
    if (i == null) {
      i = details.length;
      details.add(detail);
    } else {
      details[i] = detail;
    }

    await updateDetails(state.profileInfo.details.copyWith(emails: details));

    await createCirclesIfNotExist(
        circlesWithSelection.map((e) => (e.$1, e.$2)).toList());

    await updateDetailSharingCircles(
        detailSharingSettings: state.profileInfo.sharingSettings.emails,
        key: (detail.label.name != 'custom')
            ? detail.label.name
            : detail.customLabel,
        circlesWithSelection: circlesWithSelection,
        updateSharingSettings: (settings) =>
            state.profileInfo.sharingSettings.copyWith(emails: settings));
  }

  Future<void> updateSocialMedia(
      SocialMedia detail, List<(String, String, bool)> circlesWithSelection,
      {int? i}) async {
    final details = [...state.profileInfo.details.socialMedias];
    if (i == null) {
      i = details.length;
      details.add(detail);
    } else {
      details[i] = detail;
    }

    await updateDetails(
        state.profileInfo.details.copyWith(socialMedias: details));

    await createCirclesIfNotExist(
        circlesWithSelection.map((e) => (e.$1, e.$2)).toList());

    await updateDetailSharingCircles(
        detailSharingSettings: state.profileInfo.sharingSettings.socialMedias,
        key: (detail.label.name != 'custom')
            ? detail.label.name
            : detail.customLabel,
        circlesWithSelection: circlesWithSelection,
        updateSharingSettings: (settings) =>
            state.profileInfo.sharingSettings.copyWith(socialMedias: settings));
  }

  Future<void> updateWebsite(
      Website detail, List<(String, String, bool)> circlesWithSelection,
      {int? i}) async {
    final details = [...state.profileInfo.details.websites];
    if (i == null) {
      i = details.length;
      details.add(detail);
    } else {
      details[i] = detail;
    }

    await updateDetails(state.profileInfo.details.copyWith(websites: details));

    await createCirclesIfNotExist(
        circlesWithSelection.map((e) => (e.$1, e.$2)).toList());

    await updateDetailSharingCircles(
        detailSharingSettings: state.profileInfo.sharingSettings.websites,
        key: (detail.label.name != 'custom')
            ? detail.label.name
            : detail.customLabel,
        circlesWithSelection: circlesWithSelection,
        updateSharingSettings: (settings) =>
            state.profileInfo.sharingSettings.copyWith(websites: settings));
  }

  Future<void> updateAddress(
      Address detail, List<(String, String, bool)> circlesWithSelection,
      {int? i}) async {
    final details = [...state.profileInfo.details.addresses];
    if (i == null) {
      i = details.length;
      details.add(detail);
    } else {
      details[i] = detail;
    }

    await updateDetails(state.profileInfo.details.copyWith(addresses: details));

    await createCirclesIfNotExist(
        circlesWithSelection.map((e) => (e.$1, e.$2)).toList());

    await updateDetailSharingCircles(
        detailSharingSettings: state.profileInfo.sharingSettings.addresses,
        key: (detail.label.name != 'custom')
            ? detail.label.name
            : detail.customLabel,
        circlesWithSelection: circlesWithSelection,
        updateSharingSettings: (settings) =>
            state.profileInfo.sharingSettings.copyWith(addresses: settings));
  }

  @override
  Future<void> close() {
    _profileInfoSubscription.cancel();
    _circlesSubscription.cancel();
    _permissionsSubscription.cancel();
    return super.close();
  }
}
