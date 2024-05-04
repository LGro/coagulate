// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_contacts/flutter_contacts.dart';

import 'base.dart';

class MissingSystemContactsPermissionError implements Exception {}

class SystemContacts extends SystemContactsBase {
  @override
  Future<List<Contact>> getContacts() async {
    if (!await FlutterContacts.requestPermission()) {
      throw MissingSystemContactsPermissionError();
    }

    // TODO: Offer loading them with just id and display name to speed things up in some cases?
    // NOTE: withAccounts is required to update contact on Android
    return FlutterContacts.getContacts(
        withThumbnail: true, withProperties: true, withAccounts: true);
  }

  @override
  Future<Contact> updateContact(Contact contact) async {
    if (!await FlutterContacts.requestPermission()) {
      throw MissingSystemContactsPermissionError();
    }

    return FlutterContacts.updateContact(contact);
  }

  @override
  Future<Contact> getContact(String id) async {
    if (!await FlutterContacts.requestPermission()) {
      throw MissingSystemContactsPermissionError();
    }

    // TODO: Error handling
    return (await FlutterContacts.getContact(id))!;
  }

  @override
  Future<Contact> insertContact(Contact contact) async {
    if (!await FlutterContacts.requestPermission()) {
      throw MissingSystemContactsPermissionError();
    }

    return FlutterContacts.insertContact(contact);
  }

  @override
  Future<bool> requestPermission() => FlutterContacts.requestPermission();
}
