// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../veilid_init.dart';
import '../../veilid_processor/repository/processor_repository.dart';
import '../providers/dht.dart';
import '../providers/persistent_storage.dart';
import '../providers/system_contacts.dart';
import '../repositories/contacts.dart';

// TODO: Can we refactor this to share more with the ContactsRepository?
/// If system contact information for profile contact is changed, update profile
Future<bool> refreshProfileContactDetails() async {
  try {
    final appStorage = await getApplicationDocumentsDirectory();
    final persistentStorage = HivePersistentStorage(appStorage.path);

    final profileContactId = await persistentStorage.getProfileContactId();
    if (profileContactId == null) {
      return false;
    }

    final profileContact = await persistentStorage.getContact(profileContactId);
    if (profileContact.systemContact == null) {
      return false;
    }

    final currentSystemContact =
        await getSystemContact(profileContact.systemContact!.id);

    if (profileContact.systemContact != currentSystemContact) {
      await persistentStorage.updateContact(
          profileContact.copyWith(systemContact: currentSystemContact));
    }
    return true;
  } on Exception catch (e) {
    return false;
  }
}

/// Write the current profile contact information to all contacts' DHT record
/// that have a different (outdated) version.
Future<bool> updateToAndFromDht() async {
  try {
    final startTime = DateTime.now();

    final appStorage = await getApplicationDocumentsDirectory();
    final persistentStorage = HivePersistentStorage(appStorage.path);

    final profileContactId = await persistentStorage.getProfileContactId();
    if (profileContactId == null) {
      return false;
    }

    final contacts = await persistentStorage.getAllContacts();
    if (!contacts.containsKey(profileContactId)) {
      return false;
    }
    final profileContact = contacts[profileContactId]!;

    // TODO: Does shuffling the contacts really help not getting stuck?
    // Instead consider sorting by least recently updated
    final shuffledContacts = contacts.values.toList()..shuffle();

    try {
      await VeilidChatGlobalInit.initialize();
    } on VeilidAPIExceptionAlreadyInitialized {}

    var iContact = 0;
    while (iContact < shuffledContacts.length &&
        startTime.add(const Duration(seconds: 25)).isBefore(DateTime.now())) {
      // Wait for Veilid connectivity
      // TODO: Are we too conservative here?
      if (!ProcessorRepository.instance.startedUp ||
          !ProcessorRepository
              .instance.processorConnectionState.isPublicInternetReady) {
        sleep(const Duration(seconds: 1));
        continue;
      }

      var contact = shuffledContacts[iContact];
      iContact++;

      // Share to DHT
      if (contact.dhtSettingsForSharing != null) {
        final sharedProfile = json.encode(removeNullOrEmptyValues(
            filterAccordingToSharingProfile(profileContact).toJson()));
        if (contact.sharedProfile != sharedProfile) {
          contact = contact.copyWith(sharedProfile: sharedProfile);
          await updateContactSharingDHT(contact);
          await persistentStorage.updateContact(contact);
        }
      }

      // Receive from DHT
      final updatedContact = await updateContactReceivingDHT(contact);
      if (updatedContact != contact) {
        // TODO: update system contact according to management profile
        await persistentStorage.updateContact(updatedContact);
      }
    }
    return iContact > 0;
  } on Exception catch (e) {
    return false;
  }
}
