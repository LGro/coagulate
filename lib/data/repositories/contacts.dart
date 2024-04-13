// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:rxdart/subjects.dart';
import 'package:uuid/uuid.dart';

import '../../veilid_processor/repository/processor_repository.dart';
import '../models/coag_contact.dart';
import '../models/contact_location.dart';
import '../models/contact_update.dart';
import '../providers/dht.dart';
import '../providers/persistent_storage.dart';
import '../providers/system_contacts.dart';

// TODO: Persist all changes to any contact by never accessing coagContacts directly, only via getter and setter

// Just for testing purposes while no contacts share their locations
CoagContact _populateWithDummyLocations(CoagContact contact) =>
    contact.copyWith(
        locations: contact.details!.addresses
            .map((a) => AddressLocation(
                coagContactId: contact.coagContactId,
                longitude: Random().nextDouble() / 2 * 50,
                latitude: Random().nextDouble() / 2 * 50,
                name: a.label.name))
            .toList());

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
  ContactsRepository(this._persistentStoragePath) {
    FlutterContacts.addListener(_updateFromSystemContacts);
    unawaited(_init());
  }

  String _persistentStoragePath;
  late final HivePersistentStorage _persistentStorage =
      HivePersistentStorage(_persistentStoragePath);

  String? profileContactId = null;

  Map<String, CoagContact> coagContacts = {};
  // TODO: Persist; maybe just proxy read and writes to
  // persistent storage directly instead of having additional state here
  List<ContactUpdate> updates = [];

  final _updateStatusStreamController =
      BehaviorSubject<String>.seeded('NO-UPDATES');

  final _systemContactAccessGrantedStreamController =
      BehaviorSubject<bool>.seeded(false);

  // TODO: Ensure that:
  //  persistent storage is loaded,
  //  new changes from system contacts come in,
  //  new changes from dht come in
  //  changes in profile contact go out via dht
  Future<void> _init() async {
    // Load profile contact ID from persistent storage
    profileContactId = await _persistentStorage.getProfileContactId();

    // Load coagulate contacts from persistent storage
    coagContacts = await _persistentStorage.getAllContacts();

    coagContacts = coagContacts
        .map((key, value) => MapEntry(key, _populateWithDummyLocations(value)));

    // Update contacts wrt the system contacts
    unawaited(_updateFromSystemContacts());

    // Update the contacts wrt the DHT
    // TODO: Only do this when online
    unawaited(updateAndWatchReceivingDHT());
  }

  Future<void> updateAndWatchReceivingDHT() async {
    // TODO: Only do this when online; FIXME: This is a hack
    if (!ProcessorRepository
        .instance.processorConnectionState.attachment.publicInternetReady) {
      return;
    }
    for (final contact in coagContacts.values) {
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

  Future<void> _updateFromSystemContact(CoagContact contact) async {
    if (contact.systemContact == null) {
      // TODO: Log
      return;
    }
    // Try if permissions are granted
    try {
      final systemContact = await getSystemContact(contact.systemContact!.id);
      if (systemContact != contact.systemContact!) {
        coagContacts[contact.coagContactId] =
            contact.copyWith(systemContact: systemContact);
        _updateStatusStreamController
            .add('UPDATE-AVAILABLE:${contact.coagContactId}');
      }
    } on MissingSystemContactsPermissionError {
      _systemContactAccessGrantedStreamController.add(false);
    }
  }

  /// Update all system contacts in case they changed and add missing ones
  // TODO: Test that there can be coagulate contacts with a system contact that isn't actually in the system
  Future<void> _updateFromSystemContacts() async {
    // Try if permissions are granted
    try {
      var systemContacts = await getSystemContacts();
      _systemContactAccessGrantedStreamController.add(true);
      for (final coagContact in coagContacts.values) {
        // Skip coagulate contacts that are not associated with a system contact
        if (coagContact.systemContact == null) {
          continue;
        }
        // Remove contacts that did not change
        if (systemContacts.remove(coagContact.details)) {
          continue;
        }
        // The remaining matches based on system contact ID need to be updated
        final iChangedContact = systemContacts.indexWhere((systemContact) =>
            systemContact.id == coagContact.systemContact!.id);
        coagContacts[coagContact.coagContactId] = coagContact.copyWith(
            systemContact: systemContacts[iChangedContact]);
        systemContacts.removeAt(iChangedContact);
        _updateStatusStreamController
            .add('UPDATE-AVAILABLE:${coagContact.coagContactId}');
      }
      // The remaining system contacts are new
      for (final systemContact in systemContacts) {
        final coagContact = _populateWithDummyLocations(CoagContact(
            coagContactId: Uuid().v4().toString(),
            systemContact: systemContact,
            details: ContactDetails.fromSystemContact(systemContact)));
        coagContacts[coagContact.coagContactId] = coagContact;
        // TODO: Also signal that it's a new one?
        _updateStatusStreamController
            .add('UPDATE-AVAILABLE:${coagContact.coagContactId}');
      }
    } on MissingSystemContactsPermissionError {
      _systemContactAccessGrantedStreamController.add(false);
    }
  }

  Future<void> _onDHTContactUpdateReceived() async {
    // TODO: check DHT for updates
    // TODO: trigger persistent storage update
    _updateStatusStreamController.add('UPDATE-AVAILABLE:<CONTACT-ID>');
  }

  // Signal "update" or "contactID" in case a specific contact was updated
  // TODO: create enum or custom type for it instead of string
  // TODO: subscribe to updates in bloc/cubit
  Stream<String> getUpdateStatus() =>
      _updateStatusStreamController.asBroadcastStream();

  // TODO: subscribe to this from a settings cubit to show the appropriate button in UI
  Stream<bool> isSystemContactAccessGranted() =>
      _systemContactAccessGrantedStreamController.asBroadcastStream();

  // TODO: Does that need to be separate depending on whether the update originated from the dht or not?
  //       Or maybe separate depending on what part is updated (details, locations, dht stuff)
  Future<void> updateContact(CoagContact contact) async {
    // Skip in case already up to date
    if (coagContacts[contact.coagContactId] == contact) {
      return;
    }

    // Update persistent storage
    unawaited(_persistentStorage.updateContact(contact));

    // TODO: Allow creation of a new system contact via update contact as well; might require custom contact details schema
    // Update system contact if linked and contact details changed
    if (contact.systemContact != null &&
        coagContacts[contact.coagContactId]!.systemContact !=
            contact.systemContact) {
      // TODO: How to reconsile system contacts if permission was removed intermittently and is then granted again?
      try {
        unawaited(updateSystemContact(contact.systemContact!));
      } on MissingSystemContactsPermissionError {
        _systemContactAccessGrantedStreamController.add(false);
      }
    }

    // TODO: Move this to an unawaitable one since these changes don't need to block the stream update
    if (contact.sharedProfile != null) {
      final updatedContact = await updateContactSharingDHT(contact);
      if (updatedContact.dhtSettingsForSharing !=
          contact.dhtSettingsForSharing) {
        contact = updatedContact;
      }
    }

    coagContacts[contact.coagContactId] = contact;
    _updateStatusStreamController
        .add('UPDATE-AVAILABLE:${contact.coagContactId}');
  }

  // TODO: This seems unused, remove?
  Future<void> setProfileContactId(String id) async {
    profileContactId = id;
    await _persistentStorage.setProfileContactId(id);
    // TODO: Notify about update
  }

  Future<void> updateProfileContact(String coagContactId) async {
    if (!coagContacts.containsKey(coagContactId)) {
      // TODO: Log / raise error
      return;
    }

    // Ensure all system contacts changes are in
    await _updateFromSystemContact(coagContacts[coagContactId]!);

    for (final contact in coagContacts.values) {
      if (contact.dhtSettingsForSharing?.psk == null) {
        continue;
      }
      await updateContact(contact.copyWith(
          sharedProfile: json.encode(removeNullOrEmptyValues(
              filterAccordingToSharingProfile(coagContacts[coagContactId]!)
                  .toJson()))));
    }
  }

  String? getCoagContactIdForSystemContactId(String systemContactId) =>
      coagContacts.values
          .firstWhere((c) =>
              c.systemContact != null && c.systemContact!.id == systemContactId)
          .coagContactId;
}
