// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:typed_data';

import 'package:coagulate/data/models/coag_contact.dart';
import 'package:coagulate/data/models/contact_location.dart';
import 'package:coagulate/data/models/profile_sharing_settings.dart';
import 'package:coagulate/data/providers/system_contacts/base.dart';
import 'package:coagulate/data/repositories/contacts.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../mocked_providers.dart';

// TODO: Group tests
void main() {
  // test('contact detail key construction', () {
  //   expect(contactDetailKey<Phone>(1, Phone('123', label: PhoneLabel.home)),
  //       '1|home');
  //   expect(
  //       contactDetailKey<Phone>(
  //           2, Phone('123', label: PhoneLabel.custom, customLabel: 'CUZTOM')),
  //       '2|CUZTOM');
  //   expect(
  //       contactDetailKey<Organization>(
  //           3, Organization(company: 'corp', title: 'CEO')),
  //       '3|corp');
  // });

  test('filter details list, no active circles', () {
    final filtered = filterContactDetailsList({'mobile': '123'}, {}, []);
    expect(filtered, isEmpty);
  });

  test('filter details list, no allowed  circles', () {
    final filtered =
        filterContactDetailsList({'mobile': '123'}, {}, ['C1', 'C2']);
    expect(filtered, isEmpty);
  });

  test('filter details list, one allowed circles', () {
    final filtered = filterContactDetailsList({
      'home': '123',
      'work': '321'
    }, {
      'work': ['C2']
    }, [
      'C1',
      'C2'
    ]);
    expect(filtered, {'work': '321'});
  });

  test('filter details without active circles', () {
    final pictures = <String, List<int>>{
      'dummy': [1, 2, 3]
    };
    final filteredDetails = filterDetails(
        pictures,
        ContactDetails(
          names: const {'0': 'Main Name'},
          phones: const {'p': '1234'},
          emails: const {'e1': 'hi@mail.com'},
          socialMedias: const {'s': '@beste'},
          websites: const {'w': 'awesome.org'},
          organizations: {'o': Organization(company: 'LargeCorp')},
          events: {'e': DateTime.now()},
        ),
        const ProfileSharingSettings(),
        {});
    expect(filteredDetails.names, isEmpty);
    expect(filteredDetails.emails, isEmpty);
    expect(filteredDetails.phones, isEmpty);
    expect(filteredDetails.socialMedias, isEmpty);
    expect(filteredDetails.websites, isEmpty);
    expect(filteredDetails.events, isEmpty);
    expect(filteredDetails.organizations, isEmpty);
    expect(filteredDetails.picture, isNull);
  });

  test('filter to future events', () {
    final profile = ProfileInfo('app-user-id',
        // ignore: avoid_redundant_argument_values
        sharingSettings: const ProfileSharingSettings(),
        temporaryLocations: {
          't1': ContactTemporaryLocation(
              coagContactId: '1',
              name: 'past',
              details: '',
              start: DateTime.now().subtract(const Duration(days: 2)),
              end: DateTime.now().subtract(const Duration(days: 1)),
              longitude: 12,
              latitude: 13),
          't2': ContactTemporaryLocation(
              coagContactId: '1',
              name: 'less than a day ago',
              details: '',
              start: DateTime.now().subtract(const Duration(hours: 2)),
              end: DateTime.now().subtract(const Duration(hours: 1)),
              circles: const ['Circle'],
              longitude: 12,
              latitude: 13),
          't3': ContactTemporaryLocation(
              coagContactId: '1',
              name: 'future',
              details: '',
              start: DateTime.now().add(const Duration(days: 1)),
              end: DateTime.now().add(const Duration(days: 2)),
              circles: const ['Circle'],
              longitude: 15,
              latitude: 16),
        });
    final filtered = filterAccordingToSharingProfile(
      profile: profile,
      activeCirclesWithMemberCount: {'Circle': 2},
      dhtSettings: DhtSettings(myKeyPair: dummyTypedKeyPair()),
      sharePersonalUniqueId: true,
      introductions: [],
    );
    expect(filtered.temporaryLocations.length, 1);
    expect(filtered.temporaryLocations['t3']?.name, 'future');
    expect(filtered.temporaryLocations['t3'], profile.temporaryLocations['t3']);
  });

  test('equate contacts with stripped photo', () {
    final contact = Contact(
        displayName: 'Example Contact',
        name: Name(first: 'Example', last: 'Contact'),
        phones: [Phone('12324')],
        photo: Uint8List(64));
    final contactJson = contact.toJson();
    contactJson['photo'] = null;
    final contactWithoutPhoto = Contact.fromJson(contactJson);
    expect(systemContactsEqual(contact, contactWithoutPhoto), true);
  });

  test('filter addresses', () {
    const locations = {
      'loc0': ContactAddressLocation(
          coagContactId: '1', longitude: 10, latitude: 12),
      'loc2': ContactAddressLocation(
          coagContactId: '1', longitude: 10, latitude: 12),
      'loc3': ContactAddressLocation(
          coagContactId: '1', longitude: 10, latitude: 12),
    };
    const settings = ProfileSharingSettings(addresses: {
      'loc0': ['circle1'],
      'loc3': ['circle2', 'circle3'],
    });
    const activeCircles = ['circle1'];
    final filteredLocations =
        filterAddressLocations(locations, settings, activeCircles);
    expect(filteredLocations.length, 1);
    expect(filteredLocations.keys.first, 'loc0');
    expect(filteredLocations.values.first.longitude, 10);
  });

  test('filter names', () {
    final filteredNames = filterNames({
      'nick': 'dudi',
      'fullname': 'Dudeli Dideli'
    }, {
      'nick': ['circle1']
    }, [
      'circle1',
      'circle2'
    ]);
    expect(filteredNames, {'nick': 'dudi'});
  });

  test('remove circle', () async {
    final repo = ContactsRepository(
        DummyPersistentStorage({}),
        DummyDistributedStorage(transparent: false),
        DummySystemContacts([]),
        'UserA',
        initialize: false);
    await repo.addCircle('c1', 'c1');
    await repo.addCircle('c2', 'c2');
    await repo.updateCircleMemberships({
      'p1': ['c1', 'c2'],
      'p2': ['c2'],
    });

    await repo.removeCircle('c1');

    expect(repo.getCircleMemberships()['p1'], ['c2']);
    expect(repo.getCircleMemberships()['p2'], ['c2']);
  });
}
