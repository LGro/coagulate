// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';

import 'package:hive/hive.dart';
import '../models/coag_contact.dart';

part 'persistent_storage.g.dart';

const int mostRecentSchemaVersion = 1;

@HiveType(typeId: 1)
class ContactRecord {
  ContactRecord({required this.schemaVersion, required this.coagContactJson});

  @HiveField(0)
  final int schemaVersion;

  @HiveField(1)
  final String coagContactJson;

  @override
  String toString() => '$schemaVersion|$coagContactJson';
}

ContactRecord _recordFromContact(CoagContact contact) => ContactRecord(
    schemaVersion: mostRecentSchemaVersion,
    coagContactJson: json.encode(contact.toJson()));

CoagContact _deserializeAndMigrateIfNecessary(ContactRecord contactRecord) {
  String contactJson = contactRecord.coagContactJson;
  if (contactRecord.schemaVersion != mostRecentSchemaVersion) {
    // TODO: Upgrade contactJson
    throw Exception("Upgrading persistent storage is not implemented.");
  }
  // TODO: Nicer error handling?
  return CoagContact.fromJson(json.decode(contactJson) as Map<String, dynamic>);
}

/// Simple persistent storage based on [Hive], storing contacts as JSON strings
class HivePersistentStorage {
  HivePersistentStorage(String storagePath) {
    Hive
      ..init(storagePath)
      ..registerAdapter(ContactRecordAdapter());
  }

  Future<Box<ContactRecord>> _lazyGetContactsBox() async =>
      Hive.openBox('hive_coag_contacts_box');

  Future<Map<String, CoagContact>> getAllContacts() async =>
      (await _lazyGetContactsBox()).toMap().map((key, value) =>
          MapEntry(key.toString(), _deserializeAndMigrateIfNecessary(value)));

  Future<CoagContact> getContact(String coagContactId) async {
    final contactJson = (await _lazyGetContactsBox()).get(coagContactId);
    if (contactJson == null) {
      // TODO: handle error case more specifically
      throw Exception('Contact ID $coagContactId could not be found');
    }
    return _deserializeAndMigrateIfNecessary(contactJson);
  }

  Future<void> updateContact(CoagContact contact) async =>
      (await _lazyGetContactsBox())
          .put(contact.coagContactId, _recordFromContact(contact));

  Future<Box<String>> _lazyGetSettingsBox() async =>
      Hive.openBox('hive_coag_settings_box');

  Future<void> setProfileContactId(String profileContactId) async =>
      (await _lazyGetSettingsBox()).put('profile_contact_id', profileContactId);

  Future<String?> getProfileContactId() async =>
      (await _lazyGetSettingsBox()).get('profile_contact_id');
}
