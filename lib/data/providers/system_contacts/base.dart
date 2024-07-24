// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';

import 'package:flutter_contacts/flutter_contacts.dart';

abstract class SystemContactsBase {
  Future<List<Contact>> getContacts();
  Future<Contact> updateContact(Contact contact);
  Future<Contact> getContact(String id);
  Future<Contact> insertContact(Contact contact);
  Future<bool> requestPermission();
}

/// Compare contacts, ignoring differences wrt thumbnail or photo
bool systemContactsEqual(Contact c1, Contact c2) {
  final c1Json = jsonEncode(c1.toJson(withThumbnail: false, withPhoto: false));
  final c2Json = jsonEncode(c2.toJson(withThumbnail: false, withPhoto: false));
  return c1Json == c2Json;
}
