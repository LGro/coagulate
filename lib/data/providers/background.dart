// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:veilid_support/veilid_support.dart';
import 'package:workmanager/workmanager.dart';

import '../../veilid_init.dart';
import '../../veilid_processor/repository/processor_repository.dart';
import '../providers/dht.dart';
import '../providers/system_contacts.dart';
import '../repositories/contacts.dart';
import 'persistent_storage/sqlite.dart' as persistent_storage;

const String updateToAndFromDhtTaskName = 'social.coagulate.dht.refresh';
const String refreshProfileContactTaskName = 'social.coagulate.profile.refresh';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, __) async {
    if (task == refreshProfileContactTaskName) {
      return refreshProfileContactDetails();
    }
    if (task == updateToAndFromDhtTaskName) {
      return updateToAndFromDht();
    }
    return true;
  });
}

Future<void> registerBackgroundTasks() async {
  await Workmanager().cancelAll();
  await Workmanager().registerPeriodicTask(
    refreshProfileContactTaskName,
    refreshProfileContactTaskName,
    initialDelay: const Duration(seconds: 30),
    frequency: const Duration(minutes: 15),
    existingWorkPolicy: ExistingWorkPolicy.keep,
  );
  await Workmanager().registerPeriodicTask(
    updateToAndFromDhtTaskName,
    updateToAndFromDhtTaskName,
    initialDelay: const Duration(seconds: 40),
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingWorkPolicy.keep,
  );
}

/// If system contact information for profile contact is changed, update profile
Future<bool> refreshProfileContactDetails() async {
  try {
    final profileContactId = await persistent_storage.getProfileContactId();
    if (profileContactId == null) {
      return true;
    }

    final profileContact =
        await persistent_storage.getContact(profileContactId);
    if (profileContact.systemContact == null) {
      return false;
    }

    final currentSystemContact =
        await getSystemContact(profileContact.systemContact!.id);

    if (profileContact.systemContact != currentSystemContact) {
      await persistent_storage.updateContact(
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
  // TODO: Can we refactor this to share more with the ContactsRepository?
  try {
    List<String> log = [];
    final startTime = DateTime.now();

    final profileContactId = await persistent_storage.getProfileContactId();
    if (profileContactId == null) {
      return true;
    }

    final contacts = await persistent_storage.getAllContacts();
    if (!contacts.containsKey(profileContactId)) {
      return false;
    }
    final profileContact = contacts[profileContactId]!;

    log.add(
        'found profile contact $profileContactId ${profileContact.systemContact?.displayName}');

    // TODO: Does shuffling the contacts really help not getting stuck?
    // Instead consider sorting by least recently updated
    final shuffledContacts = contacts.values.toList()..shuffle();

    try {
      await VeilidChatGlobalInit.initialize();
    } on VeilidAPIExceptionAlreadyInitialized {}

    var iContact = 0;
    while (iContact < shuffledContacts.length &&
        startTime.add(const Duration(seconds: 25)).isAfter(DateTime.now())) {
      // Wait for Veilid connectivity
      // TODO: Are we too conservative here?
      if (!ProcessorRepository.instance.startedUp) {
        sleep(const Duration(seconds: 1));
        log.add('slept until ${DateTime.now()}');
        continue;
      }

      var contact = shuffledContacts[iContact];
      iContact++;

      log.add('processing ${contact.details?.displayName}');

      // Share to DHT
      if (contact.dhtSettingsForSharing != null) {
        final sharedProfile = json.encode(removeNullOrEmptyValues(
            filterAccordingToSharingProfile(profileContact).toJson()));
        log.add('existing profile ${contact.sharedProfile}');
        if (contact.sharedProfile != sharedProfile) {
          log.add('new profile ${sharedProfile}');
          final updatedContact = await updateContactSharingDHT(
              contact.copyWith(sharedProfile: sharedProfile));
          await persistent_storage.updateContact(updatedContact);
        }
      }

      // Receive from DHT
      // TODO: Move above the profile contact true early return
      final updatedContact = await updateContactReceivingDHT(contact);
      if (updatedContact != contact) {
        // TODO: update system contact according to management profile
        await persistent_storage.updateContact(updatedContact);
      }
    }
    return iContact > 0;
  } on Exception catch (e) {
    return false;
  }
}
