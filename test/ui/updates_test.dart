// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:typed_data';

import 'package:coagulate/data/models/coag_contact.dart';
import 'package:coagulate/data/models/contact_location.dart';
import 'package:coagulate/ui/updates/page.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veilid/veilid.dart';
import 'package:veilid_support/veilid_support.dart';

final dummyKeyPair = TypedKeyPair(
    kind: 0,
    key: FixedEncodedString43.fromBytes(Uint8List(32)),
    secret: FixedEncodedString43.fromBytes(Uint8List(32)));

void main() {
  test('compare contact details no difference', () {
    final result = compareContacts(
        CoagContact(
            coagContactId: '',
            name: 'name',
            dhtSettings: DhtSettings(myKeyPair: dummyKeyPair),
            details: ContactDetails(
                names: const {'0': 'a'}, emails: [Email('e@1.de')])),
        CoagContact(
            coagContactId: '',
            name: 'name',
            dhtSettings: DhtSettings(myKeyPair: dummyKeyPair),
            details: ContactDetails(
                names: const {'0': 'a'}, emails: [Email('e@1.de')])));
    expect(result, '');
  });

  test('compare contact details different emails', () {
    final result = compareContacts(
        CoagContact(
            coagContactId: '',
            name: 'name',
            dhtSettings: DhtSettings(myKeyPair: dummyKeyPair),
            details: ContactDetails(
                names: const {'0': 'a'}, emails: [Email('e@1.de')])),
        CoagContact(
            coagContactId: '',
            name: 'name',
            dhtSettings: DhtSettings(myKeyPair: dummyKeyPair),
            details: ContactDetails(
                names: const {'0': 'a'}, emails: [Email('e@2.de')])));
    expect(result, 'emails');
  });

  test('compare contact details different names', () {
    final result = compareContacts(
        CoagContact(
            coagContactId: '',
            name: 'name',
            dhtSettings: DhtSettings(myKeyPair: dummyKeyPair),
            details: const ContactDetails(names: {'0': 'a'})),
        CoagContact(
            coagContactId: '',
            name: 'name',
            dhtSettings: DhtSettings(myKeyPair: dummyKeyPair),
            details: const ContactDetails(names: {'0': 'b'})));
    expect(result, 'names');
  });

  test('compare contact details different names and phones', () {
    final result = compareContacts(
        CoagContact(
            coagContactId: '',
            name: 'name',
            dhtSettings: DhtSettings(myKeyPair: dummyKeyPair),
            details: ContactDetails(names: const {
              '0': 'a'
            }, phones: [
              Phone('0123', label: PhoneLabel.custom, customLabel: 'label1')
            ])),
        CoagContact(
            coagContactId: '',
            name: 'name',
            dhtSettings: DhtSettings(myKeyPair: dummyKeyPair),
            details: ContactDetails(names: const {
              '0': 'b'
            }, phones: [
              Phone('4321', label: PhoneLabel.custom, customLabel: 'label2')
            ])));
    expect(result, 'names, phones');
  });

  test('compare contact  same locations', () {
    final result = compareContacts(
        CoagContact(
          coagContactId: '',
          name: 'name',
          dhtSettings: DhtSettings(myKeyPair: dummyKeyPair),
          temporaryLocations: {
            '0': ContactTemporaryLocation(
                longitude: 0,
                latitude: 0,
                name: 'loc1',
                details: '',
                start: DateTime(5000),
                end: DateTime(5000).add(const Duration(days: 1)))
          },
        ),
        CoagContact(
          coagContactId: '',
          name: 'name',
          dhtSettings: DhtSettings(myKeyPair: dummyKeyPair),
          temporaryLocations: {
            '0': ContactTemporaryLocation(
                longitude: 0,
                latitude: 0,
                name: 'loc1',
                details: '',
                start: DateTime(5000),
                end: DateTime(5000).add(const Duration(days: 1)))
          },
        ));
    expect(result, '');
  });

  test('compare contact updated location', () {
    final result = compareContacts(
        CoagContact(
          coagContactId: '',
          name: 'name',
          dhtSettings: DhtSettings(myKeyPair: dummyKeyPair),
          temporaryLocations: {
            '0': ContactTemporaryLocation(
                longitude: 0,
                latitude: 0,
                name: 'loc1',
                details: '',
                start: DateTime(5000),
                end: DateTime(5000).add(const Duration(days: 1)))
          },
        ),
        CoagContact(
          coagContactId: '',
          name: 'name',
          dhtSettings: DhtSettings(myKeyPair: dummyKeyPair),
          temporaryLocations: {
            '0': ContactTemporaryLocation(
                longitude: 4,
                latitude: 4,
                name: 'loc2',
                details: '',
                start: DateTime(5000),
                end: DateTime(5000).add(const Duration(days: 1)))
          },
        ));
    expect(result, 'locations');
  });

  test('compare contact different locations', () {
    final result = compareContacts(
        CoagContact(
          coagContactId: '',
          name: 'name',
          dhtSettings: DhtSettings(myKeyPair: dummyKeyPair),
          temporaryLocations: {
            '0': ContactTemporaryLocation(
                longitude: 0,
                latitude: 0,
                name: 'loc1',
                details: '',
                start: DateTime(5000),
                end: DateTime(5000).add(const Duration(days: 1)))
          },
        ),
        CoagContact(
          coagContactId: '',
          name: 'name',
          dhtSettings: DhtSettings(myKeyPair: dummyKeyPair),
          temporaryLocations: {
            '1': ContactTemporaryLocation(
                longitude: 4,
                latitude: 4,
                name: 'loc2',
                details: '',
                start: DateTime(5000),
                end: DateTime(5000).add(const Duration(days: 1)))
          },
        ));
    expect(result, 'locations');
  });

  test('compare contact different but outdated locations', () {
    final result = compareContacts(
        CoagContact(
            coagContactId: '',
            name: 'name',
            dhtSettings: DhtSettings(myKeyPair: dummyKeyPair)),
        CoagContact(
          coagContactId: '',
          name: 'name',
          dhtSettings: DhtSettings(myKeyPair: dummyKeyPair),
          temporaryLocations: {
            '0': ContactTemporaryLocation(
                longitude: 0,
                latitude: 0,
                name: 'loc',
                details: '',
                start: DateTime(2000),
                end: DateTime(2000).add(const Duration(days: 1)))
          },
        ));
    expect(result, '');
  });

  test('compare contact details different pictures', () {
    final result = compareContacts(
        CoagContact(
          coagContactId: '',
          name: 'name',
          dhtSettings: DhtSettings(myKeyPair: dummyKeyPair),
          details: const ContactDetails(picture: [1, 2, 3]),
        ),
        CoagContact(
          coagContactId: '',
          name: 'name',
          dhtSettings: DhtSettings(myKeyPair: dummyKeyPair),
          details: const ContactDetails(picture: [3, 2, 1]),
        ));
    expect(result, 'picture');
  });

  test('compare contacts with matching hash codes', () {
    final c1 = CoagContact(
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
    expect(c1.hashCode, c1.copyWith().hashCode);

    final c2 = CoagContact(
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
    expect(c1.hashCode, c2.hashCode);
  });
}
