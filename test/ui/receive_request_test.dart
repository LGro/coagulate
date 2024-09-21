// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:coagulate/data/models/coag_contact.dart';
import 'package:coagulate/data/repositories/contacts.dart';
import 'package:coagulate/ui/receive_request/cubit.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as mobile_scanner;

import '../mocked_providers.dart';

ContactsRepository _contactsRepositoryFromContacts(
        List<CoagContact> contacts) =>
    ContactsRepository(
        DummyPersistentStorage(
            contacts.asMap().map((_, v) => MapEntry(v.coagContactId, v))),
        DummyDistributedStorage(),
        DummySystemContacts([]));

void main() {
  group('Test Cubit State Transitions', () {
    ContactsRepository? contactsRepository;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      contactsRepository = _contactsRepositoryFromContacts([
        CoagContact(
            coagContactId: '1',
            details: ContactDetails(
                displayName: 'Existing Contact',
                name: Name(first: 'Existing', last: 'Contact')))
      ]);
    });

    blocTest<ReceiveRequestCubit, ReceiveRequestState>(
      'emits [] when nothing is called',
      build: () => ReceiveRequestCubit(contactsRepository!),
      expect: () => const <ReceiveRequestState>[],
    );

    blocTest<ReceiveRequestCubit, ReceiveRequestState>(
      'emits qrcode state when non-coagulate code is scanned',
      build: () => ReceiveRequestCubit(contactsRepository!),
      act: (c) async => c.qrCodeCaptured(mobile_scanner.BarcodeCapture(
          barcodes: [
            const mobile_scanner.Barcode(rawValue: 'not.coag.social')
          ])),
      expect: () => const [
        ReceiveRequestState(ReceiveRequestStatus.processing),
        ReceiveRequestState(ReceiveRequestStatus.qrcode)
      ],
    );

    blocTest<ReceiveRequestCubit, ReceiveRequestState>(
      'scan request qr code',
      build: () => ReceiveRequestCubit(contactsRepository!),
      act: (c) async =>
          c.qrCodeCaptured(mobile_scanner.BarcodeCapture(barcodes: [
        const mobile_scanner.Barcode(
            rawValue: 'https://coagulate.social#VLD0:key:psk:wri:ter')
      ])),
      expect: () => const [
        ReceiveRequestState(ReceiveRequestStatus.processing),
        ReceiveRequestState(ReceiveRequestStatus.receivedRequest,
            requestSettings: ContactDHTSettings(
                key: 'VLD0:key', psk: 'psk', writer: 'wri:ter'))
      ],
    );

    blocTest<ReceiveRequestCubit, ReceiveRequestState>('scan sharing qr code',
        build: () => ReceiveRequestCubit(ContactsRepository(
            DummyPersistentStorage({}),
            DummyDistributedStorage(initialDht: {
              'VLD0:key': json.encode(CoagContactDHTSchemaV1(
                      coagContactId: '',
                      details: ContactDetails(
                          displayName: 'From DHT',
                          name: Name(first: 'From', last: 'DHT')))
                  .toJson())
            }),
            DummySystemContacts([]))),
        act: (c) async => c.qrCodeCaptured(mobile_scanner.BarcodeCapture(
                barcodes: [
                  const mobile_scanner.Barcode(
                      rawValue: 'https://coagulate.social#VLD0:key:psk')
                ])),
        verify: (c) async {
          expect(c.state.status, ReceiveRequestStatus.receivedShare);
          expect(c.state.profile!.details!.displayName, 'From DHT');
          expect(c.state.profile!.dhtSettingsForReceiving,
              const ContactDHTSettings(key: 'VLD0:key', psk: 'psk'));
          expect(c.state.requestSettings,
              const ContactDHTSettings(key: 'VLD0:key', psk: 'psk'));
        });

    blocTest<ReceiveRequestCubit, ReceiveRequestState>(
        'create coagulate contact for request, no system contact access',
        setUp: () {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
                  const MethodChannel('github.com/QuisApp/flutter_contacts'),
                  (methodCall) async {
            if (methodCall.method == 'requestPermission') {
              return false;
            }
            return null;
          });
        },
        build: () => ReceiveRequestCubit(ContactsRepository(
            DummyPersistentStorage({}),
            DummyDistributedStorage(initialDht: {
              'sharingOfferKey': json.encode(CoagContactDHTSchemaV1(
                      coagContactId: '',
                      details: ContactDetails(
                          displayName: 'From DHT',
                          name: Name(first: 'From', last: 'DHT')))
                  .toJson())
            }),
            DummySystemContacts([]))),
        seed: () => const ReceiveRequestState(
            ReceiveRequestStatus.receivedRequest,
            requestSettings: ContactDHTSettings(
                key: 'sharingOfferKey', psk: 'psk', writer: 'writer')),
        act: (c) async {
          c.updateNewRequesterContact('New Contact Name');
          await c.createNewContact();
        },
        verify: (c) {
          expect(c.state.status, ReceiveRequestStatus.success);
          expect(c.state.profile!.details!.displayName, 'From DHT');
          expect(c.state.profile!.dhtSettingsForSharing, null,
              reason:
                  'They are not part of circles, no need for a DHT record.');
          expect(
              c.state.profile!.dhtSettingsForReceiving,
              const ContactDHTSettings(
                  key: 'sharingOfferKey', psk: 'psk', writer: 'writer'));
        });

    blocTest<ReceiveRequestCubit, ReceiveRequestState>(
        'create coagulate contact from offer to share, no system contact access',
        setUp: () {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
                  const MethodChannel('github.com/QuisApp/flutter_contacts'),
                  (methodCall) async {
            if (methodCall.method == 'requestPermission') {
              return false;
            }
            return null;
          });
        },
        build: () => ReceiveRequestCubit(ContactsRepository(
            DummyPersistentStorage({}),
            DummyDistributedStorage(initialDht: {
              'sharingOfferKey': json.encode(CoagContactDHTSchemaV1(
                      coagContactId: '',
                      details: ContactDetails(
                          displayName: 'From DHT',
                          name: Name(first: 'From', last: 'DHT')))
                  .toJson())
            }),
            DummySystemContacts([]))),
        seed: () => const ReceiveRequestState(
            ReceiveRequestStatus.receivedShare,
            requestSettings: ContactDHTSettings(
                key: 'sharingOfferKey', psk: 'psk', writer: 'writer')),
        act: (c) async => c.createNewContact(),
        verify: (c) {
          expect(c.state.status, ReceiveRequestStatus.success);
          expect(c.state.profile!.details!.displayName, 'From DHT');
          expect(
              c.state.profile!.dhtSettingsForReceiving,
              const ContactDHTSettings(
                  key: 'sharingOfferKey', psk: 'psk', writer: 'writer'));
        });

    blocTest<ReceiveRequestCubit, ReceiveRequestState>(
        'link existing coagulate contact for a request for the user to share',
        build: () => ReceiveRequestCubit(ContactsRepository(
            DummyPersistentStorage({
              '1': CoagContact(
                  coagContactId: '1',
                  details: ContactDetails(
                      displayName: 'Existing Contact',
                      name: Name(first: 'Existing', last: 'Contact')))
            }),
            DummyDistributedStorage(),
            DummySystemContacts([
              Contact(
                  id: 'sysID0',
                  displayName: 'Recent Sys Profile Name',
                  name: Name(first: 'Profile'))
            ]),
            // Explicitly initialize during act to ensure it finished
            initialize: false)),
        seed: () => const ReceiveRequestState(
            ReceiveRequestStatus.receivedRequest,
            requestSettings: ContactDHTSettings(
                key: 'requestedSharingKey', psk: 'psk', writer: 'writer')),
        act: (c) async {
          // Ensure profile contact is present, because it's required for
          //  fulfilling the request
          await c.contactsRepository.initialize();
          // Add profile contact only now to ensure fetching the most recent
          //  version happens also after initialize
          await c.contactsRepository.saveContact(CoagContact(
              coagContactId: '0',
              systemContact: Contact(
                  id: 'sysID0',
                  displayName: 'Profile Contact',
                  name: Name(first: 'Profile'))));
          await c.contactsRepository.updateProfileContact('0');
          // Link the request to share to an existing contact
          await c.linkExistingContactRequested('1');
        },
        verify: (c) {
          final dht = (c.contactsRepository.distributedStorage
                  as DummyDistributedStorage)
              .dht;
          expect(dht.length, 2);
          // The requested sharing key and a key auto generated for receiving
          expect(dht.keys.toSet(), {
            'requestedSharingKey',
            'VLD0:DUMMYwPaM1X1-d45IYDGLAAKQRpW2bf8cNKCIPNuW0M'
          });

          expect(c.state.profile?.coagContactId, '1');
          expect(c.state.profile?.dhtSettingsForReceiving?.key,
              'VLD0:DUMMYwPaM1X1-d45IYDGLAAKQRpW2bf8cNKCIPNuW0M');
          expect(c.state.profile?.dhtSettingsForSharing?.key,
              'requestedSharingKey');
          expect(
              c.state.profile?.details,
              ContactDetails(
                  displayName: 'Existing Contact',
                  name: Name(first: 'Existing', last: 'Contact')));
        });

    blocTest<ReceiveRequestCubit, ReceiveRequestState>(
        'link existing coagulate contact to sharing offer',
        // Init with on existing contact and a DHT ready with one key
        build: () => ReceiveRequestCubit(ContactsRepository(
            DummyPersistentStorage({
              '1': CoagContact(
                  coagContactId: '1',
                  details: ContactDetails(
                      displayName: 'Existing Contact',
                      name: Name(first: 'Existing', last: 'Contact')))
            }),
            DummyDistributedStorage(initialDht: {
              'sharingOfferKey': json.encode(CoagContactDHTSchemaV1(
                      coagContactId: '',
                      details: ContactDetails(
                          displayName: 'From DHT',
                          name: Name(first: 'From', last: 'DHT')))
                  .toJson())
            }),
            DummySystemContacts([]),
            // Explicitly initialize during act to ensure it finished
            initialize: false)),
        // Seed with a contact offering to share via our prepared dht record
        seed: () => const ReceiveRequestState(
            ReceiveRequestStatus.receivedShare,
            requestSettings:
                ContactDHTSettings(key: 'sharingOfferKey', psk: 'psk')),
        // Link the sharing offer to our one existing contact
        act: (c) async => c.contactsRepository
            .initialize()
            .then((_) => c.linkExistingContactSharing('1')),
        verify: (c) {
          // Verify that contact to contain the dht settings for receiving more
          //  updates as well as the details from the DHT
          expect(c.state.status, ReceiveRequestStatus.success);
          expect(c.state.profile?.coagContactId, '1');
          expect(c.state.profile?.dhtSettingsForReceiving,
              const ContactDHTSettings(key: 'sharingOfferKey', psk: 'psk'));
          expect(
              c.state.profile?.details,
              ContactDetails(
                  displayName: 'From DHT',
                  name: Name(first: 'From', last: 'DHT')));
          // Verify that this is also reflected in the repository with still only
          //  one contact
          expect(
              (c.contactsRepository.distributedStorage
                      as DummyDistributedStorage)
                  .dht
                  .length,
              1);
          final contacts = c.contactsRepository.getContacts();
          expect(contacts.length, 1);
          expect(contacts['1']?.details?.displayName, 'From DHT');
        });
  });
}
