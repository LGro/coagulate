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

  test("Alice shares from Bob's profile link, who shares back", () async {
    // Alice prepares invite for Bob using Bob's profile public key
    final rrCubitA = ReceiveRequestCubit(_cRepoA);
    await rrCubitA.handleProfileLink(
        profileUrl('Bob Profile', _cRepoB.getProfileInfo()!.mainKeyPair!.key)
            .fragment,
        awaitDhtOperations: true);
    var contactBobFromProfile = _cRepoA.getContacts().values.first;
    expect(
      contactBobFromProfile.dhtSettings.theirPublicKey,
      _cRepoB.getProfileInfo()!.mainKeyPair!.key,
      reason: 'Used given profile public key',
    );
    expect(
      contactBobFromProfile.dhtSettings.recordKeyMeSharing,
      isNotNull,
      reason: 'Sharing record prepared',
    );
    expect(
      contactBobFromProfile.dhtSettings.recordKeyThemSharing,
      isNotNull,
      reason: 'Receiving record prepared',
    );
    final directSharingLinkFromAliceForBob = profileBasedOfferUrl(
        'Alice Sharing',
        contactBobFromProfile.dhtSettings.recordKeyMeSharing!,
        contactBobFromProfile.dhtSettings.myKeyPair.key);

    // Bob accepts profile based offer from Alice
    await ReceiveRequestCubit(_cRepoB).handleSharingOffer(
        directSharingLinkFromAliceForBob.fragment,
        awaitDhtOperations: true);
    final contactAliceFromBobsRepo = _cRepoB.getContacts().values.first;
    expect(
      contactAliceFromBobsRepo.dhtSettings.myKeyPair,
      _cRepoB.getProfileInfo()!.mainKeyPair,
      reason: 'Used correct profile key pair',
    );
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
    expect(
      contactAliceFromBobsRepo.dhtSettings.theyAckHandshakeComplete,
      true,
      reason: 'Handshake accepted as complete by Alice',
    );

    // Alice checks for Bob sharing back
    contactBobFromProfile =
        _cRepoA.getContact(contactBobFromProfile.coagContactId)!;
    await _cRepoA.updateContactFromDHT(contactBobFromProfile);
    contactBobFromProfile =
        _cRepoA.getContact(contactBobFromProfile.coagContactId)!;
    expect(
      contactBobFromProfile.details?.names.values.first,
      'UserB',
      reason: 'Name from sharing profile',
    );
    expect(
      contactBobFromProfile.dhtSettings.theyAckHandshakeComplete,
      true,
      reason: 'Bob indicated handshake complete',
    );
    await _cRepoA.tryShareWithContactDHT(contactBobFromProfile.coagContactId);
  });
}
