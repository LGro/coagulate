// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../data/models/coag_contact.dart';
import '../../data/models/contact_location.dart';
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

  Future<void> updateDetails(ContactDetails details) async =>
      (state.profileInfo == null)
          ? null
          : contactsRepository
              .setProfileInfo(state.profileInfo!.copyWith(details: details));

  Future<void> updateAddressLocations(
          Map<int, ContactAddressLocation> addressLocations) async =>
      (state.profileInfo == null)
          ? null
          : contactsRepository.setProfileInfo(
              state.profileInfo!.copyWith(addressLocations: addressLocations));

  Future<void> updateAvatar(String circleId, Uint8List picture) async {
    if (state.profileInfo == null) {
      return;
    }

    final pictures = {...state.profileInfo!.pictures};
    pictures[circleId] = picture;

    await contactsRepository
        .setProfileInfo(state.profileInfo!.copyWith(pictures: pictures));
  }

  Future<void> removeAvatar(String circleId) async {
    if (state.profileInfo == null) {
      return;
    }

    final pictures = {...state.profileInfo!.pictures}..remove(circleId);
    await contactsRepository
        .setProfileInfo(state.profileInfo!.copyWith(pictures: pictures));
  }

  Future<void> updateName(String id, String name,
      List<(String, String, bool)> circlesWithSelection) async {
    if (state.profileInfo == null) {
      return;
    }

    final names = {...state.profileInfo!.details.names};
    names[id] = name;

    await createCirclesIfNotExist(
        circlesWithSelection.map((e) => (e.$1, e.$2)).toList());

    final _sharingSettings = {...state.profileInfo!.sharingSettings.names};
    _sharingSettings[id] =
        circlesWithSelection.where((e) => e.$3).map((c) => c.$1).toList();

    final updatedProfile = state.profileInfo!.copyWith(
      details: state.profileInfo!.details.copyWith(
        names: names,
      ),
      sharingSettings: state.profileInfo!.sharingSettings.copyWith(
        names: _sharingSettings,
      ),
    );
    if (!isClosed) {
      emit(state.copyWith(profileInfo: updatedProfile));
    }
    await contactsRepository.setProfileInfo(updatedProfile);
  }

  Future<void> updatePhone(String label, String value,
      List<(String, String, bool)> circlesWithSelection,
      {int? i}) async {
    if (state.profileInfo == null) {
      return;
    }

    final details = {...state.profileInfo!.details.phones};
    details[label] = value;

    await createCirclesIfNotExist(
        circlesWithSelection.map((e) => (e.$1, e.$2)).toList());

    final _sharingSettings = {...state.profileInfo!.sharingSettings.phones};
    _sharingSettings[label] =
        circlesWithSelection.where((e) => e.$3).map((c) => c.$1).toList();

    final updatedProfile = state.profileInfo!.copyWith(
      details: state.profileInfo!.details.copyWith(
        phones: details,
      ),
      sharingSettings: state.profileInfo!.sharingSettings.copyWith(
        phones: _sharingSettings,
      ),
    );
    if (!isClosed) {
      emit(state.copyWith(profileInfo: updatedProfile));
    }
    await contactsRepository.setProfileInfo(updatedProfile);
  }

  Future<void> updateEmail(String label, String value,
      List<(String, String, bool)> circlesWithSelection,
      {int? i}) async {
    if (state.profileInfo == null) {
      return;
    }

    final details = {...state.profileInfo!.details.emails};
    details[label] = value;

    await createCirclesIfNotExist(
        circlesWithSelection.map((e) => (e.$1, e.$2)).toList());

    final _sharingSettings = {...state.profileInfo!.sharingSettings.emails};
    _sharingSettings[label] =
        circlesWithSelection.where((e) => e.$3).map((c) => c.$1).toList();

    final updatedProfile = state.profileInfo!.copyWith(
      details: state.profileInfo!.details.copyWith(
        emails: details,
      ),
      sharingSettings: state.profileInfo!.sharingSettings.copyWith(
        emails: _sharingSettings,
      ),
    );
    if (!isClosed) {
      emit(state.copyWith(profileInfo: updatedProfile));
    }
    await contactsRepository.setProfileInfo(updatedProfile);
  }

  Future<void> updateSocialMedia(String label, String value,
      List<(String, String, bool)> circlesWithSelection,
      {int? i}) async {
    if (state.profileInfo == null) {
      return;
    }

    final details = {...state.profileInfo!.details.socialMedias};
    details[label] = value;

    await createCirclesIfNotExist(
        circlesWithSelection.map((e) => (e.$1, e.$2)).toList());

    final _sharingSettings = {
      ...state.profileInfo!.sharingSettings.socialMedias
    };
    _sharingSettings[label] =
        circlesWithSelection.where((e) => e.$3).map((c) => c.$1).toList();

    final updatedProfile = state.profileInfo!.copyWith(
      details: state.profileInfo!.details.copyWith(
        socialMedias: details,
      ),
      sharingSettings: state.profileInfo!.sharingSettings.copyWith(
        socialMedias: _sharingSettings,
      ),
    );
    if (!isClosed) {
      emit(state.copyWith(profileInfo: updatedProfile));
    }
    await contactsRepository.setProfileInfo(updatedProfile);
  }

  Future<void> updateWebsite(String label, String value,
      List<(String, String, bool)> circlesWithSelection) async {
    if (state.profileInfo == null) {
      return;
    }

    final details = {...state.profileInfo!.details.websites};
    details[label] = value;

    await createCirclesIfNotExist(
        circlesWithSelection.map((e) => (e.$1, e.$2)).toList());

    final _sharingSettings = {...state.profileInfo!.sharingSettings.websites};
    _sharingSettings[label] =
        circlesWithSelection.where((e) => e.$3).map((c) => c.$1).toList();

    final updatedProfile = state.profileInfo!.copyWith(
      details: state.profileInfo!.details.copyWith(
        websites: details,
      ),
      sharingSettings: state.profileInfo!.sharingSettings.copyWith(
        websites: _sharingSettings,
      ),
    );
    if (!isClosed) {
      emit(state.copyWith(profileInfo: updatedProfile));
    }
    await contactsRepository.setProfileInfo(updatedProfile);
  }

  Future<void> updateAddressLocation(
      int index,
      ContactAddressLocation contactAddress,
      List<(String, String, bool)> circlesWithSelection) async {
    if (state.profileInfo == null) {
      return;
    }

    await createCirclesIfNotExist(
        circlesWithSelection.map((e) => (e.$1, e.$2)).toList());

    final _sharingSettings = {...state.profileInfo!.sharingSettings.addresses};
    _sharingSettings[contactAddress.name] =
        circlesWithSelection.where((e) => e.$3).map((c) => c.$1).toList();

    final _updatedAddressLocations = {...state.profileInfo!.addressLocations};
    _updatedAddressLocations[index] = contactAddress;

    final updatedProfile = state.profileInfo!.copyWith(
      sharingSettings: state.profileInfo!.sharingSettings.copyWith(
        addresses: _sharingSettings,
      ),
      addressLocations: _updatedAddressLocations,
    );
    if (!isClosed) {
      emit(state.copyWith(profileInfo: updatedProfile));
    }
    await contactsRepository.setProfileInfo(updatedProfile);
  }

  @override
  Future<void> close() {
    _profileInfoSubscription.cancel();
    _circlesSubscription.cancel();
    _permissionsSubscription.cancel();
    return super.close();
  }
}
