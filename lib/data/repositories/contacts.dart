// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:veilid/veilid.dart';

import '../../veilid_processor/repository/processor_repository.dart';
import '../models/coag_contact.dart';
import '../models/contact_update.dart';
import '../providers/distributed_storage/base.dart';
import '../providers/persistent_storage/base.dart';
import '../providers/system_contacts/base.dart';
import '../providers/system_contacts/system_contacts.dart';

// TODO: Persist all changes to any contact by never accessing coagContacts directly, only via getter and setter

// TODO: Add sharing profile and filter
CoagContactDHTSchemaV1 filterAccordingToSharingProfile(CoagContact contact) =>
    CoagContactDHTSchemaV1(
      coagContactId: contact.coagContactId,
      details: ContactDetails.fromSystemContact(contact.systemContact!),
      temporaryLocations: contact.temporaryLocations,
      addressLocations: contact.addressLocations,
      // TODO: Ensure these are populated by the time this is called
      shareBackDHTKey: contact.dhtSettingsForReceiving?.key,
      shareBackDHTWriter: contact.dhtSettingsForReceiving?.writer,
      shareBackPsk: contact.dhtSettingsForReceiving?.psk,
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
    // timerPersistentStorageRefresh = Timer.periodic(
    //     Duration(seconds: 5), (_) async => _updateFromPersistentStorage());

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

  Map<String, CoagContact> _contacts = {};
  final _contactsStreamController = BehaviorSubject<CoagContact>();

  // TODO: Double check whether we actually need this second stream, i.e. when would an update be passed here but not on the contacts stream?
  List<ContactUpdate> updates = [];
  final _updatesStreamController = BehaviorSubject<ContactUpdate>();

  final _systemContactAccessGrantedStreamController =
      BehaviorSubject<bool>.seeded(false);

  Future<void> _init() async {
    // Load profile contact ID from persistent storage
    profileContactId = await persistentStorage.getProfileContactId();

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

    await _updateFromSystemContacts();
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
    await _updateFromSystemContacts();
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
      await _saveUpdate(ContactUpdate(
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
  Future<void> _updateFromSystemContacts() async {
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

  // TODO: subscribe to this from a settings cubit to show the appropriate button in UI
  Stream<bool> isSystemContactAccessGranted() =>
      _systemContactAccessGrantedStreamController.asBroadcastStream();

  // TODO: Does that need to be separate depending on whether the update originated from the dht or not?
  //       Or maybe separate depending on what part is updated (details, locations, dht stuff)
  Future<void> updateContact(CoagContact contact) async {
    // Skip in case already up to date
    if (_contacts[contact.coagContactId] == contact) {
      return;
    }

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
          await _saveUpdate(ContactUpdate(
              oldContact: contact.details!,
              newContact: updatedContact.details!,
              timestamp: DateTime.now()));
          await updateContact(updatedContact);
        }
        await distributedStorage
            .watchDHTRecord(contact.dhtSettingsForReceiving!.key);
      }
    }
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
              filterAccordingToSharingProfile(_contacts[coagContactId]!)
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
}
