// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_contacts/flutter_contacts.dart';

abstract class SystemContactsBase {
  Future<List<Contact>> getContacts();
  Future<Contact> updateContact(Contact contact);
  Future<Contact> getContact(String id);
}
