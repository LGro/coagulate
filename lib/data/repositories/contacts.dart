// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:convert';

import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../veilid_processor/repository/processor_repository.dart';
import '../models/coag_contact.dart';
import '../models/contact_update.dart';
import '../providers/dht.dart';
import '../providers/persistent_storage/sqlite.dart' as persistent_storage;
import '../providers/system_contacts.dart';

// TODO: Persist all changes to any contact by never accessing coagContacts directly, only via getter and setter

// TODO: Add sharing profile and filter
CoagContactDHTSchemaV1 filterAccordingToSharingProfile(CoagContact contact) =>
    CoagContactDHTSchemaV1(
      coagContactId: contact.coagContactId,
      details: ContactDetails.fromSystemContact(contact.systemContact!),
      locations: contact.locations,
      // TODO: Ensure these are populated by the time this is called
      shareBackDHTKey: contact.dhtSettingsForReceiving?.key,
      shareBackDHTWriter: contact.dhtSettingsForReceiving?.writer,
      shareBackPubKey: contact.dhtSettingsForReceiving?.pubKey,
    );

Map<String, dynamic> removeNullOrEmptyValues(Map<String, dynamic> json) {
  // TODO: implement me; or implement custom schema for sharing payload
  return json;
}

/// Entrypoint for application layer when it comes to [CoagContact]
class ContactsRepository {
  ContactsRepository() {
    unawaited(_init());

    // Regularly check for updates from the persistent storage,
    // e.g. in case it was updated from background processes.
    timer = Timer.periodic(
        Duration(seconds: 5), (_) async => _updateFromPersistentStorage());
  }

  late final Timer? timer;
  String? profileContactId;

  Map<String, CoagContact> _contacts = {};
  // TODO: Persist; maybe just proxy read and writes to
  // persistent storage directly instead of having additional state here
  List<ContactUpdate> updates = [];

  final _contactsStreamController = BehaviorSubject<CoagContact>();

  final _systemContactAccessGrantedStreamController =
      BehaviorSubject<bool>.seeded(false);

  Future<void> _init() async {
    // Load profile contact ID from persistent storage
    profileContactId = await persistent_storage.getProfileContactId();

    // Load coagulate contacts from persistent storage
    _contacts = await persistent_storage.getAllContacts();
    for (final c in _contacts.values) {
      _contactsStreamController.add(c);
    }

    await _updateFromSystemContacts();
    FlutterContacts.addListener(_updateFromSystemContacts);

    // Update the contacts wrt the DHT
    // TODO: Only do this when online
    // await updateAndWatchReceivingDHT();

    // TODO: Only do this when online
    // for (final contact in _contacts.values) {
    //   await _saveContact(await updateContactSharingDHT(contact));
    // }
  }

  Future<void> _saveContact(CoagContact coagContact) async {
    _contacts[coagContact.coagContactId] = coagContact;
    _contactsStreamController.add(coagContact);
    await persistent_storage.updateContact(coagContact);
  }

  Future<void> _updateFromSystemContact(CoagContact contact) async {
    if (contact.systemContact == null) {
      // TODO: Log
      return;
    }
    // Try if permissions are granted
    try {
      final systemContact = await getSystemContact(contact.systemContact!.id);
      _systemContactAccessGrantedStreamController.add(true);

      if (systemContact != contact.systemContact!) {
        final updatedContact = contact.copyWith(systemContact: systemContact);
        await _saveContact(updatedContact);
      }
    } on MissingSystemContactsPermissionError {
      _systemContactAccessGrantedStreamController.add(false);
    }
  }

  Future<void> _updateFromPersistentStorage() async {
    await (await SharedPreferences.getInstance()).reload();
    final storedContacts = await persistent_storage.getAllContacts();
    for (final contact in _contacts.values) {
      // Update if there is no matching contact but is a corresponding ID
      if (!storedContacts.containsValue(contact) &&
          storedContacts.containsKey(contact.coagContactId)) {
        // TODO: Check most recent update timestamp and make sure the on from persistent storag is more recent
        await _saveContact(storedContacts[contact.coagContactId]!);
      }
    }
  }

  /// Update all system contacts in case they changed and add missing ones
  // TODO: Test that there can be coagulate contacts with a system contact that isn't actually in the system
  Future<void> _updateFromSystemContacts() async {
    // Try if permissions are granted
    try {
      var systemContacts = await getSystemContacts();
      _systemContactAccessGrantedStreamController.add(true);
      for (final coagContact in _contacts.values) {
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
        final updatedContact = coagContact.copyWith(
            systemContact: systemContacts[iChangedContact]);
        systemContacts.removeAt(iChangedContact);
        await _saveContact(updatedContact);
      }
      // The remaining system contacts are new
      for (final systemContact in systemContacts) {
        final coagContact = CoagContact(
            coagContactId: const Uuid().v4(),
            systemContact: systemContact,
            details: ContactDetails.fromSystemContact(systemContact));
        await _saveContact(coagContact);
      }
    } on MissingSystemContactsPermissionError {
      _systemContactAccessGrantedStreamController.add(false);
    }
  }

  Future<void> _onDHTContactUpdateReceived() async {
    // TODO: check DHT for updates
    // TODO: trigger persistent storage update
    // _contactsStreamController.add(coagContact);
  }

  Stream<CoagContact> getContactUpdates() =>
      _contactsStreamController.asBroadcastStream();

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
        _contacts[contact.coagContactId]!.systemContact !=
            contact.systemContact) {
      // TODO: How to reconsile system contacts if permission was removed intermittently and is then granted again?
      try {
        await updateSystemContact(contact.systemContact!);
      } on MissingSystemContactsPermissionError {
        _systemContactAccessGrantedStreamController.add(false);
      }
    }

    // TODO: Move this to an unawaitable one since these changes don't need to block the stream update
    if (contact.sharedProfile != null) {
      final updatedContact = await updateContactSharingDHT(contact);
      // TODO: Is this too broad of a condition and update?
      // i.e. should we check for specific attributes where we expect and override and then copy with them?
      // I'm worried about race conditions
      if (updatedContact != contact) {
        contact = updatedContact;
      }
    }

    await _saveContact(contact);
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
        print('checking ${contact.coagContactId}');
        final updatedContact = await updateContactReceivingDHT(contact);
        if (updatedContact != contact) {
          // TODO: Use update time from when the update was sent not received
          updates.add(ContactUpdate(
              message: 'News from ${contact.details?.displayName}',
              timestamp: DateTime.now()));
          await updateContact(updatedContact);
        }
        // TODO: Check how long this takes and what could go wrong with not awaiting instead
        // FIXME: actually start to watch, but canceling watch seems to require opening the record?
        // await watchDHTRecord(contact.dhtSettingsForReceiving!.key);
      }
    }
  }

  Future<void> updateProfileContact(String coagContactId) async {
    if (!_contacts.containsKey(coagContactId)) {
      // TODO: Log / raise error
      return;
    }

    // TODO: Do we need to enforce writing to disk to make it available to background straight away?
    await persistent_storage.setProfileContactId(coagContactId);

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

  String? getCoagContactIdForSystemContactId(String systemContactId) =>
      _contacts.values
          .firstWhere((c) =>
              c.systemContact != null && c.systemContact!.id == systemContactId)
          .coagContactId;

  Map<String, CoagContact> getContacts() => _contacts;

  Future<void> removeContact(String coagContactId) async {
    _contacts.remove(coagContactId);
    await persistent_storage.removeContact(coagContactId);
  }
}
