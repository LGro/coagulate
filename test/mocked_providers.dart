// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:convert';

import 'package:coagulate/data/models/coag_contact.dart';
import 'package:coagulate/data/models/contact_update.dart';
import 'package:coagulate/data/models/profile_sharing_settings.dart';
import 'package:coagulate/data/providers/distributed_storage/dht.dart';
import 'package:coagulate/data/providers/persistent_storage/base.dart';
import 'package:coagulate/data/providers/system_contacts/base.dart';
import 'package:coagulate/data/providers/system_contacts/system_contacts.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class DummyPersistentStorage extends PersistentStorage {
  DummyPersistentStorage(this.contacts, {this.profileContactId});

  Map<String, CoagContact> contacts;
  String? profileContactId;
  List<String> log = [];
  Map<String, String> circles = {};
  ProfileSharingSettings profileSharingSettings =
      const ProfileSharingSettings();
  Map<String, List<String>> circleMemberships = {};
  List<ContactUpdate> updates = [];

  @override
  Future<void> addUpdate(ContactUpdate update) async {
    log.add('addUpdate');
    updates.add(update);
  }

  @override
  Future<Map<String, CoagContact>> getAllContacts() async {
    log.add('getAllContacts');
    return Future.value(contacts);
  }

  @override
  Future<CoagContact> getContact(String coagContactId) async {
    log.add('getContact:$coagContactId');
    return Future.value(contacts[coagContactId]);
  }

  @override
  Future<String?> getProfileContactId() async {
    log.add('getProfileContactId');
    return Future.value(profileContactId);
  }

  @override
  Future<List<ContactUpdate>> getUpdates() async {
    log.add('getUpdates');
    return Future.value([]);
  }

  @override
  Future<void> removeContact(String coagContactId) async {
    log.add('removeContact:$coagContactId');
    contacts.remove(coagContactId);
  }

  @override
  Future<void> setProfileContactId(String profileContactId) async {
    log.add('setProfileContactId:$profileContactId');
    this.profileContactId = profileContactId;
  }

  @override
  Future<void> updateContact(CoagContact contact) async {
    log.add('updateContact:${contact.coagContactId}');
    contacts[contact.coagContactId] = contact;
  }

  @override
  Future<Map<String, List<String>>> getCircleMemberships() async =>
      circleMemberships;

  @override
  Future<Map<String, String>> getCircles() async => circles;

  @override
  Future<ProfileSharingSettings> getProfileSharingSettings() async =>
      profileSharingSettings;

  @override
  Future<void> updateCircleMemberships(
      Map<String, List<String>> circleMemberships) async {
    log.add('updateCircleMemberships');
    this.circleMemberships = circleMemberships;
  }

  @override
  Future<void> updateCircles(Map<String, String> circles) async {
    log.add('updateCircles');
    this.circles = circles;
  }

  @override
  Future<void> updateProfileSharingSettings(
      ProfileSharingSettings settings) async {
    log.add('updateProfileSharingSettings');
    profileSharingSettings = settings;
  }

  @override
  Future<void> removeProfileContactId() async {
    profileContactId = null;
  }
}

class DummyDistributedStorage extends VeilidDhtStorage {
  DummyDistributedStorage({Map<String, String>? initialDht}) {
    if (initialDht != null) {
      dht = initialDht;
    }
  }
  List<String> log = [];
  Map<String, String> dht = {};
  Map<String, Future<void> Function(String key)> watchedRecords = {};

  @override
  Future<(String, String)> createDHTRecord() async {
    log.add('createDHTRecord');
    return ('VLD0:DUMMYwPaM1X1-d45IYDGLAAKQRpW2bf8cNKCIPNuW0M', 'writer');
  }

  @override
  Future<String> readPasswordEncryptedDHTRecord(
      {required String recordKey, required String secret}) async {
    log.add('readPasswordEncryptedDHTRecord:$recordKey:$secret');
    return dht[recordKey]!;
  }

  @override
  Future<CoagContact> updateContactReceivingDHT(CoagContact contact) {
    log.add('updateContactReceivingDHT:${contact.coagContactId}');
    return super.updateContactReceivingDHT(contact);
  }

  @override
  Future<CoagContact> updateContactSharingDHT(CoagContact contact,
      {Future<String> Function()? pskGenerator}) async {
    log.add('updateContactSharingDHT:${contact.coagContactId}');
    return super.updateContactSharingDHT(contact,
        pskGenerator: () async => 'generatedRandomKey');
  }

  @override
  Future<void> updatePasswordEncryptedDHTRecord(
      {required String recordKey,
      required String recordWriter,
      required String secret,
      required String content}) async {
    log.add('updatePasswordEncryptedDHTRecord:$recordKey');
    dht[recordKey] = content;
  }

  @override
  Future<void> watchDHTRecord(
      String key, Future<void> Function(String key) onNetworkUpdate) async {
    log.add('watchDHTRecord:$key');
    // TODO: Also call the updates when updates happen
    watchedRecords[key] = onNetworkUpdate;
  }
}

class DummySystemContacts extends SystemContactsBase {
  DummySystemContacts(this.contacts, {this.permissionGranted = true});

  List<Contact> contacts;
  List<String> log = [];
  bool permissionGranted;

  @override
  Future<Contact> getContact(String id) async {
    if (!permissionGranted) {
      throw MissingSystemContactsPermissionError();
    }
    log.add('getContact:$id');
    return Future.value(contacts.where((c) => c.id == id).first);
  }

  @override
  Future<List<Contact>> getContacts() async {
    if (!permissionGranted) {
      throw MissingSystemContactsPermissionError();
    }
    log.add('getContacts');
    return Future.value(contacts);
  }

  @override
  Future<Contact> updateContact(Contact contact) {
    if (!permissionGranted) {
      throw MissingSystemContactsPermissionError();
    }
    log.add('updateContact:${json.encode(contact.toJson())}');
    if (contacts.where((c) => c.id == contact.id).isNotEmpty) {
      contacts =
          contacts.map((c) => (c.id == contact.id) ? contact : c).asList();
    } else {
      contacts.add(contact);
    }
    return Future.value(contact);
  }

  @override
  Future<Contact> insertContact(Contact contact) {
    if (!permissionGranted) {
      throw MissingSystemContactsPermissionError();
    }
    contacts.add(contact);
    return Future.value(contact);
  }

  @override
  Future<bool> requestPermission() async => permissionGranted;
}
