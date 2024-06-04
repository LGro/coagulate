// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:veilid/veilid.dart';

import '../../veilid_processor/repository/processor_repository.dart';
import '../models/coag_contact.dart';
import '../models/contact_location.dart';
import '../models/contact_update.dart';
import '../models/profile_sharing_settings.dart';
import '../providers/distributed_storage/base.dart';
import '../providers/persistent_storage/base.dart';
import '../providers/system_contacts/base.dart';
import '../providers/system_contacts/system_contacts.dart';

String contactDetailKey<T>(int i, T detail) {
  if (detail is Organization) {
    return '$i|${detail.company}';
  }

  if (detail is Phone) {
    final label = (detail.label.name == 'custom')
        ? detail.customLabel
        : detail.label.name;
    return '$i|$label';
  }
  if (detail is Email) {
    final label = (detail.label.name == 'custom')
        ? detail.customLabel
        : detail.label.name;
    return '$i|$label';
  }
  if (detail is Address) {
    final label = (detail.label.name == 'custom')
        ? detail.customLabel
        : detail.label.name;
    return '$i|$label';
  }
  if (detail is Website) {
    final label = (detail.label.name == 'custom')
        ? detail.customLabel
        : detail.label.name;
    return '$i|$label';
  }
  if (detail is SocialMedia) {
    final label = (detail.label.name == 'custom')
        ? detail.customLabel
        : detail.label.name;
    return '$i|$label';
  }
  if (detail is Event) {
    final label = (detail.label.name == 'custom')
        ? detail.customLabel
        : detail.label.name;
    return '$i|$label';
  }

  // TODO: Return null or i instead?
  return '';
}

List<T> filterContactDetailsList<T>(
  List<T> values,
  Map<String, List<String>> settings,
  List<String> activeCircles,
) {
  if (activeCircles.isEmpty) {
    return [];
  }
  final updatedValues = Map<int, T>.from(values.asMap())
    ..removeWhere((i, e) => !(settings[contactDetailKey(i, e)]
            ?.asSet()
            .intersectsWith(activeCircles.asSet()) ??
        false));
  return updatedValues.values.asList();
}

ContactDetails filterDetails(ContactDetails details,
        ProfileSharingSettings settings, List<String> activeCircles) =>
    ContactDetails(
      // TODO: filter the names as well
      displayName: details.displayName,
      name: details.name,
      phones: filterContactDetailsList(
          details.phones, settings.phones, activeCircles),
      emails: filterContactDetailsList(
          details.emails, settings.emails, activeCircles),
      addresses: filterContactDetailsList(
          details.addresses, settings.addresses, activeCircles),
      organizations: filterContactDetailsList(
          details.organizations, settings.organizations, activeCircles),
      websites: filterContactDetailsList(
          details.websites, settings.websites, activeCircles),
      socialMedias: filterContactDetailsList(
          details.socialMedias, settings.socialMedias, activeCircles),
      events: filterContactDetailsList(
          details.events, settings.events, activeCircles),
    );

// TODO: Implement me; but maybe switch for address locations to a similar indexing scheme like with the other details for circles?
Map<int, ContactAddressLocation> filterAddressLocations(
        Map<int, ContactAddressLocation> locations,
        ProfileSharingSettings settings,
        List<String> activeCircles) =>
    locations;

/// Remove locations that ended longer than a day ago, or aren't shared with the given circles
List<ContactTemporaryLocation> filterTemporaryLocations(
        List<ContactTemporaryLocation> locations, List<String> activeCircles) =>
    locations
        .where((l) =>
            !l.end.add(const Duration(days: 1)).isBefore(DateTime.now()) &&
            l.circles.toSet().intersectsWith(activeCircles.toSet()))
        .asList();

CoagContactDHTSchemaV1 filterAccordingToSharingProfile(
        {required CoagContact profile,
        required ProfileSharingSettings settings,
        required List<String> activeCircles,
        required ContactDHTSettings? shareBackSettings}) =>
    CoagContactDHTSchemaV1(
      coagContactId: profile.coagContactId,
      details: filterDetails(
          ContactDetails.fromSystemContact(profile.systemContact!),
          settings,
          activeCircles),
      // Only share locations up to 1 day ago
      temporaryLocations:
          filterTemporaryLocations(profile.temporaryLocations, activeCircles),
      addressLocations: filterAddressLocations(
          profile.addressLocations, settings, activeCircles),
      shareBackDHTKey: shareBackSettings?.key,
      shareBackDHTWriter: shareBackSettings?.writer,
      shareBackPsk: shareBackSettings?.psk,
    );

Map<String, dynamic> removeNullOrEmptyValues(Map<String, dynamic> json) {
  // TODO: implement me; or implement custom schema for sharing payload
  return json;
}

/// Entrypoint for application layer when it comes to [CoagContact]
class ContactsRepository {
  ContactsRepository(this.persistentStorage, this.distributedStorage,
      this.systemContactsStorage) {
    unawaited(_init());

    // Regularly check for updates from the persistent storage,
    // e.g. in case it was updated from background processes.
    timerPersistentStorageRefresh =
        Timer.periodic(Duration(seconds: 5), (_) async => ()
            // _updateFromPersistentStorage()
            );

    // TODO: Check if we can/should replace this with listening to the Veilid update stream
    timerDhtRefresh = Timer.periodic(
        Duration(seconds: 5), (_) async => updateAndWatchReceivingDHT());
  }

  final PersistentStorage persistentStorage;
  final DistributedStorage distributedStorage;
  final SystemContactsBase systemContactsStorage;

  late final Timer? timerPersistentStorageRefresh;
  late final Timer? timerDhtRefresh;
  String? profileContactId;

  /// Circles with IDs as keys and labels as values
  Map<String, String> _circles = {};

  /// Profile contact sharing settings, specifying circles for each detail
  ProfileSharingSettings _profileSharingSettings =
      const ProfileSharingSettings();

  /// Mapping of coagulate contact IDs to circle IDs
  Map<String, List<String>> _circleMemberships = {};

  Map<String, CoagContact> _contacts = {};
  final _contactsStreamController = BehaviorSubject<CoagContact>();

  // TODO: Double check whether we actually need this second stream, i.e. when would an update be passed here but not on the contacts stream?
  List<ContactUpdate> updates = [];
  final _updatesStreamController = BehaviorSubject<ContactUpdate>();

  final _circlesStreamController = BehaviorSubject<void>();

  final _systemContactAccessGrantedStreamController =
      BehaviorSubject<bool>.seeded(false);

  Future<void> _init() async {
    // Load profile contact ID from persistent storage
    profileContactId = await persistentStorage.getProfileContactId();

    // Initialize circles, circle memberships and sharing settings from persistent storage
    _profileSharingSettings =
        await persistentStorage.getProfileSharingSettings();
    _circleMemberships = await persistentStorage.getCircleMemberships();
    _circles = await persistentStorage.getCircles();

    // Load updates from persistent storage
    updates = await persistentStorage.getUpdates();
    for (final u in updates) {
      _updatesStreamController.add(u);
    }

    // Load coagulate contacts from persistent storage
    _contacts = await persistentStorage.getAllContacts();
    for (final c in _contacts.values) {
      _contactsStreamController.add(c);
    }

    await updateFromSystemContacts();
    FlutterContacts.addListener(_systemContactsChangedCallback);

    // Update the contacts from DHT and subscribe to future updates
    await updateAndWatchReceivingDHT();
    // TODO: This doesn't seem to work, double check; current workaround via timerDhtRefresh
    // ProcessorRepository.instance
    //     .streamUpdateValueChange()
    //     .listen(_veilidUpdateValueChangeCallback);

    // TODO: Only do this when online
    // for (final contact in _contacts.values) {
    //   await saveContact(await updateContactSharingDHT(contact));
    // }
  }

  Future<void> updateCircleMemberships(
      Map<String, List<String>> memberships) async {
    _circleMemberships = memberships;
    _circlesStreamController.add(null);
    await persistentStorage.updateCircleMemberships(memberships);

    for (final contact in _contacts.values) {
      final profileContact = getProfileContact();
      if (contact.dhtSettingsForSharing == null || profileContact == null) {
        continue;
      }

      final sharedProfile = json.encode(removeNullOrEmptyValues(
          filterAccordingToSharingProfile(
                  profile: profileContact,
                  settings: _profileSharingSettings,
                  activeCircles:
                      _circleMemberships[contact.coagContactId] ?? [],
                  shareBackSettings: contact.dhtSettingsForReceiving)
              .toJson()));
      if (sharedProfile == contact.sharedProfile) {
        continue;
      }

      // TODO: This seems too big of an action to trigger
      // disentangle this to just updating the contact and letting the ui know
      // push changes to dht async
      await updateContact(contact.copyWith(sharedProfile: sharedProfile));
    }
  }

  Future<void> updateCircles(Map<String, String> circles) async {
    _circles = circles;
    _circlesStreamController.add(null);
    await persistentStorage.updateCircles(circles);
  }

  Future<void> setProfileSharingSettings(
      ProfileSharingSettings settings) async {
    _profileSharingSettings = settings;
    await persistentStorage.updateProfileSharingSettings(settings);

    final profileContact = getProfileContact();
    if (profileContact == null) {
      return;
    }
    for (final contact in _contacts.values) {
      if (contact.dhtSettingsForSharing?.psk == null) {
        continue;
      }
      await updateContact(contact.copyWith(
          sharedProfile: json.encode(removeNullOrEmptyValues(
              filterAccordingToSharingProfile(
                      profile: profileContact,
                      settings: _profileSharingSettings,
                      activeCircles:
                          _circleMemberships[contact.coagContactId] ?? [],
                      shareBackSettings: contact.dhtSettingsForReceiving)
                  .toJson()))));
    }
  }

  ProfileSharingSettings getProfileSharingSettings() => _profileSharingSettings;

  List<(String, String, bool)> circlesWithMembership(String coagContactId) =>
      _circles
          .map((id, label) => MapEntry(id, (
                id,
                label,
                (_circleMemberships[coagContactId] ?? []).contains(id)
              )))
          .values
          .toList();

  Future<void> saveContact(CoagContact coagContact) async {
    _contacts[coagContact.coagContactId] = coagContact;
    _contactsStreamController.add(coagContact);
    await persistentStorage.updateContact(coagContact);
  }

  Future<void> _saveUpdate(ContactUpdate update) async {
    updates.add(update);
    _updatesStreamController.add(update);
    // TODO: Have two persistent storages with different prefixes for updates and contacts?
    await persistentStorage.addUpdate(update);
  }

  Future<void> _updateFromSystemContact(CoagContact contact) async {
    if (contact.systemContact == null) {
      // TODO: Log
      return;
    }
    // Try if permissions are granted
    try {
      final systemContact =
          await systemContactsStorage.getContact(contact.systemContact!.id);
      _systemContactAccessGrantedStreamController.add(true);

      if (systemContact != contact.systemContact!) {
        final updatedContact = contact.copyWith(systemContact: systemContact);
        await saveContact(updatedContact);
      }
    } on MissingSystemContactsPermissionError {
      _systemContactAccessGrantedStreamController.add(false);
    }
  }

  Future<void> _systemContactsChangedCallback() async {
    // Delay to avoid system update coming in before other updates
    await Future.delayed(const Duration(milliseconds: 100));
    final oldProfileContact = _contacts[profileContactId];
    await updateFromSystemContacts();
    if (oldProfileContact != null &&
        oldProfileContact != _contacts[profileContactId]) {
      // Trigger update of share profiles and all that jazz
      await updateProfileContact(profileContactId!);
    }
  }

  // TODO: Refactor redundancies with updateAndWatchReceivingDHT
  Future<void> _veilidUpdateValueChangeCallback(
      VeilidUpdateValueChange update) async {
    final contact = _contacts.values.firstWhereOrNull(
        (c) => c.dhtSettingsForReceiving!.key == update.key.toString());

    // FIXME: Appropriate error handling
    if (contact == null) {
      return;
    }

    final updatedContact =
        await distributedStorage.updateContactReceivingDHT(contact);
    if (updatedContact != contact) {
      // TODO: Use update time from when the update was sent not received
      // TODO: Can it happen that details are null?
      // TODO: When temporary locations are updated, only record an update about added / updated locations / check-ins
      await _saveUpdate(ContactUpdate(
          coagContactId: contact.coagContactId,
          oldContact: contact.details!,
          newContact: updatedContact.details!,
          timestamp: DateTime.now()));
      await updateContact(updatedContact);
    }
  }

  Future<void> _updateFromPersistentStorage() async {
    await (await SharedPreferences.getInstance()).reload();
    final storedContacts = await persistentStorage.getAllContacts();
    // TODO: Working with _contacts.values directly is prone to a ConcurrentModificationError; copying as a workaround
    for (final contact in List<CoagContact>.from(_contacts.values)) {
      // Update if there is no matching contact but is a corresponding ID
      if (!storedContacts.containsValue(contact) &&
          storedContacts.containsKey(contact.coagContactId)) {
        // TODO: Check most recent update timestamp and make sure the on from persistent storag is more recent
        await saveContact(storedContacts[contact.coagContactId]!);
      }
    }
  }

  /// Update all system contacts in case they changed and add missing ones
  // TODO: Test that there can be coagulate contacts with a system contact that isn't actually in the system
  Future<void> updateFromSystemContacts() async {
    // Try if permissions are granted
    try {
      var systemContacts = await systemContactsStorage.getContacts();
      _systemContactAccessGrantedStreamController.add(true);
      for (final coagContact in List<CoagContact>.from(_contacts.values)) {
        // Skip coagulate contacts that are not associated with a system contact
        if (coagContact.systemContact == null) {
          continue;
        }
        // Remove contacts that did not change
        // TODO: This could be coagContact.getSystemContactBasedOnSyncSettings
        //  in case we want to keep the original system contact for reference
        // FIXME: SystemContact comparisons might not work, because we remove the photo / thumbnail?
        if (systemContacts.remove(coagContact.systemContact)) {
          continue;
        }
        // The remaining matches based on system contact ID need to be updated
        final iChangedContact = systemContacts.indexWhere((systemContact) =>
            systemContact.id == coagContact.systemContact!.id);
        final CoagContact updatedContact;
        if (iChangedContact == -1) {
          // If after removing the system contact, nothing would be left, remove the contact entirely
          if (coagContact.details == null) {
            await removeContact(coagContact.coagContactId);
            continue;
          }
          // Otherwise just remove system contact from CoagContact i.e. "unlink" the contact
          // TODO: Add update and propose to remove contact from coagulate as well?
          // TODO: When adding attributes to CoagContact, they need to be added here; cover this with a test
          updatedContact = CoagContact(
            coagContactId: coagContact.coagContactId,
            details: coagContact.details,
            addressLocations: coagContact.addressLocations,
            temporaryLocations: coagContact.temporaryLocations,
            dhtSettingsForSharing: coagContact.dhtSettingsForSharing,
            dhtSettingsForReceiving: coagContact.dhtSettingsForReceiving,
            sharedProfile: coagContact.sharedProfile,
          );
        } else {
          updatedContact = coagContact.copyWith(
              systemContact: systemContacts[iChangedContact]);
          systemContacts.removeAt(iChangedContact);
        }
        await saveContact(updatedContact);
      }
      // The remaining system contacts are new
      for (final systemContact in systemContacts) {
        await saveContact(CoagContact(
            coagContactId: const Uuid().v4(), systemContact: systemContact));
      }
    } on MissingSystemContactsPermissionError {
      _systemContactAccessGrantedStreamController.add(false);
    }
  }

  // TODO: Rename for clarity?
  Stream<CoagContact> getContactUpdates() =>
      _contactsStreamController.asBroadcastStream();

  Stream<ContactUpdate> getUpdates() =>
      _updatesStreamController.asBroadcastStream();

  Stream<void> getCirclesUpdates() =>
      _circlesStreamController.asBroadcastStream();

  // TODO: subscribe to this from a settings cubit to show the appropriate button in UI
  Stream<bool> isSystemContactAccessGranted() =>
      _systemContactAccessGrantedStreamController.asBroadcastStream();

  // TODO: Does that need to be separate depending on whether the update originated from the dht or not?
  //       Or maybe separate depending on what part is updated (details, locations, dht stuff)
  Future<void> updateContact(CoagContact contact) async {
    final oldContact = _contacts[contact.coagContactId];
    // Skip in case already up to date
    if (oldContact == contact) {
      return;
    }

    // Early save to not keep everyone waiting for the DHT update
    await saveContact(contact);

    // TODO: Allow creation of a new system contact via update contact as well; might require custom contact details schema
    // Update system contact if linked and contact details changed
    if (contact.systemContact != null &&
        _contacts[contact.coagContactId]?.systemContact !=
            contact.systemContact) {
      // TODO: How to reconsile system contacts if permission was removed intermittently and is then granted again?
      try {
        await systemContactsStorage.updateContact(contact.systemContact!);
      } on MissingSystemContactsPermissionError {
        _systemContactAccessGrantedStreamController.add(false);
      }
    }

    if (contact.sharedProfile != null) {
      contact = await distributedStorage.updateContactSharingDHT(contact);
    }

    if (contact.dhtSettingsForReceiving != null) {
      contact = await distributedStorage.updateContactReceivingDHT(contact);
    }

    // Final save after a potential dht update
    await saveContact(contact);
  }

  Future<void> updateAndWatchReceivingDHT({bool shuffle = false}) async {
    // TODO: Only do this when online; FIXME: This is a hack
    if (!ProcessorRepository
        .instance.processorConnectionState.attachment.publicInternetReady) {
      return;
    }
    final contacts = _contacts.values.toList();
    if (shuffle) {
      contacts.shuffle();
    }
    for (final contact in contacts) {
      // Check for incoming updates
      if (contact.dhtSettingsForReceiving != null) {
        final updatedContact =
            await distributedStorage.updateContactReceivingDHT(contact);
        if (updatedContact != contact) {
          // TODO: Use update time from when the update was sent not received
          // TODO: Can it happen that details are null?
          // TODO: When temporary locations are updated, only record an update about added / updated locations / check-ins
          await _saveUpdate(ContactUpdate(
              // TODO: contact details can be null; handle this more appropriately than the current workaround with empty details
              coagContactId: contact.coagContactId,
              oldContact: contact.details ??
                  ContactDetails(displayName: '', name: Name()),
              newContact: updatedContact.details!,
              timestamp: DateTime.now()));
          await updateContact(updatedContact);
        }
        await distributedStorage
            .watchDHTRecord(contact.dhtSettingsForReceiving!.key);
      }
    }
  }

  CoagContact? getProfileContact() {
    if (profileContactId == null) {
      return null;
    }
    return _contacts[profileContactId!];
  }

  Future<void> updateProfileContact(String coagContactId) async {
    if (!_contacts.containsKey(coagContactId)) {
      // TODO: Log / raise error
      return;
    }

    // TODO: Do we need to enforce writing to disk to make it available to background straight away?
    profileContactId = coagContactId;
    await persistentStorage.setProfileContactId(coagContactId);

    // Ensure all system contacts changes are in
    await _updateFromSystemContact(_contacts[coagContactId]!);

    for (final contact in _contacts.values) {
      if (contact.dhtSettingsForSharing?.psk == null) {
        continue;
      }
      await updateContact(contact.copyWith(
          sharedProfile: json.encode(removeNullOrEmptyValues(
              filterAccordingToSharingProfile(
                      profile: _contacts[coagContactId]!,
                      settings: _profileSharingSettings,
                      activeCircles:
                          _circleMemberships[contact.coagContactId] ?? [],
                      shareBackSettings: contact.dhtSettingsForReceiving)
                  .toJson()))));
    }
  }

  CoagContact? getCoagContactForSystemContactId(String systemContactId) =>
      _contacts.values
          .firstWhere((c) => c.systemContact?.id == systemContactId);

  String? getCoagContactIdForSystemContactId(String systemContactId) =>
      getCoagContactForSystemContactId(systemContactId)?.coagContactId;

  Map<String, CoagContact> getContacts() => _contacts;

  // TODO: Proper error handling in case contact id not found or return nullable type
  CoagContact getContact(String coagContactId) => _contacts[coagContactId]!;

  Future<void> removeContact(String coagContactId) async {
    _contacts.remove(coagContactId);
    await persistentStorage.removeContact(coagContactId);
  }

  Map<String, String> getCircles() => _circles;
  Map<String, List<String>> getCircleMemberships() => _circleMemberships;
}
