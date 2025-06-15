// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:convert';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../../debug_log.dart';
import '../../models/batch_invites.dart';
import '../../models/coag_contact.dart';
import '../../models/contact_update.dart';
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
          ..execute('CREATE TABLE batches(id TEXT PRIMARY KEY, batchJson TEXT)')
          ..execute(
              'CREATE TABLE settings(id TEXT PRIMARY KEY, settingsJson TEXT)');
      },
      version: 1,
    );

class SqliteStorage extends PersistentStorage {
  SqliteStorage() {
    unawaited(_initialize());
  }

  String _debugInfo = '';

  Future<void> _initialize() async {
    final db = await getDatabase();
    final contactIds = await db.query('contacts', columns: ['id']);
    final updateIds = await db.query('updates', columns: ['id']);
    _debugInfo = 'Contacts: ${contactIds.length}\nUpdates: ${updateIds.length}';
  }

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
    // TODO: Skip and log failing contacts like with updates
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
  Future<void> removeContact(String coagContactId) async =>
      getDatabase().then((db) =>
          db.delete('contacts', where: '"id" = ?', whereArgs: [coagContactId]));

  @override
  Future<void> addUpdate(ContactUpdate update) async =>
      getDatabase().then((db) async =>
          db.insert('updates', {'updateJson': json.encode(update.toJson())}));

  @override
  Future<List<ContactUpdate>> getUpdates() async => getDatabase()
      .then((db) async => db.query('updates', columns: ['updateJson']))
      .then((results) => results
          .map((r) {
            try {
              return ContactUpdate.fromJson(json
                  .decode(r['updateJson']! as String) as Map<String, dynamic>);
            } catch (e) {
              // TODO: Log a more info about the update without the risk of
              //       including the pictures in the json, this get too big fast
              DebugLogger().log('Error deserializing update');
            }
          })
          .whereType<ContactUpdate>()
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
  Future<ProfileInfo?> getProfileInfo() async => getDatabase()
      .then((db) async => db.query('settings',
          columns: ['settingsJson'],
          where: 'id = ?',
          whereArgs: ['profileInfo'],
          limit: 1))
      .then((results) => (results.isEmpty)
          ? null
          : ProfileInfo.fromJson(
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
  Future<void> updateProfileInfo(ProfileInfo info) async =>
      getDatabase().then((db) async => db.insert('settings',
          {'id': 'profileInfo', 'settingsJson': json.encode(info.toJson())},
          conflictAlgorithm: ConflictAlgorithm.replace));

  Future<BatchInvite> getBatch(String recordKey) async {
    final db = await getDatabase();
    final result = await db.query('batches',
        columns: ['batchJson'],
        where: '"id" = ?',
        whereArgs: [recordKey],
        limit: 1);
    if (result.isEmpty) {
      // TODO: handle error case more specifically
      throw Exception('Batch with record $recordKey could not be found');
    }
    return BatchInvite.fromJson(
        json.decode(result[0]['batchJson']! as String) as Map<String, dynamic>);
  }

  @override
  Future<void> addBatch(BatchInvite batch) async {
    final db = await getDatabase();
    try {
      await getBatch(batch.recordKey.toString());
      await db.update('batches', {'batchJson': json.encode(batch.toJson())},
          where: '"id" = ?', whereArgs: [batch.recordKey.toString()]);
    } on Exception {
      await db.insert('batches', {
        'batchJson': json.encode(batch.toJson()),
        'id': batch.recordKey.toString()
      });
    }
  }

  @override
  Future<List<BatchInvite>> getBatches() async => getDatabase()
      .then((db) async => db.query('batches', columns: ['batchJson']))
      .then((results) => results
          .map((r) => BatchInvite.fromJson(
              json.decode(r['batchJson']! as String) as Map<String, dynamic>))
          .asList());

  @override
  String debugInfo() => _debugInfo;
}
