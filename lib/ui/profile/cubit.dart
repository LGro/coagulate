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
import '../../data/models/profile_sharing_settings.dart';
import '../../data/repositories/contacts.dart';

part 'cubit.g.dart';
part 'state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this.contactsRepository) : super(const ProfileState()) {
    _contactsSubscription =
        contactsRepository.getContactStream().listen((idUpdatedContact) {
      final profileContact = contactsRepository.getProfileContact();
      if (idUpdatedContact == profileContact?.coagContactId) {
        emit(state.copyWith(
            status: ProfileStatus.success,
            profileContact: profileContact,
            circles: contactsRepository.getCircles(),
            circleMemberships: contactsRepository.getCircleMemberships(),
            sharingSettings: contactsRepository.getProfileSharingSettings()));
      }
    });
    final profileContact = contactsRepository.getProfileContact();
    if (profileContact != null) {
      emit(state.copyWith(
          status: ProfileStatus.success,
          profileContact: profileContact,
          circles: contactsRepository.getCircles(),
          circleMemberships: contactsRepository.getCircleMemberships(),
          sharingSettings: contactsRepository.getProfileSharingSettings()));
    }
    // TODO: Check current state of permissions here in addition to listening to stream update
    _permissionsSubscription = contactsRepository
        .isSystemContactAccessGranted()
        .listen(
            (isGranted) => emit(state.copyWith(permissionsGranted: isGranted)));
  }

  final ContactsRepository contactsRepository;
  late final StreamSubscription<String> _contactsSubscription;
  late final StreamSubscription<bool> _permissionsSubscription;

  Future<void> promptCreate() async {
    if (await FlutterContacts.requestPermission()) {
      emit(state.copyWith(status: ProfileStatus.create));
      final newContactId = (await FlutterContacts.openExternalInsert())?.id;
      if (newContactId != null) {
        // TODO: Can we be more targeted here, to only update the one contact id?
        await contactsRepository.updateFromSystemContacts();
      }
      await setContact(newContactId);
    }
  }

  Future<void> promptPick() async {
    if (await FlutterContacts.requestPermission()) {
      emit(state.copyWith(status: ProfileStatus.pick));
      await setContact((await FlutterContacts.openExternalPick())?.id);
    }
  }

  Future<void> setContact(String? systemContactId) async {
    final contact = (systemContactId == null)
        ? null
        : contactsRepository.getContactForSystemContactId(systemContactId);

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
          status: ProfileStatus.success,
          profileContact: contact,
          sharingSettings: contactsRepository.getProfileSharingSettings()));
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
      // TODO: Proper error handling with corresponding error state
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
    unawaited(contactsRepository.updateProfileContactData(updatedContact).then(
        (_) => contactsRepository
            .updateProfileContact(state.profileContact!.coagContactId)));

    // Already emit what should also come in a bit later via the updated contacts repo
    emit(state.copyWith(profileContact: updatedContact));
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

  Future<void> updatePhoneSharingCircles(
      int index, String label, List<(String, String)> circles) async {
    await createCirclesIfNotExist(circles);
    // TODO: Trigger a cleanup of the available label/index combinations somewhere, doesn't need to be here
    final phones = Map<String, List<String>>.from(
        contactsRepository.getProfileSharingSettings().phones);
    phones['$index|$label'] = circles.map((c) => c.$1).toList();
    final updatedSharingSettings =
        contactsRepository.getProfileSharingSettings().copyWith(phones: phones);
    await contactsRepository.setProfileSharingSettings(updatedSharingSettings);
    // TODO: Handle via update subscription instead of updating the state ourselves here?
    emit(state.copyWith(sharingSettings: updatedSharingSettings));
  }

  Future<void> updateEmailSharingCircles(
      int index, String label, List<(String, String)> circles) async {
    await createCirclesIfNotExist(circles);
    // TODO: Trigger a cleanup of the available label/index combinations somewhere, doesn't need to be here
    final emails = Map<String, List<String>>.from(
        contactsRepository.getProfileSharingSettings().emails);
    emails['$index|$label'] = circles.map((c) => c.$1).toList();
    final updatedSharingSettings =
        contactsRepository.getProfileSharingSettings().copyWith(emails: emails);
    await contactsRepository.setProfileSharingSettings(updatedSharingSettings);
    // TODO: Handle via update subscription instead of updating the state ourselves here?
    emit(state.copyWith(sharingSettings: updatedSharingSettings));
  }

  Future<void> updateAddressSharingCircles(
      int index, String label, List<(String, String)> circles) async {
    await createCirclesIfNotExist(circles);
    // TODO: Trigger a cleanup of the available label/index combinations somewhere, doesn't need to be here
    final addresses = Map<String, List<String>>.from(
        contactsRepository.getProfileSharingSettings().addresses);
    addresses['$index|$label'] = circles.map((c) => c.$1).toList();
    final updatedSharingSettings = contactsRepository
        .getProfileSharingSettings()
        .copyWith(addresses: addresses);
    await contactsRepository.setProfileSharingSettings(updatedSharingSettings);
    // TODO: Handle via update subscription instead of updating the state ourselves here?
    emit(state.copyWith(sharingSettings: updatedSharingSettings));
  }

  Future<void> updateOrganizationSharingCircles(
      int index, String label, List<(String, String)> circles) async {
    await createCirclesIfNotExist(circles);
    // TODO: Trigger a cleanup of the available label/index combinations somewhere, doesn't need to be here
    final organizations = Map<String, List<String>>.from(
        contactsRepository.getProfileSharingSettings().organizations);
    organizations['$index|$label'] = circles.map((c) => c.$1).toList();
    final updatedSharingSettings = contactsRepository
        .getProfileSharingSettings()
        .copyWith(organizations: organizations);
    await contactsRepository.setProfileSharingSettings(updatedSharingSettings);
    // TODO: Handle via update subscription instead of updating the state ourselves here?
    emit(state.copyWith(sharingSettings: updatedSharingSettings));
  }

  Future<void> updateWebsiteSharingCircles(
      int index, String label, List<(String, String)> circles) async {
    await createCirclesIfNotExist(circles);
    // TODO: Trigger a cleanup of the available label/index combinations somewhere, doesn't need to be here
    final websites = Map<String, List<String>>.from(
        contactsRepository.getProfileSharingSettings().websites);
    websites['$index|$label'] = circles.map((c) => c.$1).toList();
    final updatedSharingSettings = contactsRepository
        .getProfileSharingSettings()
        .copyWith(websites: websites);
    await contactsRepository.setProfileSharingSettings(updatedSharingSettings);
    // TODO: Handle via update subscription instead of updating the state ourselves here?
    emit(state.copyWith(sharingSettings: updatedSharingSettings));
  }

  Future<void> updateSocialMediaSharingCircles(
      int index, String label, List<(String, String)> circles) async {
    await createCirclesIfNotExist(circles);
    // TODO: Trigger a cleanup of the available label/index combinations somewhere, doesn't need to be here
    final socialMedias = Map<String, List<String>>.from(
        contactsRepository.getProfileSharingSettings().socialMedias);
    socialMedias['$index|$label'] = circles.map((c) => c.$1).toList();
    final updatedSharingSettings = contactsRepository
        .getProfileSharingSettings()
        .copyWith(socialMedias: socialMedias);
    await contactsRepository.setProfileSharingSettings(updatedSharingSettings);
    // TODO: Handle via update subscription instead of updating the state ourselves here?
    emit(state.copyWith(sharingSettings: updatedSharingSettings));
  }

  Future<void> updateEventSharingCircles(
      int index, String label, List<(String, String)> circles) async {
    await createCirclesIfNotExist(circles);
    // TODO: Trigger a cleanup of the available label/index combinations somewhere, doesn't need to be here
    final events = Map<String, List<String>>.from(
        contactsRepository.getProfileSharingSettings().events);
    events['$index|$label'] = circles.map((c) => c.$1).toList();
    final updatedSharingSettings =
        contactsRepository.getProfileSharingSettings().copyWith(events: events);
    await contactsRepository.setProfileSharingSettings(updatedSharingSettings);
    // TODO: Handle via update subscription instead of updating the state ourselves here?
    emit(state.copyWith(sharingSettings: updatedSharingSettings));
  }

  @override
  Future<void> close() {
    _contactsSubscription.cancel();
    _permissionsSubscription.cancel();
    return super.close();
  }
}
