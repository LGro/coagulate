// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0
import 'dart:async';
import 'dart:math';

import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:rxdart/subjects.dart';
import 'package:uuid/uuid.dart';

import '../models/coag_contact.dart';
import '../models/contact_location.dart';
import '../providers/dht.dart';
import '../providers/persistent_storage.dart';
import '../providers/system_contacts.dart';

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

  final _updateStatusStreamController =
      BehaviorSubject<String>.seeded('NO-UPDATES');

  final _systemContactAccessGrantedStreamController =
      BehaviorSubject<bool>.seeded(false);

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
    // for (final coagContact in coagContacts.values) {
    //   // TODO: Implement dht infos for contact
    //   continue;
    //   //add watches for each dht record
    // }
  }

  // FIXME: Finish implementation
  Future<void> _updateFromDHT() async {
    for (final contact in coagContacts.values) {
      if (contact.dhtSettingsForSharing == null ||
          contact.dhtSettingsForSharing?.psk == null) {
        continue;
      }

      final updatedContact = await updateContactFromDHT(contact);
      if (updatedContact != contact) {
        updateContact(updatedContact);
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
      for (final coagContact in coagContacts.values) {
        // Skip coagulate contacts that are not associated with a system contact
        if (coagContact.details == null ||
            coagContact.details!.id == 'UNLINKED') {
          continue;
        }
        // Remove contacts that did not change
        if (systemContacts.remove(coagContact.details)) {
          continue;
        }
        // The remaining matches based on system contact ID need to be updated
        final iChangedContact = systemContacts.indexWhere(
            (systemContact) => systemContact.id == coagContact.details!.id);
        coagContacts[coagContact.coagContactId] =
            coagContact.copyWith(details: systemContacts[iChangedContact]);
        // TODO: Signal update of coagContactId
        systemContacts.removeAt(iChangedContact);
      }
      // The remaining system contacts are new
      for (final systemContact in systemContacts) {
        final coagContact = _populateWithDummyLocations(CoagContact(
            coagContactId: Uuid().v4().toString(), details: systemContact));
        coagContacts[coagContact.coagContactId] = coagContact;
        // TODO: Signal update of coagContactId; and that it's a new one
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
    if (contact.details != null &&
        contact.details!.id != 'UNLINKED' &&
        coagContacts[contact.coagContactId]!.details != contact.details) {
      // TODO: How to reconsile system contacts if permission was removed intermittently and is then granted again?
      try {
        unawaited(updateSystemContact(contact.details!));
      } on MissingSystemContactsPermissionError {
        _systemContactAccessGrantedStreamController.add(false);
      }
    }

    // TODO: Move this to an unawaitable one since these changes don't need to block the stream update
    if (contact.sharedProfile != null) {
      final updatedContact = await updateContactDHT(contact);
      if (updatedContact.dhtSettingsForSharing !=
          contact.dhtSettingsForSharing) {
        contact = updatedContact;
      }
    }

    coagContacts[contact.coagContactId] = contact;
    _updateStatusStreamController
        .add('UPDATE-AVAILABLE:${contact.coagContactId}');
  }

  Future<void> setProfileContactId(String id) async {
    profileContactId = id;
    await _persistentStorage.setProfileContactId(id);
    // TODO: Notify about update
  }
}
