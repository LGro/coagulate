// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:convert';

import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/coag_contact.dart';
import '../../models/contact_update.dart';
import 'base.dart';

Future<Database> getDatabase() async => openDatabase(
      join(await getDatabasesPath(), 'contacts.db'),
      onCreate: (db, version) => db.execute(
          'CREATE TABLE contacts(id TEXT PRIMARY KEY, contactJson TEXT)'),
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
  Future<void> removeContact(String coagContactId) async =>
      (await SharedPreferences.getInstance()).remove(coagContactId);

  @override
  Future<void> addUpdate(ContactUpdate update) {
    // TODO: implement addUpdate
    throw UnimplementedError();
  }

  @override
  Future<List<ContactUpdate>> getUpdates() {
    // TODO: implement getUpdates
    throw UnimplementedError();
  }
}
