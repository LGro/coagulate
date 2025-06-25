// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:coagulate/data/models/contact_location.dart';
import 'package:coagulate/data/repositories/contacts.dart';
import 'package:coagulate/ui/receive_request/cubit.dart';
import 'package:coagulate/ui/utils.dart';
import 'package:coagulate/veilid_init.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/mocked_providers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late ContactsRepository _cRepoA;
  late ContactsRepository _cRepoB;
  late DummyDistributedStorage _distStorage;

  setUp(() async {
    await CoagulateGlobalInit.initialize();
    _distStorage = DummyDistributedStorage(transparent: true);
    _cRepoA = ContactsRepository(DummyPersistentStorage({}), _distStorage,
        DummySystemContacts([]), 'UserA',
        initialize: false);
    await _cRepoA.initialize(listenToVeilidNetworkChanges: false);
    _cRepoB = ContactsRepository(DummyPersistentStorage({}), _distStorage,
        DummySystemContacts([]), 'UserB',
        initialize: false);
    await _cRepoB.initialize(listenToVeilidNetworkChanges: false);
  });

  test('Alice directly shares with Bob who shares back', () async {
    // Alice prepares invite for Bob and shares via default circle
    debugPrint('ALICE ACTING');
    var contactBobInvitedByA = await _cRepoA.createContactForInvite(
        'Bob Invite',
        pubKey: null,
        awaitDhtSharingAttempt: true);
    await _cRepoA.updateCirclesForContact(
        contactBobInvitedByA.coagContactId, [defaultInitialCircleId],
        triggerDhtUpdate: false);
    await _cRepoA.tryShareWithContactDHT(contactBobInvitedByA.coagContactId);
    expect(
      contactBobInvitedByA.dhtSettings.recordKeyMeSharing,
      isNotNull,
      reason: 'Sharing record prepared',
    );
    expect(
      contactBobInvitedByA.dhtSettings.recordKeyThemSharing,
      isNotNull,
      reason: 'Receiving record prepared',
    );
    expect(
      contactBobInvitedByA.dhtSettings.initialSecret,
      isNotNull,
      reason: 'Initial secret for symmetric encryption ready',
    );
    expect(
      contactBobInvitedByA.dhtSettings.theirPublicKey,
      isNull,
      reason: 'We have not seen any public keys from them yet',
    );
    expect(
      contactBobInvitedByA.dhtSettings.theirNextPublicKey,
      isNull,
      reason: 'We have not seen any public keys from them yet',
    );
    // TODO: Can those be used as matchers?
    expect(showSharingInitializing(contactBobInvitedByA), false);
    expect(showSharingOffer(contactBobInvitedByA), false);
    expect(showDirectSharing(contactBobInvitedByA), true);
    final directSharingLinkFromAliceForBob = directSharingUrl(
        'Alice Sharing',
        contactBobInvitedByA.dhtSettings.recordKeyMeSharing!,
        contactBobInvitedByA.dhtSettings.initialSecret!);

    // Bob accepts invite from Alice and shares via default circle
    debugPrint('---');
    debugPrint('BOB ACTING');
    await ReceiveRequestCubit(_cRepoB).handleDirectSharing(
        directSharingLinkFromAliceForBob.fragment,
        awaitDhtOperations: true);
    var contactAliceFromBobsRepo = _cRepoB.getContacts().values.first;
    await _cRepoB.updateCirclesForContact(
        contactAliceFromBobsRepo.coagContactId, [defaultInitialCircleId],
        triggerDhtUpdate: false);
    await _cRepoB
        .tryShareWithContactDHT(contactAliceFromBobsRepo.coagContactId);
    expect(
      contactAliceFromBobsRepo.name,
      'Alice Sharing',
      reason: 'Name from invite URL',
    );
    expect(
      contactAliceFromBobsRepo.details?.names.values.firstOrNull,
      'UserA',
      reason: 'Name from sharing profile',
    );
    expect(
      contactAliceFromBobsRepo.dhtSettings.initialSecret,
      isNotNull,
      reason: 'Initial secret still in place because no full pub key cycle yet',
    );
    expect(
      contactAliceFromBobsRepo.dhtSettings.theirNextPublicKey,
      isNotNull,
      reason: 'Public key is expected to be available after first read',
    );
    expect(showSharingInitializing(contactAliceFromBobsRepo), false);
    expect(showSharingOffer(contactAliceFromBobsRepo), false);
    expect(showDirectSharing(contactAliceFromBobsRepo), false);

    // Alice checks for Bob sharing back
    debugPrint('---');
    debugPrint('ALICE ACTING');
    await _cRepoA.updateContactFromDHT(contactBobInvitedByA);
    contactBobInvitedByA =
        _cRepoA.getContact(contactBobInvitedByA.coagContactId)!;
    expect(
      contactBobInvitedByA.details?.names.values.firstOrNull,
      'UserB',
      reason: 'Name from sharing profile',
    );
    expect(
      contactBobInvitedByA.dhtSettings.theyAckHandshakeComplete,
      true,
      reason: 'Bob indicated handshake complete',
    );
    expect(
      contactBobInvitedByA.dhtSettings.initialSecret,
      isNull,
      reason: 'Initial secret discarded due to switch to public key crypto',
    );
    await _cRepoA.tryShareWithContactDHT(contactBobInvitedByA.coagContactId);

    // Bob checks for completed handshake after updating receive and share
    debugPrint('---');
    debugPrint('BOB ACTING');
    await _cRepoB.updateContactFromDHT(contactAliceFromBobsRepo);
    contactAliceFromBobsRepo = _cRepoB.getContacts().values.first;
    expect(
      contactAliceFromBobsRepo.dhtSettings.theyAckHandshakeComplete,
      true,
      reason: 'Handshake accepted as complete by Alice',
    );
    expect(contactAliceFromBobsRepo.dhtSettings.initialSecret, isNull,
        reason:
            'Initial secret removed after pub keys exchanged and handshake');

    //// TRANSITION FROM SYMMETRIC TO ASYMMETRIC CRYPTO COMPLETED ////
    ////           TESTING ASYMMETRIC KEY ROTATION NOW            ////

    // Bob shares update, testing key rotation
    debugPrint('---');
    debugPrint('BOB ACTING');
    final profileB = _cRepoB.getProfileInfo()!;
    await _cRepoB.setProfileInfo(
        profileB.copyWith(
            addressLocations: {
              'a0': const ContactAddressLocation(latitude: 0, longitude: 0)
            },
            sharingSettings: profileB.sharingSettings.copyWith(addresses: {
              'a0': [defaultInitialCircleId]
            })),
        triggerDhtUpdate: false);
    await _cRepoB
        .tryShareWithContactDHT(contactAliceFromBobsRepo.coagContactId);

    // Alice receives new location
    debugPrint('---');
    debugPrint('ALICE ACTING');
    await _cRepoA.updateContactFromDHT(
        _cRepoA.getContact(contactBobInvitedByA.coagContactId)!);
    final contactBobFromAlicesRepo = _cRepoA.getContacts().values.first;
    expect(
      contactBobFromAlicesRepo.dhtSettings.theirPublicKey,
      isNotNull,
      reason: 'Public key is marked as working',
    );
    expect(
      contactBobFromAlicesRepo.dhtSettings.theirNextPublicKey,
      isNotNull,
      reason: 'Follow up public key has been transmitted',
    );
    expect(
      contactBobFromAlicesRepo.dhtSettings.theirPublicKey,
      isNot(equals(contactBobFromAlicesRepo.dhtSettings.theirNextPublicKey)),
      reason: 'Follow up key differs',
    );
    expect(
      contactBobFromAlicesRepo.dhtSettings.theirNextPublicKey,
      contactAliceFromBobsRepo.dhtSettings.myNextKeyPair?.key,
      reason: 'Next key matches source next key pair public key',
    );
  });
}
