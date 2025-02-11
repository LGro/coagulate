// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

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

  Future<void> fetchCoordinates(int iAddress) async {
    final address = state.profileContact?.details?.addresses
        .elementAtOrNull(iAddress)
        ?.address;

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
        state.profileContact?.details?.addresses.elementAtOrNull(iAddress);

    if (address == null) {
      return;
    }

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

    unawaited(contactsRepository.saveContact(updatedContact));

    // Already emit what should also come in a bit later via the updated contacts repo
    if (!isClosed) {
      emit(state.copyWith(profileContact: updatedContact));
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

  Future<void> updateNameSharingCircles(
      String nameId, List<(String, String)> circles) async {
    // TODO: Trigger a cleanup of the available label/index combinations somewhere, doesn't need to be here
    final names = {...contactsRepository.getProfileSharingSettings().names};
    names[nameId] = circles.map((c) => c.$1).toList();
    final updatedSharingSettings =
        contactsRepository.getProfileSharingSettings().copyWith(names: names);
    contactsRepository.setProfileSharingSettings(updatedSharingSettings);
    // TODO: Handle via update subscription instead of updating the state ourselves here?
    if (!isClosed) {
      emit(state.copyWith(sharingSettings: updatedSharingSettings));
    }
  }

  Future<void> updatePhoneSharingCircles(
      int index, String label, List<(String, String)> circles) async {
    // TODO: Trigger a cleanup of the available label/index combinations somewhere, doesn't need to be here
    final phones = Map<String, List<String>>.from(
        contactsRepository.getProfileSharingSettings().phones);
    phones[label] = circles.map((c) => c.$1).toList();
    final updatedSharingSettings =
        contactsRepository.getProfileSharingSettings().copyWith(phones: phones);
    contactsRepository.setProfileSharingSettings(updatedSharingSettings);
    // TODO: Handle via update subscription instead of updating the state ourselves here?
    if (!isClosed) {
      emit(state.copyWith(sharingSettings: updatedSharingSettings));
    }
  }

  Future<void> updateEmailSharingCircles(
      int index, String label, List<(String, String)> circles) async {
    // TODO: Trigger a cleanup of the available label/index combinations somewhere, doesn't need to be here
    final emails = Map<String, List<String>>.from(
        contactsRepository.getProfileSharingSettings().emails);
    emails[label] = circles.map((c) => c.$1).toList();
    final updatedSharingSettings =
        contactsRepository.getProfileSharingSettings().copyWith(emails: emails);
    contactsRepository.setProfileSharingSettings(updatedSharingSettings);
    // TODO: Handle via update subscription instead of updating the state ourselves here?
    if (!isClosed) {
      emit(state.copyWith(sharingSettings: updatedSharingSettings));
    }
  }

  Future<void> updateAddressSharingCircles(
      int index, String label, List<(String, String)> circles) async {
    // TODO: Trigger a cleanup of the available label/index combinations somewhere, doesn't need to be here
    final addresses = Map<String, List<String>>.from(
        contactsRepository.getProfileSharingSettings().addresses);
    addresses[label] = circles.map((c) => c.$1).toList();
    final updatedSharingSettings = contactsRepository
        .getProfileSharingSettings()
        .copyWith(addresses: addresses);
    contactsRepository.setProfileSharingSettings(updatedSharingSettings);
    // TODO: Handle via update subscription instead of updating the state ourselves here?
    if (!isClosed) {
      emit(state.copyWith(sharingSettings: updatedSharingSettings));
    }
  }

  Future<void> updateOrganizationSharingCircles(
      int index, String label, List<(String, String)> circles) async {
    // TODO: Trigger a cleanup of the available label/index combinations somewhere, doesn't need to be here
    final organizations = Map<String, List<String>>.from(
        contactsRepository.getProfileSharingSettings().organizations);
    organizations[label] = circles.map((c) => c.$1).toList();
    final updatedSharingSettings = contactsRepository
        .getProfileSharingSettings()
        .copyWith(organizations: organizations);
    contactsRepository.setProfileSharingSettings(updatedSharingSettings);
    // TODO: Handle via update subscription instead of updating the state ourselves here?
    if (!isClosed) {
      emit(state.copyWith(sharingSettings: updatedSharingSettings));
    }
  }

  Future<void> updateWebsiteSharingCircles(
      int index, String label, List<(String, String)> circles) async {
    // TODO: Trigger a cleanup of the available label/index combinations somewhere, doesn't need to be here
    final websites = Map<String, List<String>>.from(
        contactsRepository.getProfileSharingSettings().websites);
    websites[label] = circles.map((c) => c.$1).toList();
    final updatedSharingSettings = contactsRepository
        .getProfileSharingSettings()
        .copyWith(websites: websites);
    contactsRepository.setProfileSharingSettings(updatedSharingSettings);
    // TODO: Handle via update subscription instead of updating the state ourselves here?
    if (!isClosed) {
      emit(state.copyWith(sharingSettings: updatedSharingSettings));
    }
  }

  Future<void> updateSocialMediaSharingCircles(
      int index, String label, List<(String, String)> circles) async {
    // TODO: Trigger a cleanup of the available label/index combinations somewhere, doesn't need to be here
    final socialMedias = Map<String, List<String>>.from(
        contactsRepository.getProfileSharingSettings().socialMedias);
    socialMedias[label] = circles.map((c) => c.$1).toList();
    final updatedSharingSettings = contactsRepository
        .getProfileSharingSettings()
        .copyWith(socialMedias: socialMedias);
    contactsRepository.setProfileSharingSettings(updatedSharingSettings);
    // TODO: Handle via update subscription instead of updating the state ourselves here?
    if (!isClosed) {
      emit(state.copyWith(sharingSettings: updatedSharingSettings));
    }
  }

  Future<void> updateEventSharingCircles(
      int index, String label, List<(String, String)> circles) async {
    // TODO: Trigger a cleanup of the available label/index combinations somewhere, doesn't need to be here
    final events = Map<String, List<String>>.from(
        contactsRepository.getProfileSharingSettings().events);
    events[label] = circles.map((c) => c.$1).toList();
    final updatedSharingSettings =
        contactsRepository.getProfileSharingSettings().copyWith(events: events);
    contactsRepository.setProfileSharingSettings(updatedSharingSettings);
    // TODO: Handle via update subscription instead of updating the state ourselves here?
    if (!isClosed) {
      emit(state.copyWith(sharingSettings: updatedSharingSettings));
    }
  }

  Future<void> updateDetails(ContactDetails details) async {
    if (state.profileContact == null) {
      return;
    }
    final updatedContact = state.profileContact!.copyWith(details: details);
    await contactsRepository.updateProfileContactData(updatedContact);
  }

  Future<void> addName(
      String name, List<(String, String, bool)> circlesWithSelection) async {
    if (state.profileContact?.details == null) {
      return;
    }

    final names = state.profileContact!.details!.names;
    final id = Uuid().v4();
    names[id] = name;

    await updateDetails(state.profileContact!.details!.copyWith(names: names));

    await createCirclesIfNotExist(
        circlesWithSelection.map((e) => (e.$1, e.$2)).toList());

    await updateNameSharingCircles(
        id,
        circlesWithSelection
            .where((e) => e.$3)
            .map((e) => (e.$1, e.$2))
            .toList());
  }

  Future<void> editName(int i, String id, String name,
      List<(String, String, bool)> circlesWithSelection) async {
    if (state.profileContact?.details == null) {
      return;
    }

    final names = {...state.profileContact!.details!.names};
    final id = names.entries.elementAt(i).key;
    names[id] = name;

    await updateDetails(state.profileContact!.details!.copyWith(names: names));

    await createCirclesIfNotExist(
        circlesWithSelection.map((e) => (e.$1, e.$2)).toList());

    await updateNameSharingCircles(
        id,
        circlesWithSelection
            .where((e) => e.$3)
            .map((e) => (e.$1, e.$2))
            .toList());
  }

  Future<void> addPhone(
      Phone phone, List<(String, String, bool)> circlesWithSelection) async {
    if (state.profileContact?.details == null) {
      return;
    }

    final phones = [...state.profileContact!.details!.phones, phone];
    final i = phones.length - 1;

    await updateDetails(
        state.profileContact!.details!.copyWith(phones: phones));

    await createCirclesIfNotExist(
        circlesWithSelection.map((e) => (e.$1, e.$2)).toList());

    await updatePhoneSharingCircles(
        i,
        (phones[i].label.name != 'custom')
            ? phones[i].label.name
            : phones[i].customLabel,
        circlesWithSelection
            .where((e) => e.$3)
            .map((e) => (e.$1, e.$2))
            .toList());
  }

  Future<void> editPhone(int i, String label, String number,
      List<(String, String, bool)> circlesWithSelection) async {
    if (state.profileContact?.details == null) {
      return;
    }

    final phones = state.profileContact!.details!.phones;
    phones[i] = Phone(number, label: PhoneLabel.custom, customLabel: label);

    await updateDetails(
        state.profileContact!.details!.copyWith(phones: phones));

    await createCirclesIfNotExist(
        circlesWithSelection.map((e) => (e.$1, e.$2)).toList());

    await updatePhoneSharingCircles(
        i,
        (phones[i].label.name != 'custom')
            ? phones[i].label.name
            : phones[i].customLabel,
        circlesWithSelection
            .where((e) => e.$3)
            .map((e) => (e.$1, e.$2))
            .toList());
  }

  Future<void> addEmail(
      Email email, List<(String, String, bool)> circlesWithSelection) async {
    if (state.profileContact?.details == null) {
      return;
    }

    final emails = [...state.profileContact!.details!.emails, email];
    final i = emails.length - 1;

    await updateDetails(
        state.profileContact!.details!.copyWith(emails: emails));

    await createCirclesIfNotExist(
        circlesWithSelection.map((e) => (e.$1, e.$2)).toList());

    await updateEmailSharingCircles(
        i,
        (emails[i].label.name != 'custom')
            ? emails[i].label.name
            : emails[i].customLabel,
        circlesWithSelection
            .where((e) => e.$3)
            .map((e) => (e.$1, e.$2))
            .toList());
  }

  Future<void> editEmail(int i, String label, String address,
      List<(String, String, bool)> circlesWithSelection) async {
    if (state.profileContact?.details == null) {
      return;
    }

    final emails = state.profileContact!.details!.emails;
    emails[i] = Email(address, label: EmailLabel.custom, customLabel: label);

    await updateDetails(
        state.profileContact!.details!.copyWith(emails: emails));

    await createCirclesIfNotExist(
        circlesWithSelection.map((e) => (e.$1, e.$2)).toList());

    await updateEmailSharingCircles(
        i,
        (emails[i].label.name != 'custom')
            ? emails[i].label.name
            : emails[i].customLabel,
        circlesWithSelection
            .where((e) => e.$3)
            .map((e) => (e.$1, e.$2))
            .toList());
  }

  Future<void> addSocialMedia(SocialMedia socialMedia,
      List<(String, String, bool)> circlesWithSelection) async {
    if (state.profileContact?.details == null) {
      return;
    }

    final socialMedias = [
      ...state.profileContact!.details!.socialMedias,
      socialMedia
    ];
    final i = socialMedias.length - 1;

    await updateDetails(
        state.profileContact!.details!.copyWith(socialMedias: socialMedias));

    await createCirclesIfNotExist(
        circlesWithSelection.map((e) => (e.$1, e.$2)).toList());

    await updateSocialMediaSharingCircles(
        i,
        (socialMedias[i].label.name != 'custom')
            ? socialMedias[i].label.name
            : socialMedias[i].customLabel,
        circlesWithSelection
            .where((e) => e.$3)
            .map((e) => (e.$1, e.$2))
            .toList());
  }

  Future<void> editSocialMedia(int i, String label, String userName,
      List<(String, String, bool)> circlesWithSelection) async {
    if (state.profileContact?.details == null) {
      return;
    }

    final socialMedias = state.profileContact!.details!.socialMedias;
    socialMedias[i] = SocialMedia(userName,
        label: SocialMediaLabel.custom, customLabel: label);

    await updateDetails(
        state.profileContact!.details!.copyWith(socialMedias: socialMedias));

    await createCirclesIfNotExist(
        circlesWithSelection.map((e) => (e.$1, e.$2)).toList());

    await updateSocialMediaSharingCircles(
        i,
        (socialMedias[i].label.name != 'custom')
            ? socialMedias[i].label.name
            : socialMedias[i].customLabel,
        circlesWithSelection
            .where((e) => e.$3)
            .map((e) => (e.$1, e.$2))
            .toList());
  }

  Future<void> addWebsite(Website website,
      List<(String, String, bool)> circlesWithSelection) async {
    if (state.profileContact?.details == null) {
      return;
    }

    final websites = [...state.profileContact!.details!.websites, website];
    final i = websites.length - 1;

    await updateDetails(
        state.profileContact!.details!.copyWith(websites: websites));

    await createCirclesIfNotExist(
        circlesWithSelection.map((e) => (e.$1, e.$2)).toList());

    await updateWebsiteSharingCircles(
        i,
        (websites[i].label.name != 'custom')
            ? websites[i].label.name
            : websites[i].customLabel,
        circlesWithSelection
            .where((e) => e.$3)
            .map((e) => (e.$1, e.$2))
            .toList());
  }

  Future<void> editWebsite(int i, String label, String url,
      List<(String, String, bool)> circlesWithSelection) async {
    if (state.profileContact?.details == null) {
      return;
    }

    final websites = state.profileContact!.details!.websites;
    websites[i] = Website(url, label: WebsiteLabel.custom, customLabel: label);

    await updateDetails(
        state.profileContact!.details!.copyWith(websites: websites));

    await createCirclesIfNotExist(
        circlesWithSelection.map((e) => (e.$1, e.$2)).toList());

    await updateWebsiteSharingCircles(
        i,
        (websites[i].label.name != 'custom')
            ? websites[i].label.name
            : websites[i].customLabel,
        circlesWithSelection
            .where((e) => e.$3)
            .map((e) => (e.$1, e.$2))
            .toList());
  }

  Future<void> addAddress(Address address,
      List<(String, String, bool)> circlesWithSelection) async {
    if (state.profileContact?.details == null) {
      return;
    }

    final addresses = [...state.profileContact!.details!.addresses, address];
    final i = addresses.length - 1;

    await updateDetails(
        state.profileContact!.details!.copyWith(addresses: addresses));

    // TODO: Only fetch if missing or address changed
    await fetchCoordinates(i);

    await createCirclesIfNotExist(
        circlesWithSelection.map((e) => (e.$1, e.$2)).toList());

    await updateAddressSharingCircles(
        i,
        (addresses[i].label.name != 'custom')
            ? addresses[i].label.name
            : addresses[i].customLabel,
        circlesWithSelection
            .where((e) => e.$3)
            .map((e) => (e.$1, e.$2))
            .toList());
  }

  Future<void> editAddress(int i, String label, String address,
      List<(String, String, bool)> circlesWithSelection) async {
    if (state.profileContact?.details == null) {
      return;
    }

    final addresses = state.profileContact!.details!.addresses;
    addresses[i] =
        Address(address, label: AddressLabel.custom, customLabel: label);

    await updateDetails(
        state.profileContact!.details!.copyWith(addresses: addresses));

    // TODO: Only fetch if missing or address changed
    await fetchCoordinates(i);

    await createCirclesIfNotExist(
        circlesWithSelection.map((e) => (e.$1, e.$2)).toList());

    await updateAddressSharingCircles(
        i,
        (addresses[i].label.name != 'custom')
            ? addresses[i].label.name
            : addresses[i].customLabel,
        circlesWithSelection
            .where((e) => e.$3)
            .map((e) => (e.$1, e.$2))
            .toList());
  }

  @override
  Future<void> close() {
    _contactsSubscription.cancel();
    _permissionsSubscription.cancel();
    return super.close();
  }
}
