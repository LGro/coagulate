// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:typed_data';

import 'package:coagulate/data/models/coag_contact.dart';
import 'package:coagulate/data/models/contact_location.dart';
import 'package:coagulate/ui/utils.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veilid/veilid.dart';
import 'package:veilid_support/veilid_support.dart';

final dummyKeyPair = TypedKeyPair(
    kind: 0,
    key: FixedEncodedString43.fromBytes(Uint8List(32)),
    secret: FixedEncodedString43.fromBytes(Uint8List(32)));

final dummyBaseContact = CoagContact(
    coagContactId: '',
    name: 'dummy',
    myIdentity: dummyKeyPair,
    myIntroductionKeyPair: dummyKeyPair,
    dhtSettings: DhtSettings(myNextKeyPair: dummyKeyPair));

void main() {
  test('compare contact details no difference', () {
    final result = contactUpdateSummary(
        dummyBaseContact.copyWith(
            details: const ContactDetails(
                names: {'0': 'a'}, emails: {'private': 'e@1.de'})),
        dummyBaseContact.copyWith(
            details: const ContactDetails(
                names: {'0': 'a'}, emails: {'private': 'e@1.de'})));
    expect(result, '');
  });

  test('compare contact details different emails', () {
    final result = contactUpdateSummary(
        dummyBaseContact.copyWith(
            details: const ContactDetails(
                names: {'0': 'a'}, emails: {'private': 'e@1.de'})),
        dummyBaseContact.copyWith(
            details: const ContactDetails(
                names: {'0': 'a'}, emails: {'private': 'e@2.de'})));
    expect(result, 'emails');
  });

  test('compare contact details different names', () {
    final result = contactUpdateSummary(
        dummyBaseContact.copyWith(
            details: const ContactDetails(names: {'0': 'a'})),
        dummyBaseContact.copyWith(
            details: const ContactDetails(names: {'0': 'b'})));
    expect(result, 'names');
  });

  test('compare contact details different names and phones', () {
    final result = contactUpdateSummary(
        dummyBaseContact.copyWith(
            details: const ContactDetails(
                names: {'0': 'a'}, phones: {'label1': '0123'})),
        dummyBaseContact.copyWith(
            details: const ContactDetails(
                names: {'0': 'b'}, phones: {'label2': '4321'})));
    expect(result, 'names, phones');
  });

  test('compare contact same locations', () {
    final result = contactUpdateSummary(
        dummyBaseContact.copyWith(temporaryLocations: {
          '0': ContactTemporaryLocation(
              longitude: 0,
              latitude: 0,
              name: 'loc1',
              details: '',
              start: DateTime(5000),
              end: DateTime(5000).add(const Duration(days: 1)))
        }),
        dummyBaseContact.copyWith(temporaryLocations: {
          '0': ContactTemporaryLocation(
              longitude: 0,
              latitude: 0,
              name: 'loc1',
              details: '',
              start: DateTime(5000),
              end: DateTime(5000).add(const Duration(days: 1)))
        }));
    expect(result, '');
  });

  test('compare contact updated location', () {
    final result = contactUpdateSummary(
        dummyBaseContact.copyWith(temporaryLocations: {
          '0': ContactTemporaryLocation(
              longitude: 0,
              latitude: 0,
              name: 'loc1',
              details: '',
              start: DateTime(5000),
              end: DateTime(5000).add(const Duration(days: 1)))
        }),
        dummyBaseContact.copyWith(temporaryLocations: {
          '0': ContactTemporaryLocation(
              longitude: 4,
              latitude: 4,
              name: 'loc2',
              details: '',
              start: DateTime(5000),
              end: DateTime(5000).add(const Duration(days: 1)))
        }));
    expect(result, 'locations');
  });

  test('compare contact different locations', () {
    final result = contactUpdateSummary(
        dummyBaseContact.copyWith(temporaryLocations: {
          '0': ContactTemporaryLocation(
              longitude: 0,
              latitude: 0,
              name: 'loc1',
              details: '',
              start: DateTime(5000),
              end: DateTime(5000).add(const Duration(days: 1)))
        }),
        dummyBaseContact.copyWith(temporaryLocations: {
          '1': ContactTemporaryLocation(
              longitude: 4,
              latitude: 4,
              name: 'loc2',
              details: '',
              start: DateTime(5000),
              end: DateTime(5000).add(const Duration(days: 1)))
        }));
    expect(result, 'locations');
  });

  test('compare contact different but outdated locations', () {
    final result = contactUpdateSummary(
        dummyBaseContact,
        dummyBaseContact.copyWith(
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
    final result = contactUpdateSummary(
        dummyBaseContact.copyWith(
            details: const ContactDetails(picture: [1, 2, 3])),
        dummyBaseContact.copyWith(
            details: const ContactDetails(picture: [3, 2, 1])));
    expect(result, 'picture');
  });

  test('compare contact details different organizations', () {
    final result = contactUpdateSummary(
        dummyBaseContact.copyWith(
            details: ContactDetails(
                organizations: {'o': Organization(company: 'LargeCorp A')})),
        dummyBaseContact.copyWith(
            details: ContactDetails(
                organizations: {'o': Organization(company: 'LargeCorp B')})));
    expect(result, 'organizations');
  });

  test('compare contacts with matching hash codes', () {
    final c1 = dummyBaseContact.copyWith(
        name: 'name',
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

    final c2 = dummyBaseContact.copyWith(
        name: 'name',
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

  test('compare detail removal does not qualify', () {
    expect(
        contactUpdateSummary(
            dummyBaseContact.copyWith(
                details: const ContactDetails(picture: [1, 2, 3])),
            dummyBaseContact),
        isEmpty);

    expect(
        contactUpdateSummary(
            dummyBaseContact.copyWith(
                details: const ContactDetails(names: {'0': 'a'})),
            dummyBaseContact),
        isEmpty);

    expect(
        contactUpdateSummary(
            dummyBaseContact.copyWith(
                details: const ContactDetails(phones: {'landline': '123'})),
            dummyBaseContact),
        isEmpty);

    expect(
        contactUpdateSummary(
            dummyBaseContact.copyWith(
                details: const ContactDetails(emails: {'work': 'hi@mail'})),
            dummyBaseContact),
        isEmpty);

    expect(
        contactUpdateSummary(
            dummyBaseContact.copyWith(
                details: const ContactDetails(websites: {'web': 'www.tld'})),
            dummyBaseContact),
        isEmpty);

    expect(
        contactUpdateSummary(
            dummyBaseContact.copyWith(
                details: const ContactDetails(
                    socialMedias: {'mastodon': '@profile'})),
            dummyBaseContact),
        isEmpty);

    expect(
        contactUpdateSummary(
            dummyBaseContact.copyWith(
                details: ContactDetails(events: {'birthday': DateTime(2000)})),
            dummyBaseContact),
        isEmpty);

    expect(
        contactUpdateSummary(
            dummyBaseContact.copyWith(
                details: ContactDetails(
                    organizations: {'job': Organization(company: 'corp')})),
            dummyBaseContact),
        isEmpty);
  });

  test('compare location removal does not qualify', () {
    expect(
        contactUpdateSummary(
            dummyBaseContact.copyWith(addressLocations: {
              '': const ContactAddressLocation(longitude: 0, latitude: 0)
            }),
            dummyBaseContact),
        isEmpty,
        reason: 'Removing address location should not register as update');

    expect(
        contactUpdateSummary(
            dummyBaseContact.copyWith(temporaryLocations: {
              '': ContactTemporaryLocation(
                  longitude: 0,
                  latitude: 0,
                  name: '',
                  start: DateTime(2000),
                  end: DateTime(3000),
                  details: '')
            }),
            dummyBaseContact),
        isEmpty,
        reason: 'Removing temporary location should not register as update');
  });

  test('compare adding name does qualify', () {
    final result = contactUpdateSummary(
        dummyBaseContact.copyWith(
            details: const ContactDetails(names: const {})),
        dummyBaseContact.copyWith(
            details: const ContactDetails(names: {'0': 'a'})));
    expect(result, 'names');
  });
}
