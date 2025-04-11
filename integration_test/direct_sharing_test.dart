// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:coagulate/data/repositories/contacts.dart';
import 'package:coagulate/ui/receive_request/cubit.dart';
import 'package:coagulate/ui/utils.dart';
import 'package:coagulate/veilid_init.dart';
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
    await _cRepoA.initialize();
    _cRepoB = ContactsRepository(DummyPersistentStorage({}), _distStorage,
        DummySystemContacts([]), 'UserB',
        initialize: false);
    await _cRepoB.initialize();
  });

  test('Alice directly shares with Bob who shares back', () async {
    // Alice prepares invite for Bob
    var contactBobInvitedByA = await _cRepoA.createContactForInvite(
        'Bob Invite',
        pubKey: null,
        awaitDhtSharingAttempt: true);
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
    expect(showSharingInitializing(contactBobInvitedByA), false);
    expect(showSharingOffer(contactBobInvitedByA), false);
    expect(showDirectSharing(contactBobInvitedByA), true);
    final directSharingLinkFromAliceForBob = directSharingUrl(
        'Alice Sharing',
        contactBobInvitedByA.dhtSettings.recordKeyMeSharing!,
        contactBobInvitedByA.dhtSettings.initialSecret!);

    // Bob accepts invite from Alice
    await ReceiveRequestCubit(_cRepoB).handleDirectSharing(
        directSharingLinkFromAliceForBob.fragment,
        awaitDhtOperations: true);
    var contactAliceFromBobsRepo = _cRepoB.getContacts().values.first;
    expect(
      contactAliceFromBobsRepo.name,
      'Alice Sharing',
      reason: 'Name from invite URL',
    );
    expect(
      contactAliceFromBobsRepo.details?.names.values.first,
      'UserA',
      reason: 'Name from sharing profile',
    );
    expect(showSharingInitializing(contactAliceFromBobsRepo), false);
    expect(showSharingOffer(contactAliceFromBobsRepo), false);
    expect(showDirectSharing(contactAliceFromBobsRepo), false);

    // Alice checks for Bob sharing back
    await _cRepoA.updateContactFromDHT(contactBobInvitedByA);
    contactBobInvitedByA =
        _cRepoA.getContact(contactBobInvitedByA.coagContactId)!;
    expect(
      contactBobInvitedByA.details?.names.values.first,
      'UserB',
      reason: 'Name from sharing profile',
    );
    expect(
      contactBobInvitedByA.dhtSettings.theyAckHandshakeComplete,
      true,
      reason: 'Bob indicated handshake complete',
    );
    await _cRepoA.tryShareWithContactDHT(contactBobInvitedByA.coagContactId);

    // Bob checks for completed handshake after updating receive and share
    await _cRepoB.updateContactFromDHT(contactAliceFromBobsRepo);
    contactAliceFromBobsRepo = _cRepoB.getContacts().values.first;
    expect(
      contactAliceFromBobsRepo.dhtSettings.theyAckHandshakeComplete,
      true,
      reason: 'Handshake accepted as complete by Alice',
    );
  });
}
