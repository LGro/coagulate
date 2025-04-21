// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/batch_invites.dart';
import '../../models/coag_contact.dart';
import '../../models/contact_update.dart';
import 'base.dart';

Future<void> initializePersistentStorage() async {
  final appStorage = await getApplicationDocumentsDirectory();
  // TODO: Does this interfere with map caching location?
  Hive.init(appStorage.path);
}

/// Simple persistent storage based on [Hive], storing contacts as JSON strings
class HiveStorage extends PersistentStorage {
  // TODO: Add required global initialization here?!
  HiveStorage();

  Future<Box<String>> _lazyGetContactsBox() async =>
      Hive.openBox('hive_coag_contacts_box');

  @override
  Future<Map<String, CoagContact>> getAllContacts() async =>
      Map.fromEntries((await _lazyGetContactsBox()).values.map((json) {
        final contact =
            CoagContact.fromJson(jsonDecode(json) as Map<String, dynamic>);
        return MapEntry(contact.coagContactId, contact);
      }));

  @override
  Future<void> updateContact(CoagContact contact) async =>
      (await _lazyGetContactsBox())
          .put(contact.coagContactId, jsonEncode(contact.toJson()));

  Future<Box<String>> _lazyGetSettingsBox() async =>
      Hive.openBox('hive_coag_settings_box');

  @override
  Future<void> removeContact(String coagContactId) async =>
      (await _lazyGetSettingsBox()).delete(coagContactId);

  Future<Box<List<String>>> _lazyGetUpdatesBox() async =>
      Hive.openBox<List<String>>('hive_coag_updates_box');

  @override
  Future<void> addUpdate(ContactUpdate update) async {
    throw UnimplementedError();
  }

  @override
  Future<List<ContactUpdate>> getUpdates() async => _lazyGetUpdatesBox()
      .then((box) async => box.get('updates'))
      .then((updates) => (updates ?? [])
          .map((u) =>
              ContactUpdate.fromJson(json.decode(u) as Map<String, dynamic>))
          .toList());

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
