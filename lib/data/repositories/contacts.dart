// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:rxdart/subjects.dart';
import 'package:uuid/uuid.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../veilid_processor/veilid_processor.dart';
import '../models/batch_invites.dart';
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

List<int>? selectPicture(Map<String, List<int>> avatars,
        Map<String, int> activeCirclesWithMemberCount) =>
    avatars.entries
        .where((e) => activeCirclesWithMemberCount.containsKey(e.key))
        .sorted((a, b) =>
            (activeCirclesWithMemberCount[a.key] ?? 0) -
            (activeCirclesWithMemberCount[b.key] ?? 0))
        .firstOrNull
        ?.value;

ContactDetails filterDetails(
        Map<String, List<int>> pictures,
        ContactDetails details,
        ProfileSharingSettings settings,
        Map<String, int> activeCirclesWithMemberCount) =>
    ContactDetails(
      picture: selectPicture(pictures, activeCirclesWithMemberCount),
      publicKey: details.publicKey,
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

/// Remove locations that ended longer than a day ago,s
/// or aren't shared with the given circles if provided
Map<String, ContactTemporaryLocation> filterTemporaryLocations(
        Map<String, ContactTemporaryLocation> locations,
        [Iterable<String>? activeCircles]) =>
    Map.fromEntries(locations.entries.where((l) =>
        l.value.end.isAfter(DateTime.now()) &&
        (activeCircles == null ||
            l.value.circles.toSet().intersectsWith(activeCircles.toSet()))));

CoagContactDHTSchema filterAccordingToSharingProfile(
        {required ProfileInfo profile,
        required Map<String, int> activeCirclesWithMemberCount,
        required DhtSettings dhtSettings,
        required bool sharePersonalUniqueId,
        List<String> knownPersonalContactIds = const []}) =>
    CoagContactDHTSchema(
      personalUniqueId: sharePersonalUniqueId ? profile.id : null,
      details: filterDetails(profile.pictures, profile.details,
          profile.sharingSettings, activeCirclesWithMemberCount),
      // Only share locations up to 1 day ago
      temporaryLocations: filterTemporaryLocations(
          profile.temporaryLocations, activeCirclesWithMemberCount.keys),
      addressLocations: filterAddressLocations(profile.addressLocations,
          profile.sharingSettings, activeCirclesWithMemberCount.keys),
      shareBackDHTKey: dhtSettings.recordKeyThemSharing.toString(),
      shareBackDHTWriter: dhtSettings.writerThemSharing.toString(),
      shareBackPubKey: dhtSettings.myKeyPair.key.toString(),
      knownPersonalContactIds: knownPersonalContactIds,
      ackHandshakeComplete: dhtSettings.theirPublicKey != null,
    );

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
  ProfileInfo? _profileInfo;
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

  final Map<Typed<FixedEncodedString43>, BatchInvite> _batchInvites = {};

  Timer? updateFromDhtTimer;

  Future<void> initialize({bool scheduleRegularUpdates = true}) async {
    await initializeFromPersistentStorage();

    // Initialize profile info
    if (_profileInfo == null) {
      final nameId = Uuid().v4();
      await setProfileInfo(ProfileInfo(Uuid().v4(),
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

    if (scheduleRegularUpdates) {
      // updateFromDhtTimer = Timer.periodic(
      //     const Duration(seconds: 5),
      //     (t) async => updateAndWatchReceivingDHT(shuffle: true)
      //         .timeout(const Duration(seconds: 4)));
    }
  }

  /////////////////////
  // PERSISTENT STORAGE
  Future<void> initializeFromPersistentStorage() async {
    _profileInfo = await persistentStorage.getProfileInfo();
    if (_profileInfo != null) {
      _profileInfoStreamController.add(_profileInfo!);
    }

    // Initialize circles, circle memberships from persistent storage
    _circles = await persistentStorage.getCircles();
    _circleMemberships = await persistentStorage.getCircleMemberships();
    _circlesStreamController.add(null);

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

    // Load all batches and update
    final batches = await persistentStorage.getBatches();
    _batchInvites
        .addAll(Map.fromEntries(batches.map((b) => MapEntry(b.recordKey, b))));
    await Future.wait(_batchInvites.values.map(batchInviteUpdate));
  }

  Future<void> saveContact(CoagContact coagContact) async {
    _contacts[coagContact.coagContactId] = coagContact.copyWith();
    _contactsStreamController.add(coagContact.coagContactId);
    await persistentStorage.updateContact(coagContact);
  }

  //////
  // DHT
  Future<bool> updateContactFromDHT(CoagContact contact) async {
    var success = false;
    final updatedContact = await distributedStorage.getContact(contact);

    if (updatedContact != null) {
      success = true;
      final updateTime = DateTime.now();
      if (updatedContact == contact) {
        await saveContact(
            updatedContact.copyWith(mostRecentUpdate: updateTime));
      } else {
        if (!getContactUpdates()
            .map((u) => u.newContact.hashCode)
            .contains(updatedContact.hashCode)) {
          await _saveUpdate(ContactUpdate(
              coagContactId: contact.coagContactId,
              oldContact: CoagContact(
                  coagContactId: contact.coagContactId,
                  name: contact.name,
                  dhtSettings: contact.dhtSettings.copyWith(),
                  details: contact.details?.copyWith(),
                  temporaryLocations: {...contact.temporaryLocations},
                  addressLocations: {...contact.addressLocations}),
              newContact: CoagContact(
                  coagContactId: updatedContact.coagContactId,
                  name: updatedContact.name,
                  dhtSettings: updatedContact.dhtSettings.copyWith(),
                  details: updatedContact.details?.copyWith(),
                  temporaryLocations: {...updatedContact.temporaryLocations},
                  addressLocations: {...updatedContact.addressLocations}),
              // TODO: Use update time from when the update was sent not received
              timestamp: DateTime.now()));
        }

        await saveContact(updatedContact.copyWith(
            mostRecentUpdate: updateTime, mostRecentChange: updateTime));

        // When it's the first time they acknowledge a completed handshake,
        // trigger an update of the sharing DHT record to switch from the
        // initial secret to a public key derived one
        if (!contact.dhtSettings.theyAckHandshakeComplete &&
            updatedContact.dhtSettings.theyAckHandshakeComplete) {
          // TODO: This could be directly "distributedStorage.updateRecord"
          //       with error handling.
          await tryShareWithContactDHT(updatedContact);
        }
      }
    }

    if (contact.dhtSettings.recordKeyThemSharing != null) {
      await distributedStorage.watchRecord(
          contact.dhtSettings.recordKeyThemSharing!, _dhtRecordUpdateCallback);
    }

    return success;
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
        (c) => c.dhtSettings.recordKeyThemSharing == update.key);
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

    // TODO: Can we parallelize this? with Future.wait([]) like below?
    for (final contact in contacts) {
      // Check for incoming updates
      if (contact.dhtSettings.recordKeyThemSharing != null) {
        await updateContactFromDHT(contact);
      }
    }

    await Future.wait(_batchInvites.values.map(batchInviteUpdate));

    return true;
  }

  /// Update the "me-to-them" record for a given contact and update dht settings
  // TODO: Sometimes we pass a full contact instance, sometimes just the id - what are benefits and downsides? does it make sense to unify?
  Future<bool> tryShareWithContactDHT(CoagContact contact,
      {bool initializeReceivingSettings = false,
      PublicKey? contactPubKey}) async {
    try {
      // NOTE: This assumes that when we have a record key to receive, it will
      //       eventually provide us with sharing back settings
      if (contact.dhtSettings.writerMeSharing == null &&
          contact.dhtSettings.recordKeyThemSharing == null) {
        final (shareKey, shareWriter) = await distributedStorage.createRecord();

        // TODO: Get specific cryptosystem version? also, move veilid specific stuff elsewhere
        final initialSecret = (contactPubKey == null &&
                contact.dhtSettings.theirPublicKey == null)
            ? await Veilid.instance
                .bestCryptoSystem()
                .then((cs) => cs.randomSharedSecret())
            : null;

        // TODO: Is a refresh of the contact before updating necessary?
        contact = getContact(contact.coagContactId)!;
        contact = contact.copyWith(
            dhtSettings: contact.dhtSettings.copyWith(
                recordKeyMeSharing: shareKey,
                writerMeSharing: shareWriter,
                theirPublicKey: contactPubKey,
                initialSecret: initialSecret));
        await saveContact(contact);
      }

      if (initializeReceivingSettings) {
        final (receiveKey, receiveWriter) =
            await distributedStorage.createRecord();
        // TODO: Is a refresh of the contact before updating necessary?
        contact = getContact(contact.coagContactId)!;
        contact = contact.copyWith(
            dhtSettings: contact.dhtSettings.copyWith(
                recordKeyThemSharing: receiveKey,
                writerThemSharing: receiveWriter));
        await saveContact(contact);

        // Ensure shared profile contains all the updated share and share back
        await updateContactSharedProfile(contact.coagContactId);
        contact = getContact(contact.coagContactId)!;
      }

      await distributedStorage.updateRecord(
          contact.sharedProfile, contact.dhtSettings);

      return true;
    } on VeilidAPIException catch (e) {
      // TODO: Proper logging / other handling strategy / retry?
      if (kDebugMode) {
        print(e);
      }
      return false;
    }
  }

  /// Update the DHT "me-to-them" records for all contacts
  Future<bool> updateSharingDHT() async {
    if (!ProcessorRepository
        .instance.processorConnectionState.attachment.publicInternetReady) {
      veilidNetworkAvailable = false;
      return false;
    }
    veilidNetworkAvailable = true;

    // With many contacts, can this run into parallel DHT write limitations?
    await Future.wait([
      for (final contact
          in _contacts.values.where((c) => c.sharedProfile != null))
        tryShareWithContactDHT(contact)
    ]);

    return true;
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
    if (contact == null || _profileInfo == null) {
      // TODO: Raise error that can be handled downstream
      return;
    }

    await saveContact(contact.copyWith(
        sharedProfile: filterAccordingToSharingProfile(
            profile: _profileInfo!,
            // TODO: Also expose this view of the data from contacts repo?
            //       Seems to be used in different places.
            activeCirclesWithMemberCount: Map.fromEntries(
                (_circleMemberships[coagContactId] ?? []).map((circleId) =>
                    MapEntry(
                        circleId,
                        _circleMemberships.values
                            .where((ids) => ids.contains(circleId))
                            .length))),
            dhtSettings: contact.dhtSettings,
            // TODO: Do we need to trigger updating the sharing profile more often to keep this list up to date?
            // TODO: Allow opt-out (per circle or globally?)
            sharePersonalUniqueId: true,
            knownPersonalContactIds: getContacts()
                .values
                .map((c) => c.theirPersonalUniqueId)
                .where((id) => id != contact.theirPersonalUniqueId)
                // Remove null entries
                .whereType<String>()
                // Remove duplicates
                .toSet()
                .toList())));
  }

  Future<void> _dhtRecordUpdateCallback(Typed<FixedEncodedString43> key) async {
    for (final contact in _contacts.values) {
      if (key == contact.dhtSettings.recordKeyThemSharing) {
        await updateContactFromDHT(contact);
        return;
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
        name: name,
        dhtSettings: DhtSettings(
            myKeyPair: await DHTRecordPool.instance.veilid
                .bestCryptoSystem()
                .then((cs) => cs
                    .generateKeyPair()
                    .then((kp) => TypedKeyPair.fromKeyPair(cs.kind(), kp)))));
    await saveContact(contact);

    // Add to default circle and update shared profile
    await updateCirclesForContact(
        contact.coagContactId, [defaultEveryoneCircleId],
        // Trigger dht update with custom arguments below instead
        triggerDhtUpdate: false);

    // Trigger sharing, incl. DHT record creation
    unawaited(tryShareWithContactDHT(contact,
        initializeReceivingSettings: true,
        contactPubKey:
            (pubKey == null) ? null : FixedEncodedString43.fromString(pubKey)));

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

    // Update all shared profiles regardless of the current DHT sharing status
    await Future.wait([
      for (final contact in _contacts.values)
        updateContactSharedProfile(contact.coagContactId)
    ]);
  }

  Future<void> updateCirclesForContact(
      String coagContactId, List<String> circleIds,
      {bool triggerDhtUpdate = true}) async {
    _circleMemberships[coagContactId] = [...circleIds];
    // Notify about the update
    _contactsStreamController.add(coagContactId);
    _circlesStreamController.add(null);
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

  ProfileInfo? getProfileInfo() => _profileInfo?.copyWith();

  Future<void> setProfileInfo(ProfileInfo profileInfo) async {
    // Update
    _profileInfo = profileInfo.copyWith();

    // Persist
    await persistentStorage.updateProfileInfo(_profileInfo!);

    // Notify
    _profileInfoStreamController.add(_profileInfo!.copyWith());

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

  // TODO: Also clean up unnecessary updates from persistent storage
  List<ContactUpdate> getContactUpdates() => [..._contactUpdates];

  ////////////////
  // BATCH INVITES

  Future<void> handleBatchInvite(
      String myNameId,
      Typed<FixedEncodedString43> recordKey,
      FixedEncodedString43 psk,
      int mySubkey,
      KeyPair subkeyWriter) async {
    // If we already know about this invite, don't do anything
    final existingBatch = _batchInvites[recordKey];
    if (existingBatch != null) {
      await batchInviteUpdate(existingBatch);
      return;
    }

    // read meta info from first subkey, decrypt with psk
    // TODO: Factor out into helper for simple read
    final crypto =
        await VeilidCryptoPrivate.fromSharedSecret(recordKey.kind, psk);
    final record = await DHTRecordPool.instance
        .openRecordRead(recordKey, debugName: 'coag::read', crypto: crypto);
    Uint8List? batchInfoRaw;
    try {
      batchInfoRaw = await record.get(
          crypto: crypto, refreshMode: DHTRecordRefreshMode.network, subkey: 0);
    } on FormatException catch (e) {
    } finally {
      await record.close();
    }
    if (batchInfoRaw == null) {
      return;
    }
    final batchInfo = BatchInviteInfoSchema.fromJson(
        jsonDecode(utf8.decode(batchInfoRaw)) as Map<String, dynamic>);

    // create circle from label with id from record key
    await addCircle(recordKey.toString(), batchInfo.label);

    final profileInfo = getProfileInfo();

    if (profileInfo == null) {
      return;
    }

    // TODO: Update sharing profile for circle to include name
    final myName =
        profileInfo.details.names[myNameId] ?? '${batchInfo.label} $mySubkey';

    // generate one keypair to use for all contacts in that batch
    final batchKeyPair = await DHTRecordPool.instance.veilid
        .bestCryptoSystem()
        .then((cs) => cs
            .generateKeyPair()
            .then((kp) => TypedKeyPair.fromKeyPair(cs.kind(), kp)));

    // TODO: Detect if someone has already written to my subkey and raise error

    // write pubkey and name to own subkey
    // TODO: Factor out into helper for simple write
    final mySubkeyRecord = await DHTRecordPool.instance.openRecordWrite(
        recordKey, subkeyWriter,
        debugName: 'coag::write-batch-subkey',
        crypto: crypto,
        defaultSubkey: mySubkey);
    final mySubkeyContent =
        BatchSubkeySchema(myName, batchKeyPair.key, const {});
    await mySubkeyRecord
        .tryWriteBytes(utf8.encode(jsonEncode(mySubkeyContent.toJson())));
    await mySubkeyRecord.close();

    final batch = BatchInvite(
        label: batchInfo.label,
        expiration: batchInfo.expiration,
        recordKey: recordKey,
        psk: psk,
        subkeyCount: record.subkeyCount,
        mySubkey: mySubkey,
        subkeyWriter: subkeyWriter,
        myName: myName,
        myKeyPair: batchKeyPair);

    _batchInvites[batch.recordKey] = batch;
    await persistentStorage.addBatch(batch);

    await batchInviteUpdate(batch);
  }

  // TODO: regularly run for all batches
  // TODO: how to deal with race condition of two folks setting things up in parallel, who wins? make it unidirectional, no share back settings or override share back settings? is this really an issue?
  Future<void> batchInviteUpdate(BatchInvite batch) async {
    // Do not check expired invite batches
    if (DateTime.now().isAfter(batch.expiration)) {
      // TODO: Do we clean up / mark contacts that didn't successfully connect?
      return;
    }

    final crypto = await VeilidCryptoPrivate.fromSharedSecret(
        batch.recordKey.kind, batch.psk);

    // get current record matches
    final myConnectionRecords = {...batch.myConnectionRecords};

    // iterate over other subkeys, to
    for (var subkey = 1; subkey < batch.subkeyCount; subkey++) {
      if (subkey == batch.mySubkey) {
        continue;
      }

      final record = await DHTRecordPool.instance.openRecordRead(
          batch.recordKey,
          debugName: 'coag::read',
          crypto: crypto);
      Uint8List? contactSubkeyContentRaw;
      try {
        contactSubkeyContentRaw = await record.get(
            crypto: crypto,
            refreshMode: DHTRecordRefreshMode.network,
            subkey: subkey);
      } on FormatException catch (e) {
      } on VeilidAPIException {
        continue;
      } finally {
        await record.close();
      }
      if (contactSubkeyContentRaw == null) {
        continue;
      }
      final contactSubkeyContent = BatchSubkeySchema.fromJson(
          jsonDecode(utf8.decode(contactSubkeyContentRaw))
              as Map<String, dynamic>);

      // Get existing contact if available
      var contact = getContacts()
          .values
          .where((c) =>
              c.dhtSettings.theirPublicKey == contactSubkeyContent.publicKey)
          .firstOrNull;

      // or create new contact if not yet exists
      if (contact == null) {
        contact = CoagContact(
          coagContactId: Uuid().v4(),
          name: contactSubkeyContent.name,
          dhtSettings: DhtSettings(
              theyAckHandshakeComplete: true,
              theirPublicKey: contactSubkeyContent.publicKey,
              myKeyPair: batch.myKeyPair),
        );
        await saveContact(contact);
        await updateCirclesForContact(
            contact.coagContactId,
            // Add to default circle and update shared profile
            [defaultEveryoneCircleId, batch.recordKey.toString()],
            // Trigger dht update with custom arguments below instead
            triggerDhtUpdate: false);
      }

      // If contact subkey contains pubkey I haven't successfully created a
      // DHT sharing record for before, create DHT record and write with pubkey
      // to my subkey
      // NOTE: This is separate from the contact creation above because while we
      // usually succeed creating a new contact, initializing the sharing might
      // fail, so we need to be able to retry here.
      if (!myConnectionRecords
          .containsKey(contactSubkeyContent.publicKey.toString())) {
        // Trigger sharing, incl. DHT record creation and update contact
        await tryShareWithContactDHT(contact,
            contactPubKey: contact.dhtSettings.theirPublicKey);
        contact = getContact(contact.coagContactId);

        if (contact?.dhtSettings.recordKeyMeSharing != null) {
          myConnectionRecords[contactSubkeyContent.publicKey.toString()] =
              contact!.dhtSettings.recordKeyMeSharing!;
        } else {
          // this should happen only when record creation fails in
          // trysharewithcontactdht?
          print('missing share key for batch offer');
        }
      }

      // If contact subkey contains my pubkey with a dht record key,
      // create contact, add to batch circle and fetch from said record
      if (contact?.dhtSettings.recordKeyThemSharing == null &&
          contactSubkeyContent.records
              .containsKey(batch.myKeyPair.key.toString())) {
        contact = contact?.copyWith(
            dhtSettings: contact.dhtSettings.copyWith(
                recordKeyThemSharing: contactSubkeyContent
                    .records[batch.myKeyPair.key.toString()]));
        if (contact != null) {
          // Save even if update from DHT fails
          await saveContact(contact);
          // Try updating from DHT
          await updateContactFromDHT(contact);
        }
      }
    }

    // Update record matches in batch
    _batchInvites[batch.recordKey] =
        batch.copyWith(myConnectionRecords: myConnectionRecords);
    await persistentStorage.addBatch(batch);
    // and write to my subkey
    final mySubkeyRecord = await DHTRecordPool.instance.openRecordWrite(
        batch.recordKey, batch.subkeyWriter,
        debugName: 'coag::write-batch-subkey',
        crypto: crypto,
        defaultSubkey: batch.mySubkey);
    final mySubkeyContent = BatchSubkeySchema(
        batch.myName, batch.myKeyPair.key, myConnectionRecords);
    await mySubkeyRecord
        .tryWriteBytes(utf8.encode(jsonEncode(mySubkeyContent.toJson())));
    await mySubkeyRecord.close();
    // TODO: Also update the name in case someone changed the name available to the circle?
  }
}
