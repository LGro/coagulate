// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:coagulate/data/models/coag_contact.dart';
import 'package:coagulate/data/repositories/contacts.dart';
import 'package:coagulate/ui/contact_list/cubit.dart';
import 'package:coagulate/ui/contact_list/page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mocked_providers.dart';

Future<Widget> createContactList(ContactsRepository contactsRepository) async =>
    RepositoryProvider.value(
        value: contactsRepository,
        child: const MaterialApp(
            home: Directionality(
          textDirection: TextDirection.ltr,
          child: ContactListPage(),
        )));

void main() {
  group('Utilities', () {
    test('extractAllValuesToString', () {
      expect(
          extractAllValuesToString({
            'root': {
              'list': [1, 2, 3],
              'string': 'string'
            }
          }),
          '1|2|3|string');
    });
    test('filterAndSortContacts', () {
      final contacts = [
        CoagContact(
            coagContactId: '1',
            details: ContactDetails(
                displayName: 'Daisy', name: Name(first: 'Daisy'))),
      ];
      expect(filterAndSortContacts(contacts, filter: 'name').length, 0);
      expect(filterAndSortContacts(contacts, filter: 'dai').length, 1);
    });
  });
  group('Contact List Page Widget Tests', () {
    testWidgets('Testing Scrolling', (tester) async {
      final contactsRepository = ContactsRepository(
          DummyPersistentStorage(List<CoagContact>.generate(
                  1000,
                  (i) => CoagContact(
                      coagContactId: '$i',
                      details: ContactDetails(
                          displayName: 'Contact $i',
                          name: Name(first: 'Contact', last: '$i'))))
              .asMap()
              .map((k, v) => MapEntry('$k', v))),
          DummyDistributedStorage(),
          DummySystemContacts([]));

      final contactList = await createContactList(contactsRepository);
      await tester.pumpWidget(contactList);
      expect(find.text('Contact 1'), findsOneWidget);
      await tester.fling(find.byType(ListView), const Offset(0, -200), 3000);
      await tester.pumpAndSettle();
      expect(find.text('Contact 1'), findsNothing);
    });
  });
}
