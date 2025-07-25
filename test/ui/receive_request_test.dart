// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:coagulate/data/models/coag_contact.dart';
import 'package:coagulate/data/repositories/contacts.dart';
import 'package:coagulate/ui/receive_request/cubit.dart';
import 'package:coagulate/ui/utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as mobile_scanner;
import 'package:veilid_support/veilid_support.dart';

import '../mocked_providers.dart';

const appUserName = 'App User Name';

FixedEncodedString43 _dummyPsk(int i) =>
    FixedEncodedString43.fromBytes(Uint8List.fromList(List.filled(32, i)));

ContactsRepository _contactsRepositoryFromContacts(
        List<CoagContact> contacts) =>
    ContactsRepository(
      DummyPersistentStorage(
          Map.fromEntries(contacts.map((c) => MapEntry(c.coagContactId, c)))),
      DummyDistributedStorage(initialDht: {
        dummyDhtRecordKey(0): CoagContactDHTSchema(
          details: const ContactDetails(names: {'0': 'DHT 0'}),
          shareBackDHTKey: dummyDhtRecordKey(9).toString(),
          shareBackPubKey: dummyTypedKeyPair(9, 9).key.toString(),
        ),
        dummyDhtRecordKey(1): CoagContactDHTSchema(
          details: const ContactDetails(names: {'1': 'DHT 1'}),
          shareBackDHTKey: dummyDhtRecordKey(8).toString(),
          shareBackPubKey: dummyTypedKeyPair(8, 8).key.toString(),
        ),
        dummyDhtRecordKey(2): CoagContactDHTSchema(
          details: const ContactDetails(names: {'2': 'DHT 2'}),
          shareBackDHTKey: dummyDhtRecordKey(8).toString(),
          shareBackPubKey: dummyTypedKeyPair(8, 8).key.toString(),
        ),
      }),
      DummySystemContacts([]),
      appUserName,
      initialize: false,
      generateTypedKeyPair: () async => dummyTypedKeyPair(),
      generateSharedSecret: () async => dummyPsk(42),
    );

void main() {
  group('Test Cubit State Transitions', () {
    ContactsRepository? contactsRepository;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      contactsRepository = _contactsRepositoryFromContacts([
        CoagContact(
            coagContactId: '2',
            name: 'Existing Contact A',
            myIdentity: dummyTypedKeyPair(3, 2),
            myIntroductionKeyPair: dummyTypedKeyPair(3, 3),
            dhtSettings: DhtSettings(
                myKeyPair: dummyTypedKeyPair(2, 1),
                myNextKeyPair: dummyTypedKeyPair(2, 2))),
        CoagContact(
            coagContactId: '5',
            name: 'Existing Contact B',
            myIdentity: dummyTypedKeyPair(2, 3),
            myIntroductionKeyPair: dummyTypedKeyPair(2, 4),
            dhtSettings: DhtSettings(
                myKeyPair: dummyTypedKeyPair(5, 1),
                myNextKeyPair: dummyTypedKeyPair(5, 5))),
      ]);
      await contactsRepository!.initialize();
    });

    blocTest<ReceiveRequestCubit, ReceiveRequestState>(
      'emits no state changes when nothing is called',
      build: () => ReceiveRequestCubit(contactsRepository!),
      expect: () => const <ReceiveRequestState>[],
    );

    blocTest<ReceiveRequestCubit, ReceiveRequestState>(
      'scan qr code',
      build: () => ReceiveRequestCubit(contactsRepository!),
      act: (c) async => c.scanQrCode(),
      expect: () => const [ReceiveRequestState(ReceiveRequestStatus.qrcode)],
    );

    blocTest<ReceiveRequestCubit, ReceiveRequestState>(
      'emits qrcode state when non-coagulate code is scanned',
      build: () => ReceiveRequestCubit(contactsRepository!),
      act: (c) async => c.qrCodeCaptured(const mobile_scanner.BarcodeCapture(
          barcodes: [mobile_scanner.Barcode(rawValue: 'not.coag.social')])),
      expect: () => const [
        ReceiveRequestState(ReceiveRequestStatus.processing),
        ReceiveRequestState(ReceiveRequestStatus.qrcode),
      ],
    );

    blocTest<ReceiveRequestCubit, ReceiveRequestState>(
      'emits qrcode state when coagulate link is scanned but fragment missing',
      build: () => ReceiveRequestCubit(contactsRepository!),
      act: (c) async => c.qrCodeCaptured(const mobile_scanner.BarcodeCapture(
          barcodes: [
            mobile_scanner.Barcode(rawValue: 'https://coagulate.social/c/')
          ])),
      expect: () => const [
        ReceiveRequestState(ReceiveRequestStatus.processing),
        ReceiveRequestState(ReceiveRequestStatus.qrcode),
      ],
    );

    blocTest<ReceiveRequestCubit, ReceiveRequestState>(
      'emits scan qr code when handling own invite link',
      build: () => ReceiveRequestCubit(contactsRepository!),
      act: (c) async {
        final contact = await contactsRepository!
            .createContactForInvite('for invite', awaitDhtSharingAttempt: true);
        await c.qrCodeCaptured(mobile_scanner.BarcodeCapture(barcodes: [
          mobile_scanner.Barcode(
              rawValue: directSharingUrl(
                      'my own',
                      contact.dhtSettings.recordKeyMeSharing!,
                      contact.dhtSettings.initialSecret!)
                  .toString())
        ]));
      },
      expect: () => [
        const ReceiveRequestState(ReceiveRequestStatus.processing),
        const ReceiveRequestState(ReceiveRequestStatus.qrcode),
      ],
    );

    blocTest<ReceiveRequestCubit, ReceiveRequestState>(
        'successful direct sharing qt scanning, no dht info available yet',
        build: () => ReceiveRequestCubit(contactsRepository!),
        act: (c) async =>
            c.qrCodeCaptured(mobile_scanner.BarcodeCapture(barcodes: [
              mobile_scanner.Barcode(
                  rawValue: directSharingUrl(
                          'Direct Sharer', dummyDhtRecordKey(4), _dummyPsk(5))
                      .toString())
            ])),
        expect: () => [
              const ReceiveRequestState(ReceiveRequestStatus.processing),
              const TypeMatcher<ReceiveRequestState>()
                  .having((s) => s.status.isSuccess, 'isSuccess', isTrue),
            ],
        verify: (c) {
          // Check state
          expect(c.state.status, ReceiveRequestStatus.success);
          expect(c.state.profile!.name, 'Direct Sharer');
          expect(c.state.profile!.dhtSettings.initialSecret, _dummyPsk(5));
          expect(c.state.profile!.dhtSettings.recordKeyThemSharing,
              dummyDhtRecordKey(4));
          expect(c.state.profile!.dhtSettings.recordKeyMeSharing, null);

          // Check repo
          expect(
              c.contactsRepository
                  .getContact(c.state.profile!.coagContactId)
                  ?.name,
              'Direct Sharer');
          expect(
              c.contactsRepository
                  .getCirclesForContact(c.state.profile!.coagContactId),
              isEmpty);
        });

    blocTest<ReceiveRequestCubit, ReceiveRequestState>(
        'direct sharing qr code, dht available',
        build: () => ReceiveRequestCubit(contactsRepository!),
        act: (c) async =>
            c.qrCodeCaptured(mobile_scanner.BarcodeCapture(barcodes: [
              mobile_scanner.Barcode(
                  rawValue: directSharingUrl(
                          'Direct Sharer', dummyDhtRecordKey(0), _dummyPsk(0))
                      .toString())
            ])),
        expect: () => [
              const ReceiveRequestState(ReceiveRequestStatus.processing),
              const TypeMatcher<ReceiveRequestState>()
                  .having((s) => s.status.isSuccess, 'isSuccess', isTrue),
            ],
        verify: (c) {
          // Check state
          expect(c.state.status, ReceiveRequestStatus.success);
          expect(c.state.profile!.name, 'Direct Sharer');
          expect(c.state.profile!.dhtSettings.initialSecret, _dummyPsk(0));
          expect(c.state.profile!.dhtSettings.recordKeyThemSharing,
              dummyDhtRecordKey(0));
          // Still null, but populated from DHT in the repo below
          expect(c.state.profile!.dhtSettings.recordKeyMeSharing, isNull);

          // Check repo
          expect(
              c.contactsRepository
                  .getContact(c.state.profile!.coagContactId)
                  ?.name,
              'Direct Sharer');
          expect(
              c.contactsRepository
                  .getCirclesForContact(c.state.profile!.coagContactId),
              isEmpty);
          expect(
              c.contactsRepository
                  .getContact(c.state.profile!.coagContactId)
                  ?.dhtSettings
                  .recordKeyMeSharing,
              dummyDhtRecordKey(9));
        });

    // blocTest<ReceiveRequestCubit, ReceiveRequestState>(
    //     'successful profile qr scanning',
    //     build: () => ReceiveRequestCubit(contactsRepository!),
    //     act: (c) async =>
    //         c.qrCodeCaptured(mobile_scanner.BarcodeCapture(barcodes: [
    //           mobile_scanner.Barcode(
    //               rawValue:
    //                   profileUrl('Profile Sharer', _dummyTypedKeyPair(4, 4).key)
    //                       .toString())
    //         ])),
    //     expect: () => [
    //           const ReceiveRequestState(ReceiveRequestStatus.processing),
    //           const TypeMatcher<ReceiveRequestState>()
    //               .having((s) => s.status.isSuccess, 'isSuccess', isTrue),
    //         ],
    //     verify: (c) {
    //       // Check state
    //       expect(c.state.status, ReceiveRequestStatus.success);
    //       expect(c.state.profile!.name, 'Profile Sharer');
    //       expect(c.state.profile!.dhtSettings.theirPublicKey,
    //           _dummyTypedKeyPair(4, 4).key);
    //       expect(c.state.profile!.dhtSettings.initialSecret, isNull);
    //       expect(c.state.profile!.dhtSettings.recordKeyThemSharing, isNotNull);
    //       expect(c.state.profile!.dhtSettings.recordKeyMeSharing, isNotNull);

    //       // Check repo
    //       expect(
    //           c.contactsRepository
    //               .getContact(c.state.profile!.coagContactId)
    //               ?.name,
    //           'Profile Sharer');
    //       expect(
    //           c.contactsRepository
    //               .getCirclesForContact(c.state.profile!.coagContactId),
    //           contains(defaultEveryoneCircleId));
    //     });

    blocTest<ReceiveRequestCubit, ReceiveRequestState>(
        'successful profile based offer qr scanning',
        build: () => ReceiveRequestCubit(contactsRepository!),
        act: (c) async =>
            c.qrCodeCaptured(mobile_scanner.BarcodeCapture(barcodes: [
              mobile_scanner.Barcode(
                  rawValue: profileBasedOfferUrl('Offering Sharer',
                          dummyDhtRecordKey(4), dummyTypedKeyPair(4, 4).key)
                      .toString())
            ])),
        expect: () => [
              const ReceiveRequestState(ReceiveRequestStatus.processing),
              const TypeMatcher<ReceiveRequestState>()
                  .having((s) => s.status.isSuccess, 'isSuccess', isTrue),
            ],
        verify: (c) {
          // Check state
          expect(c.state.status, ReceiveRequestStatus.success);
          expect(c.state.profile!.name, 'Offering Sharer');
          expect(c.state.profile!.dhtSettings.theirPublicKey,
              dummyTypedKeyPair(4, 4).key);
          expect(c.state.profile!.dhtSettings.initialSecret, isNull);
          expect(c.state.profile!.dhtSettings.recordKeyThemSharing,
              dummyDhtRecordKey(4));
          expect(c.state.profile!.dhtSettings.recordKeyMeSharing, isNull);

          // Check repo
          expect(
              c.contactsRepository
                  .getContact(c.state.profile!.coagContactId)
                  ?.name,
              'Offering Sharer');
          expect(
              c.contactsRepository
                  .getCirclesForContact(c.state.profile!.coagContactId),
              isEmpty);
        });

    blocTest<ReceiveRequestCubit, ReceiveRequestState>(
      'batch invite qr scanning',
      build: () => ReceiveRequestCubit(contactsRepository!),
      act: (c) async =>
          c.qrCodeCaptured(mobile_scanner.BarcodeCapture(barcodes: [
        mobile_scanner.Barcode(
            rawValue: batchInviteUrl('Batch Label', dummyDhtRecordKey(4),
                    _dummyPsk(4), 4, dummyTypedKeyPair(4, 4).toKeyPair())
                .toString())
      ])),
      expect: () => [
        const ReceiveRequestState(ReceiveRequestStatus.processing),
        const TypeMatcher<ReceiveRequestState>().having(
            (s) => s.status.isHandleBatchInvite, 'isHandleBatchInvite', isTrue),
      ],
    );

    // blocTest<ReceiveRequestCubit, ReceiveRequestState>(
    //   'scan direct sharing qr code triggers matching state',
    //   build: () => ReceiveRequestCubit(contactsRepository!),
    //   act: (c) async =>
    //       c.qrCodeCaptured(const mobile_scanner.BarcodeCapture(barcodes: [
    //     mobile_scanner.Barcode(
    //         rawValue: 'https://coagulate.social/c/#VLD0:key:psk:wri:ter')
    //   ])),
    //   expect: () => const [
    //     ReceiveRequestState(ReceiveRequestStatus.processing),
    //     ReceiveRequestState(ReceiveRequestStatus.handleDirectSharing),
    //     ReceiveRequestState(ReceiveRequestStatus.success),
    //   ],
    // );
//     blocTest<ReceiveRequestCubit, ReceiveRequestState>(
//         'create coagulate contact for request, no system contact access',
//         setUp: () {
//           TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
//               .setMockMethodCallHandler(
//                   const MethodChannel('github.com/QuisApp/flutter_contacts'),
//                   (methodCall) async {
//             if (methodCall.method == 'requestPermission') {
//               return false;
//             }
//             return null;
//           });
//         },
//         build: () => ReceiveRequestCubit(ContactsRepository(
//             DummyPersistentStorage({}),
//             DummyDistributedStorage(initialDht: {
//               'sharingOfferKey': json.encode(CoagContactDHTSchemaV1(
//                       coagContactId: '',
//                       details: ContactDetails(
//                           displayName: 'From DHT',
//                           name: Name(first: 'From', last: 'DHT')))
//                   .toJson())
//             }),
//             DummySystemContacts([]))),
//         seed: () => const ReceiveRequestState(
//             ReceiveRequestStatus.receivedRequest,
//             requestSettings: ContactDHTSettings(
//                 key: 'sharingOfferKey', psk: 'psk', writer: 'writer')),
//         act: (c) async {
//           c.updateNewRequesterContact('New Contact Name');
//           await c.createNewContact();
//         },
//         verify: (c) {
//           expect(c.state.status, ReceiveRequestStatus.success);
//           expect(c.state.profile!.details!.names.values.first, 'From DHT');
//           expect(c.state.profile!.dhtSettingsForSharing, null,
//               reason:
//                   'They are not part of circles, no need for a DHT record.');
//           expect(
//               c.state.profile!.dhtSettingsForReceiving,
//               const ContactDHTSettings(
//                   key: 'sharingOfferKey', psk: 'psk', writer: 'writer'));
//         });

//     blocTest<ReceiveRequestCubit, ReceiveRequestState>(
//         'create coagulate contact from offer to share, no system contact access',
//         setUp: () {
//           TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
//               .setMockMethodCallHandler(
//                   const MethodChannel('github.com/QuisApp/flutter_contacts'),
//                   (methodCall) async {
//             if (methodCall.method == 'requestPermission') {
//               return false;
//             }
//             return null;
//           });
//         },
//         build: () => ReceiveRequestCubit(ContactsRepository(
//             DummyPersistentStorage({}),
//             DummyDistributedStorage(initialDht: {
//               'sharingOfferKey': json.encode(CoagContactDHTSchemaV1(
//                       coagContactId: '',
//                       details: ContactDetails(
//                           displayName: 'From DHT',
//                           name: Name(first: 'From', last: 'DHT')))
//                   .toJson())
//             }),
//             DummySystemContacts([]))),
//         seed: () => const ReceiveRequestState(
//             ReceiveRequestStatus.receivedShare,
//             requestSettings: ContactDHTSettings(
//                 key: 'sharingOfferKey', psk: 'psk', writer: 'writer')),
//         act: (c) async => c.createNewContact(),
//         verify: (c) {
//           expect(c.state.status, ReceiveRequestStatus.success);
//           expect(c.state.profile!.details!.names.values.first, 'From DHT');
//           expect(
//               c.state.profile!.dhtSettingsForReceiving,
//               const ContactDHTSettings(
//                   key: 'sharingOfferKey', psk: 'psk', writer: 'writer'));
//         });
  });
}
