// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:typed_data';

import 'package:coagulate/data/models/coag_contact.dart';
import 'package:coagulate/data/models/contact_location.dart';
import 'package:coagulate/data/models/profile_sharing_settings.dart';
import 'package:coagulate/data/providers/system_contacts/base.dart';
import 'package:coagulate/data/repositories/contacts.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_test/flutter_test.dart';

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
    final filtered = filterContactDetailsList<Phone>([Phone('123')], {}, []);
    expect(filtered, []);
  });

  test('filter details list, no allowed  circles', () {
    final filtered =
        filterContactDetailsList<Phone>([Phone('123')], {}, ['C1', 'C2']);
    expect(filtered, []);
  });

  test('filter details list, one allowed circles', () {
    final filtered = filterContactDetailsList<Phone>([
      Phone('123', label: PhoneLabel.home),
      Phone('321', label: PhoneLabel.work)
    ], {
      'work': ['C2']
    }, [
      'C1',
      'C2'
    ]);
    expect(filtered, [Phone('321', label: PhoneLabel.work)]);
  });

  // test('filter details without active circles', () {
  //   final filteredDetails = filterDetails(
  //       ContactDetails(
  //         names: const {'0': 'Main Name'},
  //         phones: [Phone('1234')],
  //         emails: [Email('hi@mail.com')],
  //         addresses: [Address('Home 123')],
  //         organizations: [Organization(company: 'Corp', title: 'CEO')],
  //         socialMedias: [SocialMedia('@beste')],
  //         websites: [Website('awesome.org')],
  //         events: [Event(month: 1, day: 30)],
  //       ),
  //       const ProfileSharingSettings(),
  //       []);
  //   expect(filteredDetails.names, {});
  //   expect(filteredDetails.emails, []);
  //   expect(filteredDetails.phones, []);
  //   expect(filteredDetails.addresses, []);
  //   expect(filteredDetails.organizations, []);
  //   expect(filteredDetails.socialMedias, []);
  //   expect(filteredDetails.websites, []);
  //   expect(filteredDetails.events, []);
  // });

  // test('filter to future events', () {
  //   final contact = CoagContact(
  //       coagContactId: '1',
  //       systemContact: Contact(displayName: 'Contact Name'),
  //       temporaryLocations: [
  //         ContactTemporaryLocation(
  //             coagContactId: '1',
  //             name: 'past',
  //             details: '',
  //             start: DateTime.now().subtract(Duration(days: 2)),
  //             end: DateTime.now().subtract(Duration(days: 1)),
  //             longitude: 12,
  //             latitude: 13),
  //         ContactTemporaryLocation(
  //             coagContactId: '1',
  //             name: 'less than a day ago',
  //             details: '',
  //             start: DateTime.now().subtract(const Duration(hours: 2)),
  //             end: DateTime.now().subtract(const Duration(hours: 1)),
  //             circles: const ['Circle'],
  //             longitude: 12,
  //             latitude: 13),
  //         ContactTemporaryLocation(
  //             coagContactId: '1',
  //             name: 'future',
  //             details: '',
  //             start: DateTime.now().add(const Duration(days: 1)),
  //             end: DateTime.now().add(const Duration(days: 2)),
  //             circles: const ['Circle'],
  //             longitude: 15,
  //             latitude: 16),
  //       ]);
  //   final filtered = filterAccordingToSharingProfile(
  //       profile: contact,
  //       settings: const ProfileSharingSettings(),
  //       activeCircles: ['Circle'],
  //       shareBackSettings: null);
  //   expect(filtered.temporaryLocations.length, 1);
  //   expect(filtered.temporaryLocations[0].name, 'future');
  //   expect(filtered.temporaryLocations[0], contact.temporaryLocations[2]);
  // });

  test('equate contacts with stripped photo', () {
    final contact = Contact(
        displayName: 'Exampe Contact',
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
      0: ContactAddressLocation(
          coagContactId: '1', longitude: 10, latitude: 12, name: 'loc0'),
      2: ContactAddressLocation(
          coagContactId: '1', longitude: 10, latitude: 12, name: 'loc2'),
      3: ContactAddressLocation(
          coagContactId: '1', longitude: 10, latitude: 12, name: 'loc3'),
    };
    const settings = ProfileSharingSettings(addresses: {
      '0|home': ['circle1'],
      '3|work': ['circle2', 'circle3'],
    });
    const activeCircles = ['circle1'];
    final filteredLocations =
        filterAddressLocations(locations, settings, activeCircles);
    expect(filteredLocations.length, 1);
    expect(filteredLocations.keys.first, 0);
    expect(filteredLocations.values.first.name, 'loc0');
  });

  test('filter names', () {
    final fileteredNames = filterNames({
      'nick': 'dudi',
      'fullname': 'Dudeli Dideli'
    }, {
      'nick': ['circle1']
    }, [
      'circle1',
      'circle2'
    ]);
    expect(fileteredNames, {'nick': 'dudi'});
  });
}
