// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:typed_data';

import 'package:coagulate/data/models/coag_contact.dart';
import 'package:coagulate/data/models/contact_location.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veilid/veilid.dart';

final dummyKeyPair = TypedKeyPair(
    kind: 0,
    key: FixedEncodedString43.fromBytes(Uint8List(32)),
    secret: FixedEncodedString43.fromBytes(Uint8List(32)));

void main() {
  test('details equatable', () {
    final details = ContactDetails(emails: [Email('1@com')]);
    final sameDetails = ContactDetails(emails: [Email('1@com')]);
    final otherDetails = ContactDetails(emails: [Email('2@com')]);
    expect(details == sameDetails, true);
    expect(details == otherDetails, false);
  });

  test('schema serialization and deserialization', () {
    final schema = CoagContactDHTSchemaV2(
      details: const ContactDetails(names: {'0': 'My Name'}),
      shareBackDHTKey: 'dhtKey',
      shareBackDHTWriter: 'dhtWriter',
      shareBackPubKey: 'pubKey',
    );
    final schema2 = CoagContactDHTSchemaV2.fromJson(schema.toJson());
    expect(schema, schema2);
  });

  test('equality test copy with change', () {
    final contact = CoagContact(
        coagContactId: '',
        name: 'name',
        dhtSettings: DhtSettings(myKeyPair: dummyKeyPair),
        details: const ContactDetails(picture: [1, 2, 3]),
        temporaryLocations: {
          '0': ContactTemporaryLocation(
              longitude: 0,
              latitude: 0,
              name: 'loc',
              details: '',
              start: DateTime(2000),
              end: DateTime(2000).add(const Duration(days: 1)))
        });
    final copy = contact.copyWith(
        details: contact.details!.copyWith(names: {
      ...contact.details!.names,
      ...{'1': 'b'}
    }));
    expect(contact == copy, false);
  });

  test('equality test copy then change, ensure no references', () {
    final contact = CoagContact(
        coagContactId: '',
        name: 'name',
        dhtSettings: DhtSettings(myKeyPair: dummyKeyPair),
        details: const ContactDetails(picture: [1, 2, 3]),
        temporaryLocations: {
          '0': ContactTemporaryLocation(
              longitude: 0,
              latitude: 0,
              name: 'loc',
              details: '',
              start: DateTime(2000),
              end: DateTime(2000).add(const Duration(days: 1)))
        });
    final copy = contact.copyWith();
    copy.temporaryLocations['1'] = ContactTemporaryLocation(
        longitude: 2,
        latitude: 2,
        name: 'loc2',
        details: '',
        start: DateTime(2000),
        end: DateTime(2000).add(const Duration(days: 1)));
    expect(contact == copy, false);
  });
}
