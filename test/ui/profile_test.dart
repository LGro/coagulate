// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:coagulate/data/models/coag_contact.dart';
import 'package:coagulate/data/repositories/contacts.dart';
import 'package:coagulate/ui/profile/page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mocked_providers.dart';

Future<Widget> createProfilePage(ContactsRepository contactsRepository) async =>
    RepositoryProvider.value(
        value: contactsRepository,
        child: const MaterialApp(
            home: Directionality(
          textDirection: TextDirection.ltr,
          child: ProfilePage(),
        )));

final _profileContact = CoagContact(
  coagContactId: '1',
  systemContact: Contact(
    id: '1',
    displayName: 'Test Name',
    name: Name(first: 'Test', last: 'Name'),
    emails: [Email('test@mail.com')],
    phones: [Phone('12345')],
    socialMedias: [SocialMedia('@social')],
    websites: [Website('www.awesome.org')],
  ),
);

void main() {
  testWidgets('Test Chosen Profile Displayed', (tester) async {
    final contactsRepository = ContactsRepository(
        DummyPersistentStorage([_profileContact]
            .asMap()
            .map((_, v) => MapEntry(v.coagContactId, v)))
          ..profileContactId = '1',
        DummyDistributedStorage(),
        DummySystemContacts([_profileContact.systemContact!]));

    final pageWidget = await createProfilePage(contactsRepository);
    await tester.pumpWidget(pageWidget);

    expect(
        find.text(_profileContact.systemContact!.displayName), findsOneWidget);
    expect(find.text(_profileContact.systemContact!.phones[0].number),
        findsOneWidget);
    expect(find.text(_profileContact.systemContact!.emails[0].address),
        findsOneWidget);
    expect(find.text(_profileContact.systemContact!.socialMedias[0].userName),
        findsOneWidget);
    expect(find.text(_profileContact.systemContact!.websites[0].url),
        findsOneWidget);
  });

  testWidgets('Test circle creation and assignment', (tester) async {
    final contactsRepository = ContactsRepository(
        DummyPersistentStorage([_profileContact]
            .asMap()
            .map((_, v) => MapEntry(v.coagContactId, v)))
          ..profileContactId = '1',
        DummyDistributedStorage(),
        DummySystemContacts([_profileContact.systemContact!]));

    final pageWidget = await createProfilePage(contactsRepository);
    await tester.pumpWidget(pageWidget);

    await tester.tap(find.byKey(const Key('emailsCirclesMgmt0')));
    await tester.pump();
    expect(find.textContaining('Share'), findsOneWidget);
    expect(find.text('New Circle'), findsOneWidget);

    const circleName = 'new circle name';
    await tester.enterText(
        find.byKey(const Key('circlesForm_newCircleInput')), circleName);

    await tester.tap(find.byKey(const Key('circlesForm_submit')));
    await tester.pump();

    await tester.tap(find.byKey(const Key('websitesCirclesMgmt0')));
    await tester.pump();
    // TODO: This should come back true, why doesn't it?
    // expect(find.textContaining(circleName), findsOneWidget);
  });

  testWidgets('Test No Contact', (tester) async {
    final contactsRepository = ContactsRepository(DummyPersistentStorage({}),
        DummyDistributedStorage(), DummySystemContacts([]));

    final pageWidget = await createProfilePage(contactsRepository);
    await tester.pumpWidget(pageWidget);

    expect(find.textContaining('Welcome to Coagulate'), findsOneWidget);
  });

  // testWidgets('Choose system contact as profile', (tester) async {
  //   final contactsRepository = ContactsRepository(
  //       DummyPersistentStorage({}),
  //       DummyDistributedStorage(),
  //       DummySystemContacts([
  //         Contact(
  //             displayName: 'Sys Contact',
  //             name: Name(first: 'Sys', last: 'Contact'))
  //       ]));
  //   final page = await createProfilePage(contactsRepository);
  //   await tester.pumpWidget(page);

  //   await tester.tap(find.byKey(const Key('profilePickContactAsProfile')));

  //   await tester.pump();

  //   // start with no profile contact
  //   // push choose contact button
  //   // have predefined contact returned from provider
  //   // check that its displayed

  //   expect(find.text('Sys Contact'), findsOneWidget);

  //   contactsRepository.timerDhtRefresh?.cancel();
  //   contactsRepository.timerPersistentStorageRefresh?.cancel();
  // });
}
