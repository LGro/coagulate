// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../../veilid_init.dart';
import '../../veilid_processor/repository/processor_repository.dart';
import '../providers/dht.dart';
import '../providers/persistent_storage.dart';
import '../providers/system_contacts.dart';
import '../repositories/contacts.dart';

const String dhtRefreshBackgroundTaskName = 'social.coagulate.dht.refresh';
const String refreshProfileContactTaskName = 'social.coagulate.profile.refresh';
const String shareUpdatedProfileToDhtTaskName = 'social.coagulate.dht.profile';

// TODO: Can we refactor this to share more with the ContactsRepository?
/// If system contact information for profile contact is changed, update profile
Future<bool> refreshProfileContactDetails(String task, _) async {
  try {
    if (task != refreshProfileContactTaskName) {
      return true;
    }

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
Future<bool> shareUpdatedProfileToDHT(String task, _) async {
  // TODO: Do we need refreshProfileContactDetails as a separate task or do we just do it always here because it's fast?
  if (task != shareUpdatedProfileToDhtTaskName) {
    return true;
  }
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

    // Don't try to fetch things if not connected to the internet
    final connectivity = await Connectivity().checkConnectivity();
    if (!connectivity.contains(ConnectivityResult.wifi) &&
        !connectivity.contains(ConnectivityResult.mobile) &&
        !connectivity.contains(ConnectivityResult.ethernet)) {
      return true;
    }

    // TODO: Check if Veilid is already running?
    await VeilidChatGlobalInit.initialize();

    var iContact = 0;
    while (iContact < contacts.length &&
        startTime.add(const Duration(seconds: 25)).isBefore(DateTime.now())) {
      // Wait for Veilid connectivity
      // TODO: Are we too conservative here?
      if (!ProcessorRepository.instance.startedUp ||
          !ProcessorRepository
              .instance.processorConnectionState.isPublicInternetReady) {
        sleep(const Duration(seconds: 1));
        continue;
      }

      final contact = contacts.values.elementAt(iContact);
      iContact++;
      if (contact.dhtSettingsForSharing == null) {
        continue;
      }

      final sharedProfile = json.encode(removeNullOrEmptyValues(
          filterAccordingToSharingProfile(profileContact).toJson()));
      if (contact.sharedProfile == sharedProfile) {
        continue;
      }

      final updatedContact = contact.copyWith(sharedProfile: sharedProfile);
      await updateContactSharingDHT(updatedContact);

      await persistentStorage.updateContact(updatedContact);
    }
    return true;
  } on Exception catch (e) {
    return false;
  }
}

Future<bool> refreshContactsFromDHT(String task, _) async {
  if (task != dhtRefreshBackgroundTaskName) {
    return Future.value(true);
  }
  final startTime = DateTime.now();

  // Don't try to fetch things if not connected to the internet
  final connectivity = await Connectivity().checkConnectivity();
  if (!connectivity.contains(ConnectivityResult.wifi) &&
      !connectivity.contains(ConnectivityResult.mobile) &&
      !connectivity.contains(ConnectivityResult.ethernet)) {
    return Future.value(true);
  }

  // TODO: Check if Veilid is already running?
  await VeilidChatGlobalInit.initialize();

  final appStorage = await getApplicationDocumentsDirectory();
  final persistentStorage = HivePersistentStorage(appStorage.path);

  // TODO: Update contacts from DHT records and persist; order by least recently updated or random?
  // Shuffling might reduce the risk for re-trying on an unreachable / long running update and never getting to others?
  final contacts = (await persistentStorage.getAllContacts()).values.toList()
    ..shuffle();

  var iContact = 0;
  while (iContact < contacts.length &&
      startTime.add(const Duration(seconds: 25)).isBefore(DateTime.now())) {
    // Wait for Veilid connectivity
    // TODO: Are we too conservative here?
    if (!ProcessorRepository.instance.startedUp ||
        !ProcessorRepository
            .instance.processorConnectionState.isPublicInternetReady) {
      sleep(const Duration(seconds: 1));
      continue;
    }

    final contact = contacts[iContact];
    iContact++;

    // TODO: set last checked timestamp inside this function?
    final updatedContact = await updateContactReceivingDHT(contact);
    if (updatedContact == contact) {
      continue;
    }

    // system contact update?
    // persiste to disk

    // If changed, update system contact according to management profile
    // Update coagContact & persist
  }

  return Future.value(true);
}
