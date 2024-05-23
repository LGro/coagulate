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
        contactsRepository.getContactUpdates().listen((contact) {
      if (contact.coagContactId == contactsRepository.profileContactId) {
        emit(state.copyWith(
            status: ProfileStatus.success,
            profileContact: contact,
            circles: contactsRepository.getCircles(),
            sharingSettings: contactsRepository.getProfileSharingSettings()));
      }
    });
    // TODO: Does only doing this here and not in the parent constructor call above cause flicker?
    final profileContact = contactsRepository.getProfileContact();
    if (profileContact != null) {
      emit(state.copyWith(
          status: ProfileStatus.success,
          profileContact: profileContact,
          circles: contactsRepository.getCircles(),
          sharingSettings: contactsRepository.getProfileSharingSettings()));
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

  Future<void> promptCreate() async {
    if (await FlutterContacts.requestPermission()) {
      emit(state.copyWith(status: ProfileStatus.create));
      final newContactId = (await FlutterContacts.openExternalInsert())?.id;
      if (newContactId != null) {
        // TODO: Can we be more trageted here, to only update the one contact id?
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

  void updatePhoneSharingCircles(
      int index, String label, List<String> circles) {
    // TODO: Trigger a cleanup of the available label/index combinations somewhere, doesn't need to be here
    final phones = Map<String, List<String>>.from(
        contactsRepository.getProfileSharingSettings().phones);
    phones['$index|$label'] = circles;
    final updatedSharingSettings =
        contactsRepository.getProfileSharingSettings().copyWith(phones: phones);
    contactsRepository.setProfileSharingSettings(updatedSharingSettings);
    // TODO: Handle via update subscription instead of updating the state ourselves here?
    emit(state.copyWith(sharingSettings: updatedSharingSettings));
  }

  void updateEmailSharingCircles(
      int index, String label, List<String> circles) {
    // TODO: Trigger a cleanup of the available label/index combinations somewhere, doesn't need to be here
    final emails = Map<String, List<String>>.from(
        contactsRepository.getProfileSharingSettings().emails);
    emails['$index|$label'] = circles;
    final updatedSharingSettings =
        contactsRepository.getProfileSharingSettings().copyWith(emails: emails);
    contactsRepository.setProfileSharingSettings(updatedSharingSettings);
    // TODO: Handle via update subscription instead of updating the state ourselves here?
    emit(state.copyWith(sharingSettings: updatedSharingSettings));
  }

  void updateAddressSharingCircles(
      int index, String label, List<String> circles) {
    // TODO: Trigger a cleanup of the available label/index combinations somewhere, doesn't need to be here
    final addresses = Map<String, List<String>>.from(
        contactsRepository.getProfileSharingSettings().addresses);
    addresses['$index|$label'] = circles;
    final updatedSharingSettings = contactsRepository
        .getProfileSharingSettings()
        .copyWith(addresses: addresses);
    contactsRepository.setProfileSharingSettings(updatedSharingSettings);
    // TODO: Handle via update subscription instead of updating the state ourselves here?
    emit(state.copyWith(sharingSettings: updatedSharingSettings));
  }

  void updateOrganizationSharingCircles(
      int index, String label, List<String> circles) {
    // TODO: Trigger a cleanup of the available label/index combinations somewhere, doesn't need to be here
    final organizations = Map<String, List<String>>.from(
        contactsRepository.getProfileSharingSettings().organizations);
    organizations['$index|$label'] = circles;
    final updatedSharingSettings = contactsRepository
        .getProfileSharingSettings()
        .copyWith(organizations: organizations);
    contactsRepository.setProfileSharingSettings(updatedSharingSettings);
    // TODO: Handle via update subscription instead of updating the state ourselves here?
    emit(state.copyWith(sharingSettings: updatedSharingSettings));
  }

  void updateWebsiteSharingCircles(
      int index, String label, List<String> circles) {
    // TODO: Trigger a cleanup of the available label/index combinations somewhere, doesn't need to be here
    final websites = Map<String, List<String>>.from(
        contactsRepository.getProfileSharingSettings().websites);
    websites['$index|$label'] = circles;
    final updatedSharingSettings = contactsRepository
        .getProfileSharingSettings()
        .copyWith(websites: websites);
    contactsRepository.setProfileSharingSettings(updatedSharingSettings);
    // TODO: Handle via update subscription instead of updating the state ourselves here?
    emit(state.copyWith(sharingSettings: updatedSharingSettings));
  }

  void updateSocialMediaSharingCircles(
      int index, String label, List<String> circles) {
    // TODO: Trigger a cleanup of the available label/index combinations somewhere, doesn't need to be here
    final socialMedias = Map<String, List<String>>.from(
        contactsRepository.getProfileSharingSettings().socialMedias);
    socialMedias['$index|$label'] = circles;
    final updatedSharingSettings = contactsRepository
        .getProfileSharingSettings()
        .copyWith(socialMedias: socialMedias);
    contactsRepository.setProfileSharingSettings(updatedSharingSettings);
    // TODO: Handle via update subscription instead of updating the state ourselves here?
    emit(state.copyWith(sharingSettings: updatedSharingSettings));
  }

  void updateEventSharingCircles(
      int index, String label, List<String> circles) {
    // TODO: Trigger a cleanup of the available label/index combinations somewhere, doesn't need to be here
    final events = Map<String, List<String>>.from(
        contactsRepository.getProfileSharingSettings().events);
    events['$index|$label'] = circles;
    final updatedSharingSettings =
        contactsRepository.getProfileSharingSettings().copyWith(events: events);
    contactsRepository.setProfileSharingSettings(updatedSharingSettings);
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
