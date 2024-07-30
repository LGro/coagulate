import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:geocoding/geocoding.dart';
import 'package:rxdart/subjects.dart';
import 'package:uuid/uuid.dart';
import 'package:veilid/veilid_state.dart';

import '../../veilid_processor/veilid_processor.dart';
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
            l.end.isAfter(DateTime.now()) &&
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

class ContactsRepository {
  ContactsRepository(this.persistentStorage, this.distributedStorage,
      this.systemContactsStorage,
      {bool initialize = true}) {
    if (initialize) {
      unawaited(this.initialize());
    }
  }

  final PersistentStorage persistentStorage;
  final DistributedStorage distributedStorage;
  final SystemContactsBase systemContactsStorage;

  Map<String, CoagContact> _contacts = {};
  final _contactsStreamController = BehaviorSubject<String>();
  Stream<String> getContactStream() =>
      _contactsStreamController.asBroadcastStream();

  /// Coagulate contact ID of the profile contact
  String? _profileContactId;

  /// Profile contact sharing settings, specifying circles for each detail
  ProfileSharingSettings _profileSharingSettings =
      const ProfileSharingSettings();

  /// Circles with IDs as keys and labels as values
  Map<String, String> _circles = {};
  final _circlesStreamController = BehaviorSubject<void>();

  /// Update stream for changes affecting the available circles.
  /// For contact circle membership related changes, subscribe to
  /// getContactStream()
  Stream<void> getCirclesStream() =>
      _circlesStreamController.asBroadcastStream();

  /// Mapping of coagulate contact IDs to circle IDs
  Map<String, List<String>> _circleMemberships = {};

  /// History of received contact updates
  List<ContactUpdate> _contactUpdates = [];
  final _updatesStreamController = BehaviorSubject<ContactUpdate>();
  Stream<ContactUpdate> getUpdatesStream() =>
      _updatesStreamController.asBroadcastStream();

  // TODO: subscribe to this from a settings cubit to show the appropriate button in UI
  final _systemContactAccessGrantedStreamController =
      BehaviorSubject<bool>.seeded(false);
  Stream<bool> isSystemContactAccessGranted() =>
      _systemContactAccessGrantedStreamController.asBroadcastStream();

  bool systemContactsChangedCallbackTemporarilyDisabled = false;

  bool veilidNetworkAvailable = false;

  Future<void> initialize() async {
    await initializeFromPersistentStorage();

    await updateFromSystemContacts();
    FlutterContacts.addListener(_systemContactsChangedCallback);

    // Update the contacts from DHT and subscribe to future updates
    await updateAndWatchReceivingDHT();

    // Update the shared profile with all contacts
    await updateSharingDHT();

    ProcessorRepository.instance
        .streamProcessorConnectionState()
        .listen(_veilidConnectionStateChangeCallback);

    // TODO: This doesn't seem to work, double check; current workaround via timerDhtRefresh
    ProcessorRepository.instance
        .streamUpdateValueChange()
        .listen(_veilidUpdateValueChangeCallback);
  }

  /////////////////////
  // PERSISTENT STORAGE
  Future<void> initializeFromPersistentStorage() async {
    _profileContactId = await persistentStorage.getProfileContactId();

    // Initialize circles, circle memberships and sharing settings from persistent storage
    _circles = await persistentStorage.getCircles();
    _circleMemberships = await persistentStorage.getCircleMemberships();
    _profileSharingSettings =
        await persistentStorage.getProfileSharingSettings();

    // Load updates from persistent storage
    // TODO: Actually delete old updates from persistent storage
    _contactUpdates = (await persistentStorage.getUpdates())
        .where((u) => u.timestamp
            .isAfter(DateTime.now().subtract(const Duration(days: 30))))
        .toList();
    for (final u in _contactUpdates) {
      _updatesStreamController.add(u);
    }

    // Load coagulate contacts from persistent storage
    _contacts = await persistentStorage.getAllContacts();
    for (final c in _contacts.values) {
      _contactsStreamController.add(c.coagContactId);
    }
  }

  Future<void> saveContact(CoagContact coagContact) async {
    _contacts[coagContact.coagContactId] = coagContact;
    _contactsStreamController.add(coagContact.coagContactId);
    await persistentStorage.updateContact(coagContact);
  }

  // update contacts from system address book (async)
  // update contacts from dht (async)

  // update repo state (sync)
  // update persistent storage (async)
  // update system address book (async)
  // update contacts in dht (async)

  //////
  // DHT
  Future<void> updateContactFromDHT(CoagContact contact) async {
    final updatedContact =
        await distributedStorage.updateContactReceivingDHT(contact);
    final updateTime = DateTime.now();
    if (updatedContact == contact) {
      await saveContact(updatedContact.copyWith(mostRecentUpdate: updateTime));
    } else {
      // TODO: Use update time from when the update was sent not received
      // TODO: When temporary locations are updated, only record an update about added / updated locations / check-ins
      await _saveUpdate(ContactUpdate(
          // TODO: contact details can be null; handle this more appropriately than the current workaround with empty details
          coagContactId: contact.coagContactId,
          oldContact:
              contact.details ?? ContactDetails(displayName: '', name: Name()),
          // TODO: Can it happen that details are null?
          newContact: updatedContact.details!,
          timestamp: DateTime.now()));

      await saveContact(updatedContact.copyWith(
          mostRecentUpdate: updateTime, mostRecentChange: updateTime));

      // TODO: Allow creation of a new system contact via update contact as well; might require custom contact details schema
      // Update system contact if linked and contact details changed
      if (updatedContact.systemContact != null &&
          contact.systemContact != updatedContact.systemContact) {
        // TODO: How to reconsile system contacts if permission was removed intermittently and is then granted again?
        try {
          await systemContactsStorage
              .updateContact(updatedContact.systemContact!);
        } on MissingSystemContactsPermissionError {
          _systemContactAccessGrantedStreamController.add(false);
        }
      }
    }
    if (contact.dhtSettingsForReceiving != null) {
      await distributedStorage
          .watchDHTRecord(contact.dhtSettingsForReceiving!.key);
    }
  }

  void _veilidConnectionStateChangeCallback(ProcessorConnectionState event) {
    if (event.isPublicInternetReady &&
        event.isAttached &&
        !veilidNetworkAvailable) {
      veilidNetworkAvailable = true;
      unawaited(updateAndWatchReceivingDHT());
      unawaited(updateSharingDHT());
    }
  }

  Future<void> _veilidUpdateValueChangeCallback(
      VeilidUpdateValueChange update) async {
    final contact = _contacts.values.firstWhereOrNull(
        (c) => c.dhtSettingsForReceiving?.key == update.key.toString());
    if (contact == null) {
      // TODO: log
      return;
    }
    await updateContactFromDHT(contact);
  }

  Future<void> updateAndWatchReceivingDHT({bool shuffle = false}) async {
    if (!ProcessorRepository
        .instance.processorConnectionState.attachment.publicInternetReady) {
      veilidNetworkAvailable = false;
      return;
    }
    veilidNetworkAvailable = true;
    final contacts = _contacts.values.toList();
    if (shuffle) {
      contacts.shuffle();
    }
    for (final contact in contacts) {
      // Check for incoming updates
      if (contact.dhtSettingsForReceiving != null) {
        await updateContactFromDHT(contact);
      }
    }
  }

  Future<void> updateSharingDHT() async {
    if (!ProcessorRepository
        .instance.processorConnectionState.attachment.publicInternetReady) {
      veilidNetworkAvailable = false;
      return;
    }
    veilidNetworkAvailable = true;
    if (_profileContactId != null) {
      await updateFromSystemContact(_profileContactId!);
    }
    // TODO: With many contacts, can this run into parallel DHT write limitations?
    await Future.wait([
      for (final contact in _contacts.values
          .where((c) => c.dhtSettingsForSharing?.psk != null))
        updateContactSharedProfile(contact.coagContactId)
    ]);
  }

  //////////////////
  // SYSTEM CONTACTS
  Future<void> _systemContactsChangedCallback() async {
    if (systemContactsChangedCallbackTemporarilyDisabled) {
      return;
    }
    final oldProfileContact = getProfileContact();
    await updateFromSystemContacts();
    final newProfileContact = getProfileContact();
    if (oldProfileContact != null && oldProfileContact != newProfileContact) {
      // Trigger update of share profiles and all that jazz
      await updateProfileContact(newProfileContact!.coagContactId);
    }
  }

  // TODO: This method handles too many cases as indicated by the odd arguments; separate out into multiple
  Future<void> updateFromSystemContact(String coagContactId,
      {Contact? systemContact, bool tryRetrievingSystemContact = true}) async {
    final contact = getContact(coagContactId);
    if (contact?.systemContact == null) {
      return;
    }

    if (systemContact == null) {
      if (tryRetrievingSystemContact) {
        // Try if permissions are granted
        try {
          final systemContacts = await systemContactsStorage.getContacts();
          _systemContactAccessGrantedStreamController.add(true);

          systemContact = systemContacts
              .where((sc) => sc.id == contact!.systemContact!.id)
              .firstOrNull;
        } on MissingSystemContactsPermissionError {
          _systemContactAccessGrantedStreamController.add(false);
          return;
        }
      }

      // In case we neither got handed a system contact nor could we find one,
      // despite we have the permissions to check, remove the association
      if (systemContact == null) {
        // or in case there would not be any details left, fully remove contact
        if (contact!.details == null) {
          return removeContact(contact.coagContactId);
        }
        // TODO: This is prone to missing new schema fields; offer a copyWithoutSystemContact instead?!
        return saveContact(CoagContact(
          coagContactId: contact.coagContactId,
          details: contact.details,
          addressLocations: contact.addressLocations,
          temporaryLocations: contact.temporaryLocations,
          dhtSettingsForSharing: contact.dhtSettingsForSharing,
          dhtSettingsForReceiving: contact.dhtSettingsForReceiving,
          sharedProfile: contact.sharedProfile,
          mostRecentUpdate: contact.mostRecentUpdate,
          mostRecentChange: contact.mostRecentChange,
        ));
      } else {
        // TODO: Any more advanced updating magic needs to go here!
        return saveContact(contact!.copyWith(systemContact: systemContact));
      }
    }
  }

  /// Update all system contacts in case they changed and add missing ones
  // TODO: Test that there can be coagulate contacts with a system contact that isn't actually in the system
  Future<void> updateFromSystemContacts() async {
    // Try if permissions are granted
    try {
      final systemContacts = await systemContactsStorage.getContacts();
      _systemContactAccessGrantedStreamController.add(true);
      // Copy contacts here to deal with interference with parallel contact updates
      for (var coagContact in List<CoagContact>.from(_contacts.values)) {
        // Create system contacts for coagulate contacts that are not associated with one yet
        if (coagContact.systemContact == null &&
            await systemContactsStorage.requestPermission()) {
          // TODO: allow disabling this auto creation of system contacts?
          // Temporarily disable auto update callback when system contacts signal changes to avoid interfering contact updates
          // systemContactsChangedCallbackTemporarilyDisabled = true;
          // coagContact = coagContact.copyWith(
          //     systemContact: await systemContactsStorage
          //         .insertContact(coagContact.details!.toSystemContact()));
          // await saveContact(coagContact);
          // systemContactsChangedCallbackTemporarilyDisabled = false;
          continue;
        } else if (coagContact.systemContact != null) {
          // Remove contacts from queue that did not change
          // TODO: This could be coagContact.getSystemContactBasedOnSyncSettings
          //       in case we want to keep the original system contact for reference
          // NOTE: Object instance equals comparisons does not work, because we remove the photo / thumbnail
          final iContact = systemContacts.indexWhere(
              (c) => systemContactsEqual(c, coagContact.systemContact!));
          if (iContact != -1) {
            systemContacts.removeAt(iContact);
            continue;
          }
        }

        // The remaining matches based on system contact ID need to be updated
        final iChangedContact = systemContacts.indexWhere((systemContact) =>
            systemContact.id == coagContact.systemContact!.id);
        await updateFromSystemContact(coagContact.coagContactId,
            systemContact: (iChangedContact == -1)
                ? null
                : systemContacts[iChangedContact],
            tryRetrievingSystemContact: false);
        if (iChangedContact != -1) {
          systemContacts.removeAt(iChangedContact);
        }
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

  ///////////
  // CONTACTS

  Map<String, CoagContact> getContacts() => _contacts;

  CoagContact? getContact(String coagContactId) => _contacts[coagContactId];

  CoagContact? getContactForSystemContactId(String systemContactId) =>
      _contacts.values
          .firstWhere((c) => c.systemContact?.id == systemContactId);

  Future<void> removeContact(String coagContactId) async {
    _contacts.remove(coagContactId);
    _contactsStreamController.add(coagContactId);
    _circleMemberships.remove(coagContactId);
    final updateFutures = [
      persistentStorage.removeContact(coagContactId),
      persistentStorage.updateCircleMemberships(_circleMemberships)
    ];

    if (_profileContactId == coagContactId) {
      updateFutures.add(unsetProfileContact());
    }

    // TODO: change updates stream to just trigger refresh instead of carry the updates; or give each update an id and only stream these ids for when an update was added / removed
    _contactUpdates =
        _contactUpdates.where((u) => u.coagContactId != coagContactId).toList();

    await Future.wait(updateFutures);
  }

  /// Ensure the most recent profile contact details are shared with the contact
  /// identified by the given ID based on the current sharing settings and
  /// circle memberships
  Future<void> updateContactSharedProfile(String coagContactId) async {
    var contact = _contacts[coagContactId];
    final profileContact = getProfileContact();
    if (contact == null) {
      // TODO: Raise error that can be handled downstream
      return;
    }
    contact = contact.copyWith(
        sharedProfile: json.encode(removeNullOrEmptyValues(
            filterAccordingToSharingProfile(
                    // TODO: Double check what we set the shared profile to for an empty profile
                    profile: profileContact ??
                        CoagContact(
                            coagContactId: '', systemContact: Contact()),
                    settings: _profileSharingSettings,
                    activeCircles: _circleMemberships[coagContactId] ?? [],
                    shareBackSettings: contact.dhtSettingsForReceiving)
                .toJson())));
    contact = await distributedStorage.updateContactSharingDHT(contact);
    await saveContact(contact);
  }

  Future<void> updateContactSharingSettings(
      String coagContactId, ContactDHTSettings sharingSettings) async {
    if (!_contacts.containsKey(coagContactId)) {
      // TODO: Log and/or raise error?
      return;
    }
    // TODO: what if there were sharing settings before? do we clean up the old shared profile?
    final updatedContact = _contacts[coagContactId]!
        .copyWith(dhtSettingsForSharing: sharingSettings);
    // Save updated contact first, before triggering update of sharing profile
    // for the then already existing contact
    await saveContact(updatedContact);
    await updateContactSharedProfile(coagContactId);
  }

  Future<void> updateContactReceivingSettings(
      String coagContactId, ContactDHTSettings receivingSettings) async {
    if (!_contacts.containsKey(coagContactId)) {
      // TODO: Log and/or raise error?
      return;
    }
    final updatedContact = _contacts[coagContactId]!
        .copyWith(dhtSettingsForReceiving: receivingSettings);
    await saveContact(updatedContact);
    await updateContactFromDHT(updatedContact);
  }

  //////////
  // CIRCLES
  Map<String, String> getCircles() => _circles;

  Map<String, List<String>> getCircleMemberships() => _circleMemberships;

  Map<String, String> getCirclesForContact(String coagContactId) =>
      _circleMemberships[coagContactId]
          ?.where((circleId) => _circles.containsKey(circleId))
          .toList()
          .asMap()
          .map((_, circleId) => MapEntry(circleId, _circles[circleId]!)) ??
      {};

  List<String> getContactIdsForCircle(String circleId) => _circleMemberships
      .map((coagContactId, circleIds) => MapEntry(
          coagContactId, (circleIds.contains(circleId)) ? coagContactId : null))
      .values
      .whereType<String>()
      .toList();

  Future<void> addCircle(String circleId, String name) async {
    // TODO: handle id collisions; maybe don't allow passing an id as an arg but generate it safely in here
    _circles[circleId] = name;
    _circlesStreamController.add(null);
    await persistentStorage.updateCircles(_circles);
  }

  Future<void> updateCircleMemberships(
      Map<String, List<String>> memberships) async {
    _circleMemberships = memberships;

    // Notify about potentially affected contacts
    for (final coagContactId in memberships.keys) {
      _contactsStreamController.add(coagContactId);
    }

    await persistentStorage.updateCircleMemberships(memberships);

    await Future.wait([
      for (final contact in _contacts.values
          .where((c) => c.dhtSettingsForSharing?.psk != null))
        updateContactSharedProfile(contact.coagContactId)
    ]);
  }

  Future<void> updateCirclesForContact(
      String coagContactId, List<String> circleIds) async {
    _circleMemberships[coagContactId] = circleIds;
    // Notify about the update
    _contactsStreamController.add(coagContactId);
    await Future.wait([
      persistentStorage.updateCircleMemberships(_circleMemberships),
      updateContactSharedProfile(coagContactId)
    ]);
  }

  // TODO: Make this a pure utilities function instead for better testability?
  List<(String, String, bool, int)> circlesWithMembership(
          String coagContactId) =>
      _circles
          .map((id, label) => MapEntry(id, (
                id,
                label,
                (_circleMemberships[coagContactId] ?? []).contains(id),
                _circleMemberships.values
                    .where((circles) => circles.contains(id))
                    .length
              )))
          .values
          .toList();

  //////////////////
  // PROFILE CONTACT

  CoagContact? getProfileContact() =>
      (_profileContactId == null) ? null : _contacts[_profileContactId!];

  Future<void> unsetProfileContact() async {
    _profileContactId = null;
    _profileSharingSettings = const ProfileSharingSettings();
    // TODO: updating all contacts' shared profile data to empty
    await Future.wait([
      persistentStorage.removeProfileContactId(),
      persistentStorage.updateProfileSharingSettings(_profileSharingSettings)
    ]);
  }

  Future<void> updateProfileContact(String coagContactId) async {
    if (!_contacts.containsKey(coagContactId)) {
      return unsetProfileContact();
    }

    // TODO: Do we need to enforce writing to disk to make it available to background straight away?
    _profileContactId = coagContactId;
    await persistentStorage.setProfileContactId(coagContactId);

    if (_profileContactId != null) {
      // Ensure all system contacts changes are in
      await updateFromSystemContact(_profileContactId!);

      final profileContact = getProfileContact()!;
      final systemContact = await systemContactsStorage
          .getContact(profileContact.systemContact!.id);
      _systemContactAccessGrantedStreamController.add(true);

      // Automatically resolve addresses to coordinates
      // TODO: Only do this when enabled in the settings
      // TODO: Detect which addresses changed, and refetch more intelligently
      final addressLocations = <int, ContactAddressLocation>{};
      for (var i = 0; i < systemContact.addresses.length; i++) {
        final address = systemContact.addresses[i];
        // TODO: Also add some status indicator per address to show when unfetched, fetching, failed, fetched
        try {
          final locations = await locationFromAddress(address.address);
          final chosenLocation = locations[0];
          addressLocations[i] = ContactAddressLocation(
              coagContactId: profileContact.coagContactId,
              longitude: chosenLocation.longitude,
              latitude: chosenLocation.latitude,
              name: (address.label == AddressLabel.custom)
                  ? address.customLabel
                  : address.label.name);
        } on NoResultFoundException catch (e) {}
      }

      if (systemContact != profileContact.systemContact! ||
          addressLocations != profileContact.addressLocations) {
        final updatedContact = profileContact.copyWith(
            systemContact: systemContact, addressLocations: addressLocations);
        await saveContact(updatedContact);
      }
    }

    await updateSharingDHT();
  }

  Future<void> updateProfileContactData(CoagContact contact) async {
    await saveContact(contact);

    await Future.wait([
      for (final contact in _contacts.values
          .where((c) => c.dhtSettingsForSharing?.psk != null))
        updateContactSharedProfile(contact.coagContactId)
    ]);
  }

  /////////////////////////
  // PROFILE SHARE SETTINGS

  ProfileSharingSettings getProfileSharingSettings() => _profileSharingSettings;

  Future<void> setProfileSharingSettings(
      ProfileSharingSettings settings) async {
    _profileSharingSettings = settings;
    await persistentStorage.updateProfileSharingSettings(settings);

    if (getProfileContact() == null) {
      return;
    }

    await Future.wait([
      for (final contact in _contacts.values
          .where((c) => c.dhtSettingsForSharing?.psk != null))
        updateContactSharedProfile(contact.coagContactId)
    ]);
  }

  //////////
  // UPDATES

  Future<void> _saveUpdate(ContactUpdate update) async {
    _contactUpdates.add(update);
    _updatesStreamController.add(update);
    // TODO: Have two persistent storages with different prefixes for updates and contacts?
    //       Because we might not need to migrate the updates on app updates, but def the contacts.
    await persistentStorage.addUpdate(update);
  }

  List<ContactUpdate> getContactUpdates() => _contactUpdates;
}
