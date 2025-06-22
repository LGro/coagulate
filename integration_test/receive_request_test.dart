// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:coagulate/data/models/coag_contact.dart';
import 'package:coagulate/data/repositories/contacts.dart';
import 'package:coagulate/data/utils.dart';
import 'package:coagulate/ui/receive_request/cubit.dart';
import 'package:coagulate/ui/utils.dart';
import 'package:coagulate/veilid_init.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as mobile_scanner;
import 'package:veilid_support/veilid_support.dart';

import '../test/mocked_providers.dart';

const appUserName = 'App User Name';

Typed<FixedEncodedString43> _dummyDhtRecordKey(int i) =>
    Typed<FixedEncodedString43>(
        kind: cryptoKindVLD0,
        value: FixedEncodedString43.fromBytes(
            Uint8List.fromList(List.filled(32, i))));

FixedEncodedString43 _dummyPsk(int i) =>
    FixedEncodedString43.fromBytes(Uint8List.fromList(List.filled(32, i)));

Future<ContactsRepository> _contactsRepositoryFromContacts(
        {required List<CoagContact> contacts,
        required Map<Typed<FixedEncodedString43>, CoagContactDHTSchema>
            initialDht}) async =>
    ContactsRepository(
        DummyPersistentStorage(
            Map.fromEntries(contacts.map((c) => MapEntry(c.coagContactId, c)))),
        DummyDistributedStorage(initialDht: initialDht),
        DummySystemContacts([]),
        appUserName,
        initialize: false);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Test Cubit State Transitions', () {
    ContactsRepository? contactsRepository;
    var initialContacts = <CoagContact>[];
    var initialDht = <Typed<FixedEncodedString43>, CoagContactDHTSchema>{};

    setUp(() async {
      await CoagulateGlobalInit.initialize();
      initialContacts = [
        CoagContact(
            coagContactId: '2',
            name: 'Existing Contact A',
            myIdentity: await generateTypedKeyPairBest(),
            dhtSettings:
                DhtSettings(myNextKeyPair: await generateTypedKeyPairBest())),
        CoagContact(
            coagContactId: '5',
            name: 'Existing Contact B',
            myIdentity: await generateTypedKeyPairBest(),
            dhtSettings:
                DhtSettings(myNextKeyPair: await generateTypedKeyPairBest())),
      ];
      initialDht = {
        _dummyDhtRecordKey(0): CoagContactDHTSchema(
          details: const ContactDetails(names: {'0': 'DHT 0'}),
          shareBackDHTKey: _dummyDhtRecordKey(9).toString(),
          shareBackPubKey:
              await generateTypedKeyPairBest().then((kp) => kp.key.toString()),
        ),
        _dummyDhtRecordKey(1): CoagContactDHTSchema(
          details: const ContactDetails(names: {'1': 'DHT 1'}),
          shareBackDHTKey: _dummyDhtRecordKey(8).toString(),
          shareBackPubKey:
              await generateTypedKeyPairBest().then((kp) => kp.key.toString()),
        ),
        _dummyDhtRecordKey(2): CoagContactDHTSchema(
          details: const ContactDetails(names: {'2': 'DHT 2'}),
          shareBackDHTKey: _dummyDhtRecordKey(8).toString(),
          shareBackPubKey:
              await generateTypedKeyPairBest().then((kp) => kp.key.toString()),
        ),
      };
      contactsRepository = await _contactsRepositoryFromContacts(
          contacts: [...initialContacts], initialDht: {...initialDht});
      await contactsRepository!.initialize();
    });

    blocTest<ReceiveRequestCubit, ReceiveRequestState>(
        'successful direct sharing qt scanning, no dht info available yet',
        build: () => ReceiveRequestCubit(contactsRepository!),
        act: (c) async => c.qrCodeCaptured(
            mobile_scanner.BarcodeCapture(barcodes: [
              mobile_scanner.Barcode(
                  rawValue: directSharingUrl(
                          'Direct Sharer', _dummyDhtRecordKey(4), _dummyPsk(5))
                      .toString())
            ]),
            awaitDhtOperations: true),
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
              _dummyDhtRecordKey(4));
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
        act: (c) async => c.qrCodeCaptured(
            mobile_scanner.BarcodeCapture(barcodes: [
              mobile_scanner.Barcode(
                  rawValue: directSharingUrl(
                          'Direct Sharer', _dummyDhtRecordKey(0), _dummyPsk(0))
                      .toString())
            ]),
            awaitDhtOperations: true),
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
              _dummyDhtRecordKey(0));
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
              _dummyDhtRecordKey(9));
        });

    blocTest<ReceiveRequestCubit, ReceiveRequestState>(
        'successful profile qr scanning',
        build: () => ReceiveRequestCubit(contactsRepository!),
        act: (c) async => c.qrCodeCaptured(
            mobile_scanner.BarcodeCapture(barcodes: [
              mobile_scanner.Barcode(
                  rawValue: profileUrl('Profile Sharer',
                          initialContacts[0].dhtSettings.myKeyPair.key)
                      .toString())
            ]),
            awaitDhtOperations: true),
        expect: () => [
              const ReceiveRequestState(ReceiveRequestStatus.processing),
              const TypeMatcher<ReceiveRequestState>()
                  .having((s) => s.status.isSuccess, 'isSuccess', isTrue),
            ],
        verify: (c) {
          // Check state
          expect(c.state.status, ReceiveRequestStatus.success);
          expect(c.state.profile!.name, 'Profile Sharer');
          expect(c.state.profile!.dhtSettings.theirPublicKey,
              initialContacts[0].dhtSettings.myKeyPair?.key);
          expect(c.state.profile!.dhtSettings.initialSecret, isNull);
          expect(c.state.profile!.dhtSettings.recordKeyThemSharing, isNotNull);
          expect(c.state.profile!.dhtSettings.recordKeyMeSharing, isNotNull);

          // Check repo
          expect(
              c.contactsRepository
                  .getContact(c.state.profile!.coagContactId)
                  ?.name,
              'Profile Sharer');
          expect(
              c.contactsRepository
                  .getCirclesForContact(c.state.profile!.coagContactId),
              isEmpty);
        });

    blocTest<ReceiveRequestCubit, ReceiveRequestState>(
        'successful profile based offer qr scanning',
        build: () => ReceiveRequestCubit(contactsRepository!),
        act: (c) async => c.qrCodeCaptured(
            mobile_scanner.BarcodeCapture(barcodes: [
              mobile_scanner.Barcode(
                  rawValue: profileBasedOfferUrl(
                          'Offering Sharer',
                          _dummyDhtRecordKey(4),
                          initialContacts[0].dhtSettings.myKeyPair!.key)
                      .toString())
            ]),
            awaitDhtOperations: true),
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
              initialContacts[0].dhtSettings.myKeyPair.key);
          expect(c.state.profile!.dhtSettings.initialSecret, isNull);
          expect(c.state.profile!.dhtSettings.recordKeyThemSharing,
              _dummyDhtRecordKey(4));
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

    // blocTest<ReceiveRequestCubit, ReceiveRequestState>(
    //   'batch invite qr scanning',
    //   build: () => ReceiveRequestCubit(contactsRepository!),
    //   act: (c) async =>
    //       c.qrCodeCaptured(mobile_scanner.BarcodeCapture(barcodes: [
    //     mobile_scanner.Barcode(
    //         rawValue: batchInviteUrl('Batch Label', _dummyDhtRecordKey(4),
    //                 _dummyPsk(4), 4, _dummyTypedKeyPair(4, 4).toKeyPair())
    //             .toString())
    //   ])),
    //   expect: () => [
    //     const ReceiveRequestState(ReceiveRequestStatus.processing),
    //     const TypeMatcher<ReceiveRequestState>().having(
    //         (s) => s.status.isHandleBatchInvite, 'isHandleBatchInvite', isTrue),
    //   ],
    // );
  });
}
