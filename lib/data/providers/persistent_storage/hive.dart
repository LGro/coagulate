// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/coag_contact.dart';
import '../../models/contact_update.dart';
import 'base.dart';

part 'hive.g.dart';

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

Future<void> initializePersistentStorage() async {
  final appStorage = await getApplicationDocumentsDirectory();
  Hive
    ..init(appStorage.path)
    ..registerAdapter(ContactRecordAdapter());
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
class HiveStorage extends PersistentStorage {
  // TODO: Add required global initialization here?!
  HiveStorage();

  Future<Box<ContactRecord>> _lazyGetContactsBox() async =>
      Hive.openBox('hive_coag_contacts_box');

  @override
  Future<Map<String, CoagContact>> getAllContacts() async =>
      (await _lazyGetContactsBox()).toMap().map((key, value) =>
          MapEntry(key.toString(), _deserializeAndMigrateIfNecessary(value)));

  @override
  Future<CoagContact> getContact(String coagContactId) async {
    final contactJson = (await _lazyGetContactsBox()).get(coagContactId);
    if (contactJson == null) {
      // TODO: handle error case more specifically
      throw Exception('Contact ID $coagContactId could not be found');
    }
    return _deserializeAndMigrateIfNecessary(contactJson);
  }

  @override
  Future<void> updateContact(CoagContact contact) async =>
      (await _lazyGetContactsBox())
          .put(contact.coagContactId, _recordFromContact(contact));

  Future<Box<String>> _lazyGetSettingsBox() async =>
      Hive.openBox('hive_coag_settings_box');

  @override
  Future<void> setProfileContactId(String profileContactId) async =>
      (await _lazyGetSettingsBox()).put('profile_contact_id', profileContactId);

  @override
  Future<String?> getProfileContactId() async =>
      (await _lazyGetSettingsBox()).get('profile_contact_id');

  @override
  Future<void> removeContact(String coagContactId) async =>
      (await _lazyGetSettingsBox()).delete(coagContactId);

  Future<Box<String>> _lazyGetUpdatesBox() async =>
      Hive.openBox('hive_coag_updates_box');

  @override
  Future<void> addUpdate(ContactUpdate update) async =>
      throw UnimplementedError();
  // (await _lazyGetUpdatesBox())
  //     .put(contact.coagContactId, json.encode(update.toJson()));

  @override
  Future<List<ContactUpdate>> getUpdates() {
    // TODO: implement getUpdates
    throw UnimplementedError();
  }
}
