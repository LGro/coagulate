// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:io';
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
    const details = ContactDetails(emails: {'e1': '1@com'});
    const sameDetails = ContactDetails(emails: {'e1': '1@com'});
    const otherDetails = ContactDetails(emails: {'e1': '2@com'});
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
        myIdentity: dummyKeyPair,
        myIntroductionKeyPair: dummyKeyPair,
        dhtSettings: DhtSettings(myNextKeyPair: dummyKeyPair),
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
        myIdentity: dummyKeyPair,
        myIntroductionKeyPair: dummyKeyPair,
        dhtSettings: DhtSettings(myNextKeyPair: dummyKeyPair),
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

  test('merge system contacts', () {
    final merged = mergeSystemContacts(
        Contact(id: 'sys', displayName: 'Sys Name', phones: [
          Phone('1234-sys'),
          Phone('0000-coag',
              label: PhoneLabel.custom,
              customLabel: 'old mansion $coagulateManagedLabelSuffix')
        ]),
        Contact(id: 'coag', displayName: 'Coag Name', phones: [
          Phone('54321-coag', label: PhoneLabel.custom, customLabel: 'mansion')
        ]));
    expect(merged.id, 'sys');
    expect(merged.displayName, 'Sys Name');
    expect(merged.phones.length, 2,
        reason: 'old mansion should be removed and mansion added '
            'alongside existing system phone');
    expect(merged.phones[0].number, '1234-sys');
    expect(merged.phones[1].number, '54321-coag');
    expect(
        merged.phones[1].customLabel, 'mansion $coagulateManagedLabelSuffix');
  });

  test('coveredByCoagulate Email with mismatched label still covers', () {
    final isCovered = coveredByCoagulate(Email('covered@coag.org'), [
      Email('other@corp.co'),
      Email('covered@coag.org', label: EmailLabel.school)
    ]);
    expect(isCovered, true);
  });

  test('removeCoagManagedSuffixes for phone', () {
    final withoutSuffixes = removeCoagManagedSuffixes(Contact(phones: [
      Phone('123',
          label: PhoneLabel.custom, customLabel: addCoagSuffix('mobile'))
    ]));
    expect(withoutSuffixes.phones.length, 1);
    expect(withoutSuffixes.phones.first.customLabel, 'mobile');
  });

  test('add and remove coagulate managed suffix', () {
    const withSuffix = 'mobile $coagulateManagedLabelSuffix';
    expect(removeCoagSuffix(addCoagSuffix(withSuffix)), 'mobile');

    const withoutSuffix = 'mobile';
    expect(removeCoagSuffix(addCoagSuffix(withoutSuffix)), withoutSuffix);

    const withNewlinesAndSuffix = 'foo\n\n $coagulateManagedLabelSuffix';
    expect(removeCoagSuffix(addCoagSuffix(withNewlinesAndSuffix)), 'foo');

    expect(addCoagSuffixNewline('my note\n\n\n'),
        'my note\n\n$coagulateManagedLabelSuffix');
  });

  test('contact details deserialization for backwards compatibility', () async {
    final details = ContactDetails(
        publicKey: 'pub-key',
        picture: const [1, 2, 3],
        names: const {'n': 'My Name'},
        phones: const {'p': '123'},
        emails: const {'e': 'hi@mail'},
        websites: const {'w': 'www.com'},
        socialMedias: const {'s': '@social'},
        events: {'y2k': DateTime(2000)});

    final file = File('test/assets/contact_details.json');
    final contents = await file.readAsString();
    final deserializedDetails =
        ContactDetails.fromJson(json.decode(contents) as Map<String, dynamic>);

    expect(details, deserializedDetails);
  });
}
