// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../models/coag_contact.dart';
import '../../models/contact_update.dart';

const String mostRecentSchemaVersion = '1';

String _recordFromContact(CoagContact contact) =>
    '$mostRecentSchemaVersion|${json.encode(contact.toJson())}';

CoagContact _deserializeAndMigrateIfNecessary(String contactRecord) {
  final schemaVersion = contactRecord.split('|').first;
  final contactJson = contactRecord.substring(schemaVersion.length + 1);
  if (schemaVersion != mostRecentSchemaVersion) {
    // TODO: Upgrade contactJson
    throw Exception('Upgrading persistent storage is not implemented.');
  }
  // TODO: Nicer error handling?
  return CoagContact.fromJson(json.decode(contactJson) as Map<String, dynamic>);
}

Future<CoagContact> getContact(String coagContactId) async {
  final contactRecord =
      (await SharedPreferences.getInstance()).getString(coagContactId);
  if (contactRecord == null) {
    // TODO: handle error case more specifically
    throw Exception('Contact ID $coagContactId could not be found');
  }
  return _deserializeAndMigrateIfNecessary(contactRecord);
}

Future<Map<String, CoagContact>> getAllContacts() async => {
      for (final k in (await SharedPreferences.getInstance())
          .getKeys()
          .where((k) => Uuid.isValidUUID(fromString: k)))
        k: await getContact(k)
    };

Future<void> updateContact(CoagContact contact) async =>
    (await SharedPreferences.getInstance())
        .setString(contact.coagContactId, _recordFromContact(contact));

Future<void> setProfileContactId(String profileContactId) async =>
    (await SharedPreferences.getInstance())
        .setString('profile_contact_id', profileContactId);

Future<String?> getProfileContactId() async =>
    (await SharedPreferences.getInstance()).getString('profile_contact_id');

Future<void> removeContact(String coagContactId) async =>
    (await SharedPreferences.getInstance()).remove(coagContactId);

Future<List<ContactUpdate>> getUpdates() async {
  final updatesString =
      (await SharedPreferences.getInstance()).getString('updates');
  if (updatesString == null || updatesString.isEmpty) {
    return [];
  }
  return json.decode(updatesString) as List<ContactUpdate>;
}

Future<void> addUpdate(ContactUpdate update) async {
  await (await SharedPreferences.getInstance())
      .setString('updates', json.encode((await getUpdates())..add(update)));
}
