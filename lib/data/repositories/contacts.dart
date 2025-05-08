// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/subjects.dart';
import 'package:uuid/uuid.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../ui/utils.dart';
import '../../veilid_processor/veilid_processor.dart';
import '../models/backup.dart';
import '../models/batch_invites.dart';
import '../models/coag_contact.dart';
import '../models/contact_introduction.dart';
import '../models/contact_location.dart';
import '../models/contact_update.dart';
import '../models/profile_sharing_settings.dart';
import '../providers/distributed_storage/base.dart';
import '../providers/persistent_storage/base.dart';
import '../providers/system_contacts/base.dart';

const String defaultInitialCircleId = 'coag::initial';

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

Map<String, T> filterContactDetailsList<T>(
  Map<String, T> values,
  Map<String, List<String>> settings,
  Iterable<String> activeCircles,
) {
  if (activeCircles.isEmpty) {
    return {};
  }
  return {...values}..removeWhere((label, value) =>
      !(settings[label]?.asSet().intersectsWith(activeCircles.asSet()) ??
          false));
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
      websites: filterContactDetailsList(details.websites, settings.websites,
          activeCirclesWithMemberCount.keys),
      socialMedias: filterContactDetailsList(details.socialMedias,
          settings.socialMedias, activeCirclesWithMemberCount.keys),
      events: filterContactDetailsList(
          details.events, settings.events, activeCirclesWithMemberCount.keys),
    );

/// Remove address locations that are not shared with the circles specified for
/// the corresponding address label
Map<String, ContactAddressLocation> filterAddressLocations(
        Map<String, ContactAddressLocation> locations,
        ProfileSharingSettings settings,
        Iterable<String> activeCircles) =>
    Map.fromEntries(locations.entries.where((l) =>
        settings.addresses[l.key]
            ?.toSet()
            .intersectsWith(activeCircles.toSet()) ??
        false));

/// Remove locations that ended longer than a day ago,
/// or aren't shared with the given circles if provided
Map<String, ContactTemporaryLocation> filterTemporaryLocations(
        Map<String, ContactTemporaryLocation> locations,
        [Iterable<String>? activeCircles]) =>
    Map.fromEntries(locations.entries.where((l) =>
        l.value.end.isAfter(DateTime.now()) &&
        // TODO: Unify that selected circles are part of profileShareSettings
        //       instead of the location instance?
        (activeCircles == null ||
            l.value.circles.toSet().intersectsWith(activeCircles.toSet()))));

// TODO: Empty all the known contacts and misc stuff when no circles active?
CoagContactDHTSchema filterAccordingToSharingProfile(
        {required ProfileInfo profile,
        required Map<String, int> activeCirclesWithMemberCount,
        required DhtSettings dhtSettings,
        required bool sharePersonalUniqueId,
        required List<ContactIntroduction> introductions,
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
      introductions: introductions,
    );

Future<TypedKeyPair> generateTypedKeyPairBest() async =>
    DHTRecordPool.instance.veilid.bestCryptoSystem().then((cs) => cs
        .generateKeyPair()
        .then((kp) => TypedKeyPair.fromKeyPair(cs.kind(), kp)));

Future<FixedEncodedString43> generateRandomSharedSecretBest() async =>
    Veilid.instance.bestCryptoSystem().then((cs) => cs.randomSharedSecret());

class ContactsRepository {
  ContactsRepository(
    this.persistentStorage,
    this.distributedStorage,
    this.systemContactsStorage,
    this.initialName, {
    bool initialize = true,
    this.notificationCallback,
    this.generateTypedKeyPair = generateTypedKeyPairBest,
    this.generateSharedSecret = generateRandomSharedSecretBest,
  }) {
    if (initialize) {
      unawaited(this.initialize());
    }
  }

  final String initialName;

  final PersistentStorage persistentStorage;
  final DistributedStorage distributedStorage;
  final SystemContactsBase systemContactsStorage;

  final Future<void> Function(int id, String title, String body,
      {String? payload})? notificationCallback;

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

  final Future<TypedKeyPair> Function() generateTypedKeyPair;

  final Future<FixedEncodedString43> Function() generateSharedSecret;

  Future<void> initialize(
      {bool scheduleRegularUpdates = true,
      bool listenToVeilidNetworkChanges = true}) async {
    await initializeFromPersistentStorage();

    // Initialize profile info
    if (_profileInfo == null) {
      // Ensure that the initial circle exists
      if (!getCircles().containsKey(defaultInitialCircleId)) {
        // TODO: Localize
        await addCircle(defaultInitialCircleId, 'Friends');
      }

      final nameId = Uuid().v4();
      await setProfileInfo(ProfileInfo(Uuid().v4(),
          details: ContactDetails(names: {nameId: initialName}),
          sharingSettings: ProfileSharingSettings(names: {
            nameId: const [defaultInitialCircleId]
          }),
          mainKeyPair: await generateTypedKeyPair()));
    }

    // Update the contacts from DHT and subscribe to future updates
    await updateAndWatchReceivingDHT();

    // Update the shared profile with all contacts
    await updateSharingDHT();

    if (listenToVeilidNetworkChanges) {
      ProcessorRepository.instance
          .streamProcessorConnectionState()
          .listen(_veilidConnectionStateChangeCallback);
    }

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
    await updateAllBatchInvites();
  }

  Future<void> saveContact(CoagContact coagContact) async {
    _contacts[coagContact.coagContactId] = coagContact.copyWith();
    _contactsStreamController.add(coagContact.coagContactId);
    await persistentStorage.updateContact(coagContact);
  }

  //////
  // DHT
  Future<bool> updateContactFromDHT(CoagContact contact) async {
    debugPrint('Attempting to update contact ${contact.name}');
    var success = false;
    try {
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
            final update = ContactUpdate(
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
                timestamp: DateTime.now());
            await _saveUpdate(update);

            final updateSummary =
                contactUpdateSummary(update.oldContact, update.newContact);
            final notificationTitle =
                (update.oldContact.details?.names.isNotEmpty ?? false)
                    ? update.oldContact.details!.names.values.join(' / ')
                    : update.newContact.details!.names.values.join(' / ');
            if (notificationCallback != null && updateSummary.isNotEmpty) {
              await notificationCallback!(
                  0, notificationTitle, 'Updated $updateSummary',
                  payload: contact.coagContactId);
            }
          }

          await saveContact(updatedContact.copyWith(
              mostRecentUpdate: updateTime, mostRecentChange: updateTime));

          // Ensure shared profile contains all the updated share and share back
          await updateContactSharedProfile(contact.coagContactId);

          unawaited(updateSystemContact(contact.coagContactId));

          // When it's the first time they acknowledge a completed handshake,
          // trigger an update of the sharing DHT record to switch from the
          // initial secret to a public key derived one
          if (!contact.dhtSettings.theyAckHandshakeComplete &&
              updatedContact.dhtSettings.theyAckHandshakeComplete) {
            // TODO: This could be directly "distributedStorage.updateRecord"
            //       with error handling.
            await tryShareWithContactDHT(updatedContact.coagContactId);
          }
        }
      }

      if (contact.dhtSettings.recordKeyThemSharing != null) {
        await distributedStorage.watchRecord(
            contact.dhtSettings.recordKeyThemSharing!,
            _dhtRecordUpdateCallback);
      }

      return success;
    } on VeilidAPIException catch (e) {
      // TODO: Report / log them somewhere accessible for debugging?
      // TODO: Handle if connected but record unavailable -> suggest reconnect
      debugPrint('Veilid API ERROR: $e');
      return false;
    }
  }

  void _veilidConnectionStateChangeCallback(ProcessorConnectionState event) {
    debugPrint('veilid connection state changed $event');
    if (event.isPublicInternetReady &&
        event.isAttached &&
        !veilidNetworkAvailable) {
      veilidNetworkAvailable = true;
      // This prioritizes receiving before sharing; does this help when running
      // in a background fetch task to at least get notifications about others?
      unawaited(updateAndWatchReceivingDHT().then((_) => updateSharingDHT()));
      unawaited(updateAllBatchInvites());
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
      debugPrint('Veilid attachment not public internet ready');
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
  Future<bool> tryShareWithContactDHT(String coagContactId,
      {bool initializeReceivingSettings = false,
      PublicKey? contactPubKey}) async {
    var contact = getContact(coagContactId);
    if (contact == null) {
      return false;
    }
    try {
      // NOTE: This assumes that when we have a record key to receive, it will
      //       eventually provide us with sharing back settings
      if (contact.dhtSettings.writerMeSharing == null &&
          contact.dhtSettings.recordKeyThemSharing == null) {
        final (shareKey, shareWriter) = await distributedStorage.createRecord();

        // TODO: Get specific cryptosystem version? also, move veilid specific stuff elsewhere
        final initialSecret = (contactPubKey == null &&
                contact.dhtSettings.theirPublicKey == null)
            ? await generateSharedSecret()
            : null;

        // TODO: Is a refresh of the contact before updating necessary?
        contact = getContact(contact.coagContactId)!;
        contact = contact.copyWith(
            dhtSettings: contact.dhtSettings.copyWith(
                recordKeyMeSharing: shareKey,
                writerMeSharing: shareWriter,
                theirPublicKey:
                    contactPubKey ?? contact.dhtSettings.theirPublicKey,
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
        tryShareWithContactDHT(contact.coagContactId)
    ]);

    return true;
  }

  /// Backup everything that is needed to restore Coagulate
  Future<(Typed<FixedEncodedString43>, FixedEncodedString43)?> backup(
      {bool waitForRecordSync = false}) async {
    final profile = getProfileInfo();
    if (profile == null) {
      return null;
    }
    final accountBackup = AccountBackup(
      // Drop pictures from profile
      ProfileInfo(
        profile.id,
        details: profile.details.copyWith(),
        addressLocations: {...profile.addressLocations},
        temporaryLocations: {...profile.temporaryLocations},
        sharingSettings: profile.sharingSettings.copyWith(),
        mainKeyPair: profile.mainKeyPair,
      ),
      // Reduce contacts to absolute minimum that is required to recreate them
      getContacts()
          .values
          .toList()
          .map((c) => CoagContact(
              coagContactId: c.coagContactId,
              name: c.name,
              dhtSettings: c.dhtSettings))
          .toList(),
      getCircles(),
      getCircleMemberships(),
    );
    final backupSecretKey = await generateSharedSecret();
    final (backupDhtKey, dhtWriter) = await distributedStorage.createRecord();
    try {
      // await distributedStorage.updateRecord(
      //     CoagContactDHTSchema(
      //         details: const ContactDetails(),
      //         shareBackDHTKey: null,
      //         shareBackPubKey: null),
      //     DhtSettings(
      //         myKeyPair: await generateTypedKeyPair(),
      //         recordKeyMeSharing: backupDhtKey,
      //         writerMeSharing:dhtWriter ,
      //         initialSecret: backupSecretKey));
      await distributedStorage.updateBackupRecord(
          accountBackup, backupDhtKey, dhtWriter, backupSecretKey);

      // While subkeys marked offline, wait
      while (waitForRecordSync) {
        final report = await DHTRecordPool.instance
            .openRecordRead(backupDhtKey,
                debugName: 'coag::backup::read::stats')
            .then((record) async {
          final report =
              await record.routingContext.inspectDHTRecord(backupDhtKey);
          await record.close();
          return report;
        });

        if (report.offlineSubkeys.isEmpty) {
          break;
        }
        await Future.delayed(const Duration(seconds: 1));
      }

      return (backupDhtKey, backupSecretKey);
    } on VeilidAPIException {
      return null;
    }
  }

  /// Restore a previously backed up Coagulate setup
  Future<bool> restore(
      Typed<FixedEncodedString43> recordKey, FixedEncodedString43 secret,
      {bool awaitDhtOperations = false}) async {
    // TODO: read record
    try {
      final jsonString =
          await distributedStorage.readBackupRecord(recordKey, secret);
      if (jsonString == null) {
        return false;
      }
      final backup = AccountBackup.fromJson(
          jsonDecode(jsonString) as Map<String, dynamic>);

      await setProfileInfo(backup.profileInfo);

      for (final contact in backup.contacts) {
        await saveContact(contact);
      }

      for (final circle in backup.circles.entries) {
        await addCircle(circle.key, circle.value);
      }

      await updateCircleMemberships(backup.circleMemberships);

      final dhtOperations = getContacts().values.map(updateContactFromDHT);
      if (awaitDhtOperations) {
        await Future.wait(dhtOperations);
      }

      return true;
    } on VeilidAPIException catch (e) {
      // TODO: Log
      return false;
    } on Exception catch (e) {
      // TODO: Log
      return false;
    }
  }

  //////////////////
  // SYSTEM CONTACTS

  Set<String> getAllLinkedSystemContactIds() => getContacts()
      .values
      .map((c) => c.systemContactId)
      .whereType<String>()
      .toSet();

  Future<void> updateSystemContact(String coagContactId) async {
    final contact = getContact(coagContactId);
    if (contact?.systemContactId == null) {
      return;
    }

    final permission = await Permission.contacts.status;
    if (!permission.isGranted) {
      return;
    }

    final systemContact = await FlutterContacts.getContact(
        contact!.systemContactId!,
        withAccounts: true,
        withGroups: true);
    if (systemContact == null) {
      // TODO: Is there a better way to remove it?
      final contactJson = contact.toJson()..remove('system_contact_id');
      await saveContact(CoagContact.fromJson(contactJson));
      return;
    }

    if (contact.details == null) {
      return;
    }

    // We combine into a display name but the system display name is kept
    // TODO: Claim existing values
    final updatedSystemContact = mergeSystemContacts(
        systemContact,
        contact.details!.toSystemContact(
            contact.details!.names.values.join(' | '),
            contact.addressLocations));
    await FlutterContacts.updateContact(updatedSystemContact);
  }

  Future<void> unlinkSystemContact(String coagContactId) async {
    final contact = getContact(coagContactId);
    if (contact?.systemContactId == null) {
      return;
    }

    final permission = await Permission.contacts.status;
    if (!permission.isGranted) {
      return;
    }

    final systemContact = await FlutterContacts.getContact(
        contact!.systemContactId!,
        withAccounts: true,
        withGroups: true);
    if (systemContact != null) {
      await FlutterContacts.updateContact(
          removeCoagManagedSuffixes(systemContact));
    }
    // TODO: Is there a better way to remove it?
    final contactJson = contact.toJson()..remove('system_contact_id');
    await saveContact(CoagContact.fromJson(contactJson));
  }

  ///////////
  // CONTACTS

  /// Get a copy of all contacts
  Map<String, CoagContact> getContacts() => {..._contacts};

  CoagContact? getContact(String coagContactId) =>
      _contacts[coagContactId]?.copyWith();

  CoagContact? getContactForSystemContactId(String systemContactId) =>
      _contacts.values
          .firstWhereOrNull((c) => c.systemContactId == systemContactId)
          ?.copyWith();

  Future<bool> removeContact(String coagContactId) async {
    await unlinkSystemContact(coagContactId);
    await updateCirclesForContact(coagContactId, [], triggerDhtUpdate: false);
    final dhtUpdateSuccess = await tryShareWithContactDHT(coagContactId);
    if (!dhtUpdateSuccess) {
      return false;
    }
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
    return true;
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
            introductions: contact.introductionsForThem,
            // TODO: Allow opt-out (per circle or globally?)
            sharePersonalUniqueId: true,
            // TODO: Do we need to trigger updating the sharing profile more often to keep this list up to date?
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
      {FixedEncodedString43? pubKey,
      bool awaitDhtSharingAttempt = false}) async {
    // Create contact
    final contact = CoagContact(
        coagContactId: Uuid().v4(),
        name: name,
        dhtSettings: DhtSettings(
            myKeyPair: await generateTypedKeyPair(),
            // If we already have a pubkey, consider the handshake complete
            theyAckHandshakeComplete: pubKey != null));
    await saveContact(contact);

    // Even though no details are shared yet, initialize shared profile
    await updateContactSharedProfile(contact.coagContactId);

    // Trigger sharing, incl. DHT record creation
    final dhtSharingAttempt = tryShareWithContactDHT(contact.coagContactId,
        initializeReceivingSettings: true, contactPubKey: pubKey);
    if (awaitDhtSharingAttempt) {
      await dhtSharingAttempt;
      // Update contact after setting up DHT things
      // TODO: Do we need to be more careful here with null checking?
      return getContact(contact.coagContactId)!;
    } else {
      unawaited(dhtSharingAttempt);
      return contact;
    }
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
    _circlesStreamController.add(null);
    await Future.wait([
      persistentStorage.updateCircleMemberships(_circleMemberships),
      updateContactSharedProfile(coagContactId)
    ]);
    _contactsStreamController.add(coagContactId);

    // Optionally, trigger DHT update
    if (triggerDhtUpdate) {
      unawaited(tryShareWithContactDHT(coagContactId));
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

  Future<void> setProfileInfo(ProfileInfo profileInfo,
      {bool triggerDhtUpdate = true}) async {
    _profileInfo = profileInfo;

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
    if (triggerDhtUpdate) {
      unawaited(updateSharingDHT());
    }
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

  Map<Typed<FixedEncodedString43>, BatchInvite> getBatchInvites() =>
      {..._batchInvites};

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

    // create circle with name from label and id from record key and share name
    await addCircle(recordKey.toString(), batchInfo.label);
    final profileInfo = getProfileInfo();
    if (profileInfo != null) {
      final updatedNameSharingSettings = {...profileInfo.sharingSettings.names};
      updatedNameSharingSettings[myNameId] = [
        recordKey.toString(),
        ...updatedNameSharingSettings[myNameId] ?? []
      ];
      await setProfileInfo(
          profileInfo.copyWith(
              sharingSettings: profileInfo.sharingSettings
                  .copyWith(names: updatedNameSharingSettings)),
          triggerDhtUpdate: false);
    }
    final myName =
        profileInfo?.details.names[myNameId] ?? '${batchInfo.label} $mySubkey';

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

  Future<MapEntry<String, Typed<FixedEncodedString43>>?>
      updateFromBatchInviteSubkey(
          BatchInvite batch, VeilidCrypto crypto, int subkey) async {
    final record = await DHTRecordPool.instance.openRecordRead(batch.recordKey,
        debugName: 'coag::read', crypto: crypto);
    Uint8List? contactSubkeyContentRaw;
    try {
      contactSubkeyContentRaw = await record.get(
          crypto: crypto,
          refreshMode: DHTRecordRefreshMode.network,
          subkey: subkey);
    } on FormatException catch (e) {
      debugPrint('Batch update format error for subkey $subkey: $e');
    } on VeilidAPIException catch (e) {
      debugPrint('Batch update veilid error for subkey $subkey: $e');
    } finally {
      await record.close();
    }
    if (contactSubkeyContentRaw == null) {
      return null;
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

    debugPrint(
        'Batch update for contact ${contact?.name ?? 'new'} at subkey $subkey');

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
          // Add to the batch circle and update shared profile
          [batch.recordKey.toString()],
          // Trigger dht update with custom arguments below instead
          triggerDhtUpdate: false);
    }

    // If contact subkey contains pubkey I haven't successfully created a
    // DHT sharing record for before, create DHT record and write with pubkey
    // to my subkey
    // NOTE: This is separate from the contact creation above because while we
    // usually succeed creating a new contact, initializing the sharing might
    // fail, so we need to be able to retry here.
    MapEntry<String, Typed<FixedEncodedString43>>? updatedConnectionRecord;
    if (!batch.myConnectionRecords
        .containsKey(contactSubkeyContent.publicKey.toString())) {
      // Trigger sharing, incl. DHT record creation and update contact
      await tryShareWithContactDHT(contact.coagContactId,
          contactPubKey: contact.dhtSettings.theirPublicKey);
      contact = getContact(contact.coagContactId);

      if (contact?.dhtSettings.recordKeyMeSharing != null) {
        updatedConnectionRecord = MapEntry(
            contactSubkeyContent.publicKey.toString(),
            contact!.dhtSettings.recordKeyMeSharing!);
      } else {
        // this should happen only when record creation fails in
        // trysharewithcontactdht?
        debugPrint('missing share key for batch offer');
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

    return updatedConnectionRecord;
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

    // iterate over other subkeys
    final subkeyFutures =
        <Future<MapEntry<String, Typed<FixedEncodedString43>>?>>[];
    for (var subkey = 1; subkey < batch.subkeyCount; subkey++) {
      if (subkey == batch.mySubkey) {
        continue;
      }
      subkeyFutures.add(updateFromBatchInviteSubkey(batch, crypto, subkey));
    }
    final connectionRecordUpdates = await Future.wait(subkeyFutures);

    // Update record matches in batch
    batch = batch.copyWith(myConnectionRecords: {
      ...batch.myConnectionRecords,
      ...Map.fromEntries(connectionRecordUpdates
          .whereType<MapEntry<String, Typed<FixedEncodedString43>>>())
    });
    _batchInvites[batch.recordKey] = batch;
    await persistentStorage.addBatch(batch);
    // and write to my subkey
    final mySubkeyRecord = await DHTRecordPool.instance.openRecordWrite(
        batch.recordKey, batch.subkeyWriter,
        debugName: 'coag::write-batch-subkey',
        crypto: crypto,
        defaultSubkey: batch.mySubkey);
    final mySubkeyContent = BatchSubkeySchema(
        batch.myName, batch.myKeyPair.key, batch.myConnectionRecords);
    await mySubkeyRecord
        .tryWriteBytes(utf8.encode(jsonEncode(mySubkeyContent.toJson())));
    await mySubkeyRecord.close();
    // TODO: Also update the name in case someone changed the name available to the circle?
  }

  Future<void> updateAllBatchInvites() =>
      Future.wait(_batchInvites.values.map(batchInviteUpdate));

  Future<void> updateBatchInviteForContact(String coagContactId) async {
    final contact = getContact(coagContactId);
    if (contact?.dhtSettings.theirPublicKey == null ||
        contact?.dhtSettings.recordKeyThemSharing != null) {
      return;
    }
    for (final batchInvite in _batchInvites.values) {
      if (batchInvite.myConnectionRecords
          .containsKey(contact!.dhtSettings.theirPublicKey.toString())) {
        // TODO: Speed this up by not refreshing all batch members but only the subkey relevant for this contact
        await batchInviteUpdate(batchInvite);
      }
    }
  }

  ////////////////
  // INTRODUCTIONS

  Future<bool> introduce(
      {required String contactIdA,
      required String nameA,
      required String contactIdB,
      required String nameB,
      String? message,
      bool awaitDhtOperations = false}) async {
    var contactA = getContact(contactIdA);
    var contactB = getContact(contactIdB);

    if (contactA?.dhtSettings.theirPublicKey == null ||
        contactB?.dhtSettings.theirPublicKey == null) {
      // TODO: let user know that fully connecting is prereq
      return false;
    }

    // TODO: check that they don't already know each other and let user know
    if (contactA!.knownPersonalContactIds
            .contains(contactB!.theirPersonalUniqueId) ||
        contactB.knownPersonalContactIds
            .contains(contactA.theirPersonalUniqueId)) {
      return false;
    }

    // TODO: Can this fail? Do we need to try except this?
    try {
      final (recordKeyA, writerA) = await distributedStorage.createRecord();
      final (recordKeyB, writerB) = await distributedStorage.createRecord();

      final introForA = ContactIntroduction(
          otherName: nameB,
          otherPublicKey: contactB.dhtSettings.theirPublicKey!,
          dhtRecordKeyReceiving: recordKeyB,
          dhtRecordKeySharing: recordKeyA,
          dhtWriterSharing: writerA);
      final introForB = ContactIntroduction(
          otherName: nameA,
          otherPublicKey: contactA.dhtSettings.theirPublicKey!,
          dhtRecordKeyReceiving: recordKeyA,
          dhtRecordKeySharing: recordKeyB,
          dhtWriterSharing: writerB);

      // Get most up to date contacts since dht record creation might have taken
      // a moment
      contactA = getContact(contactIdA);
      contactB = getContact(contactIdB);
      if (contactA == null || contactB == null) {
        return false;
      }

      await saveContact(contactA.copyWith(
          introductionsForThem: [...contactA.introductionsForThem, introForA]));
      await saveContact(contactB.copyWith(
          introductionsForThem: [...contactB.introductionsForThem, introForB]));

      final updateAndShareA = updateContactSharedProfile(contactIdA)
          .then((_) => tryShareWithContactDHT(contactIdA));
      final updateAndShareB = updateContactSharedProfile(contactIdB)
          .then((_) => tryShareWithContactDHT(contactIdB));

      if (awaitDhtOperations) {
        return await updateAndShareA && await updateAndShareB;
      } else {
        unawaited(updateAndShareA);
        unawaited(updateAndShareB);
        return true;
      }
    } on Exception {
      return false;
    }
  }

  Future<String> acceptIntroduction(
      CoagContact introducer, ContactIntroduction introduction,
      {bool awaitUpdateFromDht = false}) async {
    final contact = CoagContact(
        coagContactId: Uuid().v4(),
        name: introduction.otherName,
        dhtSettings: DhtSettings(
            myKeyPair: introducer.dhtSettings.myKeyPair,
            recordKeyMeSharing: introduction.dhtRecordKeySharing,
            writerMeSharing: introduction.dhtWriterSharing,
            theirPublicKey: introduction.otherPublicKey,
            recordKeyThemSharing: introduction.dhtRecordKeyReceiving,
            theyAckHandshakeComplete: true));
    await saveContact(contact);
    final dhtUpdate = updateContactFromDHT(contact);
    if (awaitUpdateFromDht) {
      await dhtUpdate;
    } else {
      unawaited(dhtUpdate);
    }
    return contact.coagContactId;
  }
}
