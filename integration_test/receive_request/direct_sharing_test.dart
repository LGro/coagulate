// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:bloc_test/bloc_test.dart';
import 'package:coagulate/data/models/coag_contact.dart';
import 'package:coagulate/data/repositories/contacts.dart';
import 'package:coagulate/ui/receive_request/cubit.dart';
import 'package:coagulate/ui/utils.dart';
import 'package:coagulate/veilid_init.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as mobile_scanner;
import 'package:veilid_support/veilid_support.dart';

import '../../test/mocked_providers.dart';

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
            dhtSettings:
                DhtSettings(myKeyPair: await generateTypedKeyPairBest())),
        CoagContact(
            coagContactId: '5',
            name: 'Existing Contact B',
            dhtSettings:
                DhtSettings(myKeyPair: await generateTypedKeyPairBest())),
      ];
      initialDht = {
        dummyDhtRecordKey(0): CoagContactDHTSchema(
          details: const ContactDetails(names: {'0': 'DHT 0'}),
          shareBackDHTKey: dummyDhtRecordKey(9).toString(),
          shareBackPubKey:
              await generateTypedKeyPairBest().then((kp) => kp.key.toString()),
        ),
        dummyDhtRecordKey(1): CoagContactDHTSchema(
          details: const ContactDetails(names: {'1': 'DHT 1'}),
          shareBackDHTKey: dummyDhtRecordKey(8).toString(),
          shareBackPubKey:
              await generateTypedKeyPairBest().then((kp) => kp.key.toString()),
        ),
        dummyDhtRecordKey(2): CoagContactDHTSchema(
          details: const ContactDetails(names: {'2': 'DHT 2'}),
          shareBackDHTKey: dummyDhtRecordKey(8).toString(),
          shareBackPubKey:
              await generateTypedKeyPairBest().then((kp) => kp.key.toString()),
        ),
      };
      contactsRepository = await contactsRepositoryFromContacts(
          contacts: [...initialContacts], initialDht: {...initialDht});
    });

    blocTest<ReceiveRequestCubit, ReceiveRequestState>(
        'successful direct sharing qt scanning, no dht info available yet',
        build: () => ReceiveRequestCubit(contactsRepository!),
        act: (c) async =>
            c.qrCodeCaptured(mobile_scanner.BarcodeCapture(barcodes: [
              mobile_scanner.Barcode(
                  rawValue: directSharingUrl(
                          'Direct Sharer', dummyDhtRecordKey(4), dummyPsk(5))
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
          expect(c.state.profile!.dhtSettings.initialSecret, dummyPsk(5));
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
              contains(defaultEveryoneCircleId));
        });

    blocTest<ReceiveRequestCubit, ReceiveRequestState>(
        'direct sharing qr code, dht available',
        build: () => ReceiveRequestCubit(contactsRepository!),
        act: (c) async =>
            c.qrCodeCaptured(mobile_scanner.BarcodeCapture(barcodes: [
              mobile_scanner.Barcode(
                  rawValue: directSharingUrl(
                          'Direct Sharer', dummyDhtRecordKey(0), dummyPsk(0))
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
          expect(c.state.profile!.dhtSettings.initialSecret, dummyPsk(0));
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
              contains(defaultEveryoneCircleId));
          expect(
              c.contactsRepository
                  .getContact(c.state.profile!.coagContactId)
                  ?.dhtSettings
                  .recordKeyMeSharing,
              dummyDhtRecordKey(9));
        });
  });
}
