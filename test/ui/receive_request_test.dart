// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

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
        DummyDistributedStorage());

void main() {
  group('Test Cubit State Transitions', () {
    ContactsRepository? contactsRepository;

    setUp(() {
      contactsRepository = _contactsRepositoryFromContacts([
        CoagContact(
            coagContactId: '1',
            details: ContactDetails(
                displayName: 'Existing Contact',
                name: Name(first: 'Existing', last: 'Contact')))
      ]);
    });

    tearDown(() {
      contactsRepository?.timerDhtRefresh!.cancel();
      contactsRepository?.timerPersistentStorageRefresh!.cancel();
    });

    blocTest<ReceiveRequestCubit, ReceiveRequestState>(
      'emits [] when nothing is called',
      setUp: TestWidgetsFlutterBinding.ensureInitialized,
      build: () => ReceiveRequestCubit(contactsRepository!),
      expect: () => const <ReceiveRequestState>[],
    );

    blocTest<ReceiveRequestCubit, ReceiveRequestState>(
      'emits qrcode state when non-coagulate code is scanned',
      setUp: TestWidgetsFlutterBinding.ensureInitialized,
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
      setUp: TestWidgetsFlutterBinding.ensureInitialized,
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
        setUp: TestWidgetsFlutterBinding.ensureInitialized,
        build: () => ReceiveRequestCubit(contactsRepository!),
        act: (c) async => c.qrCodeCaptured(mobile_scanner.BarcodeCapture(
                barcodes: [
                  const mobile_scanner.Barcode(
                      rawValue: 'https://coagulate.social#VLD0:key:psk')
                ])),
        verify: (c) async =>
            c.state.status.isSuccess &&
            c.state.profile!.details!.displayName == 'Contact From DHT' &&
            c.state.profile!.dhtSettingsForReceiving ==
                const ContactDHTSettings(key: 'VLD0:key', psk: 'psk'));

    blocTest<ReceiveRequestCubit, ReceiveRequestState>(
        'create coagulate contact for request, no system contact access',
        setUp: () {
          TestWidgetsFlutterBinding.ensureInitialized();
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
        build: () => ReceiveRequestCubit(contactsRepository!),
        seed: () => const ReceiveRequestState(
            ReceiveRequestStatus.receivedRequest,
            requestSettings:
                ContactDHTSettings(key: 'key', psk: 'psk', writer: 'writer')),
        act: (c) async {
          c.updateNewRequesterContact('New Contact Name');
          await c.createNewContact();
        },
        verify: (c) =>
            c.state.status.isSuccess &&
            c.state.profile!.details!.displayName == 'New Contact Name' &&
            // TODO: We might actually want to already prep share back options here
            c.state.profile!.dhtSettingsForReceiving == null &&
            c.state.profile!.dhtSettingsForSharing ==
                const ContactDHTSettings(
                    key: 'key', psk: 'psk', writer: 'writer'));

    blocTest<ReceiveRequestCubit, ReceiveRequestState>(
        'link existing coagulate contact for request',
        setUp: TestWidgetsFlutterBinding.ensureInitialized,
        build: () => ReceiveRequestCubit(contactsRepository!),
        seed: () => const ReceiveRequestState(
            ReceiveRequestStatus.receivedRequest,
            requestSettings:
                ContactDHTSettings(key: 'key', psk: 'psk', writer: 'writer')),
        act: (c) async => c.linkExistingContactRequested(CoagContact(
            coagContactId: '1',
            details: ContactDetails(
                displayName: 'Existing Contact',
                name: Name(first: 'Existing', last: 'Contact')))),
        expect: () => [
              ReceiveRequestState(ReceiveRequestStatus.success,
                  profile: CoagContact(
                      coagContactId: '1',
                      // TODO: We might actually want to already prep share back options here
                      dhtSettingsForReceiving: null,
                      dhtSettingsForSharing: const ContactDHTSettings(
                          key: 'key', psk: 'psk', writer: 'writer'),
                      details: ContactDetails(
                          displayName: 'Existing Contact',
                          name: Name(first: 'Existing', last: 'Contact'))))
            ]);

    blocTest<ReceiveRequestCubit, ReceiveRequestState>(
        'link existing coagulate contact for sharing',
        setUp: TestWidgetsFlutterBinding.ensureInitialized,
        build: () => ReceiveRequestCubit(contactsRepository!),
        seed: () => ReceiveRequestState(ReceiveRequestStatus.receivedShare,
            profile: CoagContact(
                coagContactId: 'randomly-generated',
                dhtSettingsForReceiving:
                    const ContactDHTSettings(key: 'key', psk: 'psk'),
                details: ContactDetails(
                    displayName: 'Sharing Contact',
                    name: Name(first: 'Sharing', last: 'Contact'))),
            requestSettings: const ContactDHTSettings(
                key: 'key', psk: 'psk', writer: 'writer')),
        act: (c) async => c.linkExistingContactSharing(CoagContact(
            coagContactId: '1',
            details: ContactDetails(
                displayName: 'Existing Contact',
                name: Name(first: 'Existing', last: 'Contact')))),
        expect: () => [
              ReceiveRequestState(ReceiveRequestStatus.success,
                  profile: CoagContact(
                      coagContactId: '1',
                      dhtSettingsForReceiving:
                          const ContactDHTSettings(key: 'key', psk: 'psk'),
                      details: ContactDetails(
                          displayName: 'Sharing Contact',
                          name: Name(first: 'Sharing', last: 'Contact'))))
            ]);
  });
}
