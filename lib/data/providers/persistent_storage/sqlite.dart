// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:convert';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/coag_contact.dart';
import '../../models/contact_update.dart';
import '../../models/profile_sharing_settings.dart';
import 'base.dart';

Future<Database> getDatabase() async => openDatabase(
      join(await getDatabasesPath(), 'contacts.db'),
      onCreate: (db, version) {
        db
          ..execute(
              'CREATE TABLE contacts(id TEXT PRIMARY KEY, contactJson TEXT)')
          // TODO: Consider using specific columns for update attributes instead of one json string
          ..execute(
              'CREATE TABLE updates(id INTEGER PRIMARY KEY, updateJson TEXT)')
          ..execute(
              'CREATE TABLE settings(id TEXT PRIMARY KEY, settingsJson TEXT)');
      },
      version: 1,
    );

class SqliteStorage extends PersistentStorage {
  @override
  Future<CoagContact> getContact(String coagContactId) async {
    final db = await getDatabase();
    final result = await db.query('contacts',
        columns: ['contactJson'],
        where: '"id" = ?',
        whereArgs: [coagContactId],
        limit: 1);
    if (result.isEmpty) {
      // TODO: handle error case more specifically
      throw Exception('Contact ID $coagContactId could not be found');
    }
    return CoagContact.fromJson(json.decode(result[0]['contactJson']! as String)
        as Map<String, dynamic>);
  }

  @override
  Future<Map<String, CoagContact>> getAllContacts() async {
    final db = await getDatabase();
    final results = await db.query('contacts', columns: ['id', 'contactJson']);
    return {
      for (final r in results)
        r['id']! as String: CoagContact.fromJson(
            json.decode(r['contactJson']! as String) as Map<String, dynamic>)
    };
  }

  @override
  Future<void> updateContact(CoagContact contact) async {
    final db = await getDatabase();
    try {
      await getContact(contact.coagContactId);
      await db.update(
          'contacts', {'contactJson': json.encode(contact.toJson())},
          where: '"id" = ?', whereArgs: [contact.coagContactId]);
    } on Exception {
      await db.insert('contacts', {
        'contactJson': json.encode(contact.toJson()),
        'id': contact.coagContactId
      });
    }
  }

  @override
  Future<void> setProfileContactId(String profileContactId) async =>
      (await SharedPreferences.getInstance())
          .setString('profile_contact_id', profileContactId);

  @override
  Future<String?> getProfileContactId() async =>
      (await SharedPreferences.getInstance()).getString('profile_contact_id');

  @override
  Future<void> removeProfileContactId() async =>
      (await SharedPreferences.getInstance()).remove('profile_contact_id');

  @override
  Future<void> removeContact(String coagContactId) async =>
      (await SharedPreferences.getInstance()).remove(coagContactId);

  @override
  Future<void> addUpdate(ContactUpdate update) async =>
      getDatabase().then((db) async =>
          db.insert('updates', {'updateJson': json.encode(update.toJson())}));

  @override
  Future<List<ContactUpdate>> getUpdates() async => getDatabase()
      .then((db) async => db.query('updates', columns: ['updateJson']))
      .then((results) => results
          .map((r) => ContactUpdate.fromJson(
              json.decode(r['updateJson']! as String) as Map<String, dynamic>))
          .asList());

  @override
  Future<Map<String, List<String>>> getCircleMemberships() async => getDatabase()
      .then((db) async => db.query('settings',
          columns: ['settingsJson'],
          where: 'id = ?',
          whereArgs: ['circleMemberships'],
          limit: 1))
      .then((results) => (results.isEmpty)
          ? {}
          : (json.decode(results.first['settingsJson']! as String)
                  as Map<String, dynamic>)
              .map((key, value) =>
                  MapEntry(key, (value is List) ? List<String>.from(value) : <String>[])));

  @override
  Future<Map<String, String>> getCircles() async => getDatabase()
      .then((db) async => db.query('settings',
          columns: ['settingsJson'],
          where: 'id = ?',
          whereArgs: ['circles'],
          limit: 1))
      .then((results) => (results.isEmpty)
          ? {}
          : ((json.decode(results.first['settingsJson']! as String)
                  as Map<String, dynamic>)
              .map((key, value) =>
                  MapEntry(key, (value is String) ? value : '???'))));

  @override
  Future<ProfileSharingSettings> getProfileSharingSettings() async =>
      getDatabase()
          .then((db) async => db.query('settings',
              columns: ['settingsJson'],
              where: 'id = ?',
              whereArgs: ['profileSharingSettings'],
              limit: 1))
          .then((results) => (results.isEmpty)
              ? const ProfileSharingSettings()
              : ProfileSharingSettings.fromJson(
                  json.decode(results.first['settingsJson']! as String)
                      as Map<String, dynamic>));

  @override
  Future<void> updateCircleMemberships(
          Map<String, List<String>> circleMemberships) async =>
      getDatabase().then((db) async => db.insert(
          'settings',
          {
            'id': 'circleMemberships',
            'settingsJson': json.encode(circleMemberships)
          },
          conflictAlgorithm: ConflictAlgorithm.replace));

  @override
  Future<void> updateCircles(Map<String, String> circles) async =>
      getDatabase().then((db) async => db.insert(
          'settings', {'id': 'circles', 'settingsJson': json.encode(circles)},
          conflictAlgorithm: ConflictAlgorithm.replace));

  @override
  Future<void> updateProfileSharingSettings(
          ProfileSharingSettings settings) async =>
      getDatabase().then((db) async => db.insert(
          'settings',
          {
            'id': 'profileSharingSettings',
            'settingsJson': json.encode(settings.toJson())
          },
          conflictAlgorithm: ConflictAlgorithm.replace));
}
