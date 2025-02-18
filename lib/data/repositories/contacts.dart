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
  Iterable<String> activeCircles,
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
  Iterable<String> activeCircles,
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

List<int>? selectAvatar(Map<String, List<int>> avatars,
        Map<String, int> activeCirclesWithMemberCount) =>
    avatars.entries
        .where((e) => activeCirclesWithMemberCount.containsKey(e.key))
        .sorted((a, b) =>
            (activeCirclesWithMemberCount[a.key] ?? 0) -
            (activeCirclesWithMemberCount[b.key] ?? 0))
        .firstOrNull
        ?.value;

ContactDetails filterDetails(
        Map<String, List<int>> avatars,
        ContactDetails details,
        ProfileSharingSettings settings,
        Map<String, int> activeCirclesWithMemberCount) =>
    ContactDetails(
      avatar: selectAvatar(avatars, activeCirclesWithMemberCount),
      names: filterNames(
          details.names, settings.names, activeCirclesWithMemberCount.keys),
      phones: filterContactDetailsList(
          details.phones, settings.phones, activeCirclesWithMemberCount.keys),
      emails: filterContactDetailsList(
          details.emails, settings.emails, activeCirclesWithMemberCount.keys),
      addresses: filterContactDetailsList(details.addresses, settings.addresses,
          activeCirclesWithMemberCount.keys),
      organizations: filterContactDetailsList(details.organizations,
          settings.organizations, activeCirclesWithMemberCount.keys),
      websites: filterContactDetailsList(details.websites, settings.websites,
          activeCirclesWithMemberCount.keys),
      socialMedias: filterContactDetailsList(details.socialMedias,
          settings.socialMedias, activeCirclesWithMemberCount.keys),
      events: filterContactDetailsList(
          details.events, settings.events, activeCirclesWithMemberCount.keys),
    );

Map<int, ContactAddressLocation> filterAddressLocations(
        Map<int, ContactAddressLocation> locations,
        ProfileSharingSettings settings,
        Iterable<String> activeCircles) =>
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
        List<ContactTemporaryLocation> locations,
        Iterable<String> activeCircles) =>
    locations
        .where((l) =>
            l.end.isAfter(DateTime.now()) &&
            l.circles.toSet().intersectsWith(activeCircles.toSet()))
        .asList();

CoagContactDHTSchema filterAccordingToSharingProfile(
        {required ProfileInfo profile,
        required Map<String, int> activeCirclesWithMemberCount,
        required ContactDHTSettings? shareBackSettings}) =>
    CoagContactDHTSchema(
      details: filterDetails(profile.pictures, profile.details,
          profile.sharingSettings, activeCirclesWithMemberCount),
      // Only share locations up to 1 day ago
      temporaryLocations: filterTemporaryLocations(
          profile.temporaryLocations, activeCirclesWithMemberCount.keys),
      addressLocations: filterAddressLocations(profile.addressLocations,
          profile.sharingSettings, activeCirclesWithMemberCount.keys),
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

  /// Profile info
  ProfileInfo _profileInfo = const ProfileInfo();
  final _profileInfoStreamController = BehaviorSubject<ProfileInfo>();
  Stream<ProfileInfo> getProfileInfoStream() =>
      _profileInfoStreamController.asBroadcastStream();

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
    // Ensure it is called once to initialize
    await getAppUserKeyPair();

    await initializeFromPersistentStorage();

    // Initialize profile info
    if (_profileInfo.details.names.isEmpty && initialName.isNotEmpty) {
      final nameId = Uuid().v4();
      await setProfileInfo(ProfileInfo(
          details: ContactDetails(names: {nameId: initialName}),
          sharingSettings: ProfileSharingSettings(names: {
            nameId: const [defaultEveryoneCircleId]
          })));
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
    _profileInfo = await persistentStorage.getProfileInfo();
    _profileInfoStreamController.add(_profileInfo);

    // Initialize circles, circle memberships from persistent storage
    _circles = await persistentStorage.getCircles();
    _circleMemberships = await persistentStorage.getCircleMemberships();

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
    _contacts[coagContact.coagContactId] = coagContact.copyWith();
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

  /// Get a copy of all contacts
  Map<String, CoagContact> getContacts() => {..._contacts};

  CoagContact? getContact(String coagContactId) =>
      _contacts[coagContactId]?.copyWith();

  CoagContact? getContactForSystemContactId(String systemContactId) =>
      _contacts.values
          .firstWhereOrNull((c) => c.systemContact?.id == systemContactId)
          ?.copyWith();

  Future<void> removeContact(String coagContactId) async {
    _contacts.remove(coagContactId);
    _contactsStreamController.add(coagContactId);
    _circleMemberships.remove(coagContactId);
    final updateFutures = [
      persistentStorage.removeContact(coagContactId),
      persistentStorage.updateCircleMemberships(_circleMemberships)
    ];

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

    await saveContact(contact.copyWith(
        sharedProfile: json.encode(removeNullOrEmptyValues(
            filterAccordingToSharingProfile(
                    profile: _profileInfo,
                    // TODO: Also expose this view of the data from contacts repo?
                    //       Seems to be used in different places.
                    activeCirclesWithMemberCount: Map.fromEntries(
                        (_circleMemberships[coagContactId] ?? []).map(
                            (circleId) => MapEntry(
                                circleId,
                                _circleMemberships.values
                                    .where((ids) => ids.contains(circleId))
                                    .length))),
                    shareBackSettings: contact.dhtSettingsForReceiving)
                .toJson()))));
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
    final contact = CoagContact(coagContactId: Uuid().v4(), name: name);
    await saveContact(contact);

    // Add to default circle and update shared profile
    await updateCirclesForContact(
        contact.coagContactId, [defaultEveryoneCircleId],
        // Trigger dht update with custom arguments below instead
        triggerDhtUpdate: false);

    // Trigger sharing, incl. DHT record creation
    unawaited(tryShareWithContactDHT(contact,
        initializeReceivingSettings: true, contactPubKey: pubKey));

    return contact;
  }

  //////////
  // CIRCLES
  Map<String, String> getCircles() => {..._circles};

  Map<String, List<String>> getCircleMemberships() => {..._circleMemberships};

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
    _circleMemberships = {...memberships};

    // Notify about potentially affected contacts
    for (final coagContactId in _circleMemberships.keys) {
      _contactsStreamController.add(coagContactId);
    }

    await persistentStorage.updateCircleMemberships(_circleMemberships);

    await Future.wait([
      for (final contact in _contacts.values
          .where((c) => c.dhtSettingsForSharing?.psk != null))
        updateContactSharedProfile(contact.coagContactId)
    ]);
  }

  Future<void> updateCirclesForContact(
      String coagContactId, List<String> circleIds,
      {bool triggerDhtUpdate = true}) async {
    _circleMemberships[coagContactId] = [...circleIds];
    // Notify about the update
    _contactsStreamController.add(coagContactId);
    await Future.wait([
      persistentStorage.updateCircleMemberships(_circleMemberships),
      updateContactSharedProfile(coagContactId)
    ]);

    // Trigger DHT update
    final contact = getContact(coagContactId);
    if (contact != null && triggerDhtUpdate) {
      unawaited(tryShareWithContactDHT(contact));
    }
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
  // PROFILE INFO

  ProfileInfo getProfileInfo() => _profileInfo.copyWith();

  Future<void> setProfileInfo(ProfileInfo profileInfo) async {
    // Update
    _profileInfo = profileInfo.copyWith();

    // Persist
    await persistentStorage.updateProfileInfo(_profileInfo);

    // Notify
    _profileInfoStreamController.add(_profileInfo.copyWith());

    // Update shared profile data for all contacts individually
    // NOTE: Having this before and not as part of updateSharingDHT can cause
    //       the UI to already show update info, even though it is not yet sent
    await Future.wait([
      for (final contact in _contacts.values)
        updateContactSharedProfile(contact.coagContactId)
    ]);

    // Trigger sending out shared info via DHT
    unawaited(updateSharingDHT());
  }

  //////////
  // UPDATES

  Future<void> _saveUpdate(ContactUpdate update) async {
    _contactUpdates.add(update.copyWith());
    _updatesStreamController.add(update.copyWith());
    // TODO: Have two persistent storages with different prefixes for updates and contacts?
    //       Because we might not need to migrate the updates on app updates, but def the contacts.
    await persistentStorage.addUpdate(update);
  }

  List<ContactUpdate> getContactUpdates() => [..._contactUpdates];
}
