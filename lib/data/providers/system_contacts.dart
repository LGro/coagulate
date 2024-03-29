// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_contacts/flutter_contacts.dart';

class MissingSystemContactsPermissionError implements Exception {}

Future<List<Contact>> getSystemContacts() async {
  if (!await FlutterContacts.requestPermission()) {
    throw MissingSystemContactsPermissionError();
  }

  // TODO: Offer loading them with just id and display name to speed things up in some cases?
  // NOTE: withAccounts is required to update contact on Android
  return FlutterContacts.getContacts(
      withThumbnail: true, withProperties: true, withAccounts: true);
}

Future<Contact> updateSystemContact(Contact contact) async {
  if (!await FlutterContacts.requestPermission()) {
    throw MissingSystemContactsPermissionError();
  }

  return FlutterContacts.updateContact(contact);
}

Future<Contact> getSystemContact(String id) async {
  if (!await FlutterContacts.requestPermission()) {
    throw MissingSystemContactsPermissionError();
  }

  // TODO: Error handling
  return (await FlutterContacts.getContact(id))!;
}
