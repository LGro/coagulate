import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../veilid_processor/veilid_processor.dart';
import '../models/coag_contact.dart';
import '../models/contact_location.dart';
import '../models/contact_update.dart';
import '../models/profile_sharing_settings.dart';
import '../providers/distributed_storage/base.dart';
import '../providers/persistent_storage/base.dart';
import '../providers/system_contacts/base.dart';

const String defaultEveryoneCircleId = 'coag::everyone';

String contactDetailKey<T>(T detail) {
  if (detail is Organization) {
    return detail.company;
  }

  if (detail is Phone) {
    final label = (detail.label.name == 'custom')
        ? detail.customLabel
        : detail.label.name;
    return label;
  }
  if (detail is Email) {
    final label = (detail.label.name == 'custom')
        ? detail.customLabel
        : detail.label.name;
    return label;
  }
  if (detail is Address) {
    final label = (detail.label.name == 'custom')
        ? detail.customLabel
        : detail.label.name;
    return label;
  }
  if (detail is Website) {
    final label = (detail.label.name == 'custom')
        ? detail.customLabel
        : detail.label.name;
    return label;
  }
  if (detail is SocialMedia) {
    final label = (detail.label.name == 'custom')
        ? detail.customLabel
        : detail.label.name;
    return label;
  }
  if (detail is Event) {
    final label = (detail.label.name == 'custom')
        ? detail.customLabel
        : detail.label.name;
    return label;
  }

  // TODO: Return null or i instead?
  return '';
}

Map<String, String> filterNames(
  Map<String, String> names,
  Map<String, List<String>> settings,
  List<String> activeCircles,
) {
  if (activeCircles.isEmpty) {
    return {};
  }
  final updatedValues = {...names}..removeWhere((i, n) =>
      !(settings[i]?.asSet().intersectsWith(activeCircles.asSet()) ?? false));
  return updatedValues;
}

List<T> filterContactDetailsList<T>(
  List<T> values,
  Map<String, List<String>> settings,
  List<String> activeCircles,
) {
  if (activeCircles.isEmpty) {
    return [];
  }
  final updatedValues = {...values.asMap()}..removeWhere((i, e) =>
      !(settings[contactDetailKey(e)]
              ?.asSet()
              .intersectsWith(activeCircles.asSet()) ??
          false));
  return updatedValues.values.asList();
}

ContactDetails filterDetails(ContactDetails details,
        ProfileSharingSettings settings, List<String> activeCircles) =>
    ContactDetails(
      names: filterNames(details.names, settings.names, activeCircles),
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

Map<int, ContactAddressLocation> filterAddressLocations(
        Map<int, ContactAddressLocation> locations,
        ProfileSharingSettings settings,
        List<String> activeCircles) =>
    {
      // TODO: If we were also using "label" style keys for "locations", this could be simplified
      for (final location in locations.entries)
        if (({
                  for (final addressSetting in settings.addresses.entries)
                    int.parse(addressSetting.key.split('|').first):
                        addressSetting.value
                }[location.key]
                    ?.toSet() ??
                {})
            .intersection(activeCircles.toSet())
            .isNotEmpty)
          location.key: location.value
    };

/// Remove locations that ended longer than a day ago, or aren't shared with the given circles
List<ContactTemporaryLocation> filterTemporaryLocations(
        List<ContactTemporaryLocation> locations, List<String> activeCircles) =>
    locations
        .where((l) =>
            l.end.isAfter(DateTime.now()) &&
            l.circles.toSet().intersectsWith(activeCircles.toSet()))
        .asList();

CoagContactDHTSchema filterAccordingToSharingProfile(
        {required CoagContact profile,
        required ProfileSharingSettings settings,
        required List<String> activeCircles,
        required ContactDHTSettings? shareBackSettings}) =>
    CoagContactDHTSchema(
      details: filterDetails(profile.details!, settings, activeCircles),
      // Only share locations up to 1 day ago
      temporaryLocations:
          filterTemporaryLocations(profile.temporaryLocations, activeCircles),
      addressLocations: filterAddressLocations(
          profile.addressLocations, settings, activeCircles),
      shareBackDHTKey: shareBackSettings?.key,
      shareBackDHTWriter: shareBackSettings?.writer,
      shareBackPubKey: shareBackSettings?.pubKey,
    );

Map<String, dynamic> removeNullOrEmptyValues(Map<String, dynamic> json) {
  // TODO: implement me; or implement custom schema for sharing payload
  return json;
}

// TODO: This feels like it should live somewhere else
Future<TypedKeyPair> getAppUserKeyPair() async {
  const spKey = 'coag_app_user_key_pair';
  final sp = await SharedPreferences.getInstance();
  var keyPairString = sp.getString(spKey);
  if (keyPairString == null) {
    final keyPair = await DHTRecordPool.instance.veilid.bestCryptoSystem().then(
        (cs) => cs
            .generateKeyPair()
            .then((kp) => TypedKeyPair.fromKeyPair(cs.kind(), kp)));
    keyPairString = keyPair.toString();
    await sp.setString(spKey, keyPairString);
  }
  return TypedKeyPair.fromString(keyPairString);
  // TODO: Upgrade keypair to newer crypto system once available
}

class ContactsRepository {
  ContactsRepository(this.persistentStorage, this.distributedStorage,
      this.systemContactsStorage, this.initialName,
      {bool initialize = true}) {
    if (initialize) {
      unawaited(this.initialize());
    }
  }

  final String initialName;

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
    // Ensure it is initialized
    await getAppUserKeyPair();

    await initializeFromPersistentStorage();

    if (getProfileContact() == null && initialName.isNotEmpty) {
      final initialDetails = ContactDetails(names: {Uuid().v4(): initialName});
      final minimalProfileContact =
          CoagContact(coagContactId: Uuid().v4(), details: initialDetails);
      // Needs to be saved before setting
      await saveContact(minimalProfileContact);
      await setProfileContact(minimalProfileContact.coagContactId);
      // Add initial name to share with everyone, opt out possible later
      await setProfileSharingSettings(ProfileSharingSettings(names: {
        initialDetails.names.keys.first: const [defaultEveryoneCircleId]
      }));
    }

    // Ensure that everyone is part of the default circle
    if (!getCircles().containsKey(defaultEveryoneCircleId)) {
      // TODO: Localize
      await addCircle(defaultEveryoneCircleId, 'Everyone');
    }
    final circleMemberships = {...getCircleMemberships()};
    circleMemberships[defaultEveryoneCircleId] = [...getContacts().keys];
    await updateCircleMemberships(circleMemberships);

    // FIXME: System contact sync is disabled
    //await updateFromSystemContacts();
    //FlutterContacts.addListener(_systemContactsChangedCallback);

    // Update the contacts from DHT and subscribe to future updates
    await updateAndWatchReceivingDHT();

    // Update the shared profile with all contacts
    await updateSharingDHT();

    ProcessorRepository.instance
        .streamProcessorConnectionState()
        .listen(_veilidConnectionStateChangeCallback);
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

  //////
  // DHT
  Future<void> updateContactFromDHT(CoagContact contact) async {
    final updatedContact =
        await distributedStorage.getContact(contact, await getAppUserKeyPair());

    if (updatedContact != null) {
      final updateTime = DateTime.now();
      if (updatedContact == contact) {
        await saveContact(
            updatedContact.copyWith(mostRecentUpdate: updateTime));
      } else {
        // TODO: Use update time from when the update was sent not received
        // TODO: When temporary locations are updated, only record an update about added / updated locations / check-ins
        await _saveUpdate(ContactUpdate(
            // TODO: contact details can be null; handle this more appropriately than the current workaround with empty details
            coagContactId: contact.coagContactId,
            oldContact: contact.details ?? const ContactDetails(),
            newContact: updatedContact.details ?? const ContactDetails(),
            timestamp: DateTime.now()));

        await saveContact(updatedContact.copyWith(
            mostRecentUpdate: updateTime, mostRecentChange: updateTime));
      }
    }

    if (contact.dhtSettingsForReceiving != null) {
      await distributedStorage.watchRecord(
          contact.dhtSettingsForReceiving!.key, _dhtRecordUpdateCallback);
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
    // TODO: Also handle network unavailable changes?
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

  Future<bool> updateAndWatchReceivingDHT({bool shuffle = false}) async {
    if (!ProcessorRepository
        .instance.processorConnectionState.attachment.publicInternetReady) {
      veilidNetworkAvailable = false;
      return false;
    }
    veilidNetworkAvailable = true;
    final contacts = _contacts.values.toList();
    if (shuffle) {
      contacts.shuffle();
    }

    // TODO: Can we parallelize this? with Future.wait([])?
    for (final contact in contacts) {
      // Check for incoming updates
      if (contact.dhtSettingsForReceiving != null) {
        await updateContactFromDHT(contact);
      }
    }

    return true;
  }

  /// Update the "me-to-them" record for a given contact and update dht settings
  Future<void> tryShareWithContactDHT(CoagContact contact,
      {bool initializeReceivingSettings = false, String? contactPubKey}) async {
    try {
      if (contact.dhtSettingsForSharing?.writer == null) {
        final (shareKey, shareWriter) = await distributedStorage.createRecord();
        final dhtSettingsForSharing = ContactDHTSettings(
            key: shareKey,
            writer: shareWriter,
            // TODO: Get specific cryptosystem version? also, move veilid specific stuff elsewhere
            psk: (contactPubKey == null)
                ? await Veilid.instance.bestCryptoSystem().then(
                    (cs) => cs.randomSharedSecret().then((v) => v.toString()))
                : null,
            pubKey: contactPubKey);

        // TODO: Is a refresh of the contact before updating necessary?
        contact = getContact(contact.coagContactId)!
            .copyWith(dhtSettingsForSharing: dhtSettingsForSharing);
        await saveContact(contact);
      }
      if (initializeReceivingSettings) {
        final (receiveKey, receiveWriter) =
            await distributedStorage.createRecord();
        final dhtSettingsForReceiving = ContactDHTSettings(
            key: receiveKey,
            writer: receiveWriter,
            pubKey: await getAppUserKeyPair()
                .then((kp) => '${cryptoKindToString(kp.kind)}:${kp.key}'));
        // Write to it once to populate it
        try {
          await distributedStorage.updateRecord(
              content: '',
              key: dhtSettingsForReceiving!.key,
              writer: dhtSettingsForReceiving!.writer!,
              publicKey: dhtSettingsForReceiving?.pubKey,
              psk: dhtSettingsForReceiving?.psk);
        } on VeilidAPIException catch (e) {
          // TODO: Proper logging / other handling strategy / retry?
          if (kDebugMode) {
            print(e);
          }
        }

        // TODO: Is a refresh of the contact before updating necessary?
        contact = getContact(contact.coagContactId)!
            .copyWith(dhtSettingsForReceiving: dhtSettingsForReceiving);
        await saveContact(contact);

        // Ensure shared profile contains all the updated share and share back
        await updateContactSharedProfile(contact.coagContactId);
        contact = getContact(contact.coagContactId)!;
      }

      await distributedStorage.updateRecord(
          content: contact.sharedProfile ?? '',
          key: contact.dhtSettingsForSharing!.key,
          writer: contact.dhtSettingsForSharing!.writer!,
          publicKey: contact.dhtSettingsForSharing?.pubKey,
          psk: contact.dhtSettingsForSharing?.psk);
    } on VeilidAPIException catch (e) {
      // TODO: Proper logging / other handling strategy / retry?
      if (kDebugMode) {
        print(e);
      }
    }
  }

  /// Update the DHT "me-to-them" records for all contacts
  Future<void> updateSharingDHT() async {
    if (!ProcessorRepository
        .instance.processorConnectionState.attachment.publicInternetReady) {
      veilidNetworkAvailable = false;
      return;
    }
    veilidNetworkAvailable = true;

    // With many contacts, can this run into parallel DHT write limitations?
    await Future.wait([
      for (final contact
          in _contacts.values.where((c) => c.sharedProfile != null))
        tryShareWithContactDHT(contact)
    ]);
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
    final contact = _contacts[coagContactId];
    if (contact == null) {
      // TODO: Raise error that can be handled downstream
      return;
    }

    final profileContact = getProfileContact();
    if (profileContact?.details == null) {
      return;
    }

    await saveContact(contact.copyWith(
        sharedProfile: json.encode(removeNullOrEmptyValues(
            filterAccordingToSharingProfile(
                    profile: profileContact!,
                    settings: _profileSharingSettings,
                    activeCircles: _circleMemberships[coagContactId] ?? [],
                    shareBackSettings: contact.dhtSettingsForReceiving)
                .toJson()))));
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
    unawaited(updateContactFromDHT(updatedContact));
  }

  Future<void> _dhtRecordUpdateCallback(String key) async {
    for (final contact in _contacts.values) {
      if (key == contact.dhtSettingsForReceiving?.key) {
        return updateContactFromDHT(contact);
      }
    }
  }

  /// Creating contact from just a name or from a profile link, i.e. with name
  /// and public key
  Future<CoagContact> createContactForInvite(String name,
      {String? pubKey}) async {
    // Create contact
    final contact = CoagContact(
        coagContactId: Uuid().v4(),
        details: ContactDetails(names: {Uuid().v4(): name}));
    await saveContact(contact);

    // Add to default circle and update shared profile
    await updateCirclesForContact(
        contact.coagContactId, [defaultEveryoneCircleId]);

    // Trigger sharing, incl. DHT record creation
    unawaited(tryShareWithContactDHT(contact,
        initializeReceivingSettings: true, contactPubKey: pubKey));

    return contact;
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

  Future<void> setProfileContact(String coagContactId) async {
    if (!_contacts.containsKey(coagContactId)) {
      return unsetProfileContact();
    }
    // TODO: Do we need to enforce writing to disk to make it available to background straight away?
    _profileContactId = coagContactId;
    await persistentStorage.setProfileContactId(coagContactId);

    // Ensure the profile page refreshes; might warrant a separate even stream?
    _contactsStreamController.add(coagContactId);
  }

  Future<void> updateProfileContactData(CoagContact contact) async {
    // TODO: Validity checks that id matches current profile contact?

    await saveContact(contact);

    await Future.wait([
      for (final contact in _contacts.values
          .where((c) => c.dhtSettingsForSharing?.psk != null))
        updateContactSharedProfile(contact.coagContactId)
    ]);

    unawaited(updateSharingDHT());
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
