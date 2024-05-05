// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:coagulate/data/models/coag_contact.dart';
import 'package:coagulate/data/repositories/contacts.dart';
import 'package:coagulate/ui/profile/page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../mocked_providers.dart';

Future<Widget> createProfilePage(ContactsRepository contactsRepository) async =>
    RepositoryProvider.value(
        value: contactsRepository,
        child: LocalizedApp(
            await LocalizationDelegate.create(
                fallbackLocale: 'en_US', supportedLocales: ['en_US', 'de_DE']),
            const MaterialApp(
                home: Directionality(
              textDirection: TextDirection.ltr,
              child: ProfilePage(),
            ))));

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

ContactsRepository _contactsRepositoryFromContact() => ContactsRepository(
    DummyPersistentStorage(
        [_profileContact].asMap().map((_, v) => MapEntry(v.coagContactId, v))),
    DummyDistributedStorage(),
    DummySystemContacts([_profileContact.systemContact!]));

void main() {
  testWidgets('Test Profile Displayed', (tester) async {
    final contactsRepository = _contactsRepositoryFromContact();

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

    contactsRepository.timerDhtRefresh?.cancel();
    contactsRepository.timerPersistentStorageRefresh?.cancel();
  });
}
