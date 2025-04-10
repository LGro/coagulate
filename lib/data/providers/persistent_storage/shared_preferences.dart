// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../models/batch_invites.dart';
import '../../models/coag_contact.dart';
import '../../models/contact_update.dart';
import 'base.dart';

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

class SharedPreferencesStorage extends PersistentStorage {
  @override
  Future<CoagContact> getContact(String coagContactId) async {
    final contactRecord =
        (await SharedPreferences.getInstance()).getString(coagContactId);
    if (contactRecord == null) {
      // TODO: handle error case more specifically
      throw Exception('Contact ID $coagContactId could not be found');
    }
    return _deserializeAndMigrateIfNecessary(contactRecord);
  }

  @override
  Future<Map<String, CoagContact>> getAllContacts() async => {
        for (final k in (await SharedPreferences.getInstance())
            .getKeys()
            .where((k) => Uuid.isValidUUID(fromString: k)))
          k: await getContact(k)
      };

  @override
  Future<void> updateContact(CoagContact contact) async =>
      (await SharedPreferences.getInstance())
          .setString(contact.coagContactId, _recordFromContact(contact));

  @override
  Future<void> removeContact(String coagContactId) async =>
      (await SharedPreferences.getInstance()).remove(coagContactId);

  @override
  Future<List<ContactUpdate>> getUpdates() async {
    final updatesString =
        (await SharedPreferences.getInstance()).getString('updates');
    if (updatesString == null || updatesString.isEmpty) {
      return [];
    }
    return List.from((json.decode(updatesString) as Iterable)
        .map((u) => ContactUpdate.fromJson(u as Map<String, dynamic>)));
  }

  @override
  Future<void> addUpdate(ContactUpdate update) async {
    await (await SharedPreferences.getInstance())
        .setString('updates', json.encode((await getUpdates())..add(update)));
  }

  @override
  Future<Map<String, List<String>>> getCircleMemberships() {
    // TODO: implement getCircleMemberships
    throw UnimplementedError();
  }

  @override
  Future<Map<String, String>> getCircles() {
    // TODO: implement getCircles
    throw UnimplementedError();
  }

  @override
  Future<ProfileInfo> getProfileInfo() {
    throw UnimplementedError();
  }

  @override
  Future<void> updateCircleMemberships(
      Map<String, List<String>> circleMemberships) {
    // TODO: implement updateCircleMemberships
    throw UnimplementedError();
  }

  @override
  Future<void> updateCircles(Map<String, String> circles) {
    // TODO: implement updateCircles
    throw UnimplementedError();
  }

  @override
  Future<void> updateProfileInfo(ProfileInfo info) {
    // TODO: implement updateProfileSharingSettings
    throw UnimplementedError();
  }

  @override
  Future<void> addBatch(BatchInvite batch) {
    // TODO: implement addBatch
    throw UnimplementedError();
  }

  @override
  Future<List<BatchInvite>> getBatches() {
    // TODO: implement getBatches
    throw UnimplementedError();
  }
}
