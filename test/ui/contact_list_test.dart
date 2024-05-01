// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:coagulate/data/models/coag_contact.dart';
import 'package:coagulate/data/models/contact_update.dart';
import 'package:coagulate/data/providers/distributed_storage/base.dart';
import 'package:coagulate/data/providers/persistent_storage/base.dart';
import 'package:coagulate/data/repositories/contacts.dart';
import 'package:coagulate/ui/contact_list/page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_translate/flutter_translate.dart';

// TODO: enable feeding dummy data into contacts repo

class DummyPersistentStorage extends PersistentStorage {
  DummyPersistentStorage(this.contacts, {this.profileContactId});

  Map<String, CoagContact> contacts;
  String? profileContactId;

  @override
  Future<void> addUpdate(ContactUpdate update) {
    // TODO: implement addUpdate
    throw UnimplementedError();
  }

  @override
  Future<Map<String, CoagContact>> getAllContacts() => Future.value(contacts);

  @override
  Future<CoagContact> getContact(String coagContactId) =>
      Future.value(contacts[coagContactId]);

  @override
  Future<String?> getProfileContactId() => Future.value(profileContactId);

  @override
  Future<List<ContactUpdate>> getUpdates() => Future.value([]);

  @override
  Future<void> removeContact(String coagContactId) async {
    contacts.remove(coagContactId);
  }

  @override
  Future<void> setProfileContactId(String profileContactId) {
    // TODO: implement setProfileContactId
    throw UnimplementedError();
  }

  @override
  Future<void> updateContact(CoagContact contact) async {
    contacts[contact.coagContactId] = contact;
  }
}

class DummyDistributedStorage extends DistributedStorage {
  @override
  Future<(String, String)> createDHTRecord() {
    // TODO: implement createDHTRecord
    throw UnimplementedError();
  }

  @override
  Future<bool> isUpToDateSharingDHT(CoagContact contact) {
    // TODO: implement isUpToDateSharingDHT
    throw UnimplementedError();
  }

  @override
  Future<String> readPasswordEncryptedDHTRecord(
      {required String recordKey, required String secret}) {
    // TODO: implement readPasswordEncryptedDHTRecord
    throw UnimplementedError();
  }

  @override
  Future<CoagContact> updateContactReceivingDHT(CoagContact contact) {
    // TODO: implement updateContactReceivingDHT
    throw UnimplementedError();
  }

  @override
  Future<CoagContact> updateContactSharingDHT(CoagContact contact) {
    // TODO: implement updateContactSharingDHT
    throw UnimplementedError();
  }

  @override
  Future<void> updatePasswordEncryptedDHTRecord(
      {required String recordKey,
      required String recordWriter,
      required String secret,
      required String content}) {
    // TODO: implement updatePasswordEncryptedDHTRecord
    throw UnimplementedError();
  }

  @override
  Future<void> watchDHTRecord(String key) {
    // TODO: implement watchDHTRecord
    throw UnimplementedError();
  }
}

Future<Widget> createContactList(ContactsRepository contactsRepository) async =>
    RepositoryProvider.value(
        value: contactsRepository,
        child: LocalizedApp(
            await LocalizationDelegate.create(
                fallbackLocale: 'en_US', supportedLocales: ['en_US', 'de_DE']),
            const MaterialApp(
                home: Directionality(
              textDirection: TextDirection.ltr,
              child: ContactListPage(),
            ))));

void main() {
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
          DummyDistributedStorage());

      final contactList = await createContactList(contactsRepository);
      await tester.pumpWidget(contactList);
      expect(find.text('Contact 1'), findsOneWidget);
      await tester.fling(find.byType(ListView), const Offset(0, -200), 3000);
      await tester.pumpAndSettle();
      expect(find.text('Contact 1'), findsNothing);

      contactsRepository.timerDhtRefresh!.cancel();
      contactsRepository.timerPersistentStorageRefresh!.cancel();
    });
  });
}
