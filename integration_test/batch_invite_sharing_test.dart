// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:coagulate/data/repositories/contacts.dart';
import 'package:coagulate/ui/batch_invite_management/cubit.dart';
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
    await _cRepoA.initialize(listenToVeilidNetworkChanges: false);
    _cRepoB = ContactsRepository(DummyPersistentStorage({}), _distStorage,
        DummySystemContacts([]), 'UserB',
        initialize: false);
    await _cRepoB.initialize(listenToVeilidNetworkChanges: false);
  });

  test('Peter creates a batch, Alice and Bob join to share', () async {
    // Peter creates a batch
    final biCubitP = BatchInvitesCubit();
    await biCubitP.generateInvites(
        'Party Batch', 2, DateTime.now().add(const Duration(hours: 1)));
    final inviteLinks =
        generateBatchInviteLinks(biCubitP.state.batches.values.first);
    final batchInviteUrlAlice = Uri.parse(inviteLinks.first);
    final batchInviteUrlBob = Uri.parse(inviteLinks.last);

    // Alice prepares invite for Bob using Bob's profile public key
    final rrCubitA = ReceiveRequestCubit(_cRepoA,
        initialState: ReceiveRequestState(
            ReceiveRequestStatus.handleBatchInvite,
            fragment: batchInviteUrlAlice.fragment));
    final batchNameIdA = _cRepoA.getProfileInfo()!.details.names.keys.first;
    await rrCubitA.handleBatchInvite(myNameId: batchNameIdA);
    expect(
      _cRepoA.getContacts().values,
      isEmpty,
      reason: 'Nobody else shared with the batch yet',
    );

    // Bob accepts batch based offer from Alice
    final rrCubitB = ReceiveRequestCubit(_cRepoB,
        initialState: ReceiveRequestState(
            ReceiveRequestStatus.handleBatchInvite,
            fragment: batchInviteUrlBob.fragment));
    final batchNameIdB = _cRepoB.getProfileInfo()!.details.names.keys.first;
    await rrCubitB.handleBatchInvite(myNameId: batchNameIdB);
    var contactAliceFromBobsRepo = _cRepoB.getContacts().values.first;
    expect(
      contactAliceFromBobsRepo.name,
      'UserA',
      reason: 'Got name from batch',
    );
    expect(
      contactAliceFromBobsRepo.details,
      isNull,
      reason: 'No details available yet, since Alice has not seen Bob yet',
    );
    expect(
        contactAliceFromBobsRepo.sharedProfile?.details.names.keys.firstOrNull,
        batchNameIdB);

    // Alice finds bob in the batch and starts sharing
    expect(_cRepoA.getBatchInvites().length, 1,
        reason: 'Alice received only one batch invite');
    await _cRepoA.batchInviteUpdate(_cRepoA.getBatchInvites().values.first);
    var contactBobFromAlicesRepo = _cRepoA.getContacts().values.first;
    expect(
      contactBobFromAlicesRepo.name,
      'UserB',
      reason: 'Got name from batch',
    );
    expect(
      contactBobFromAlicesRepo.dhtSettings.recordKeyMeSharing,
      isNotNull,
      reason: 'Alice started sharing',
    );
    expect(
      contactBobFromAlicesRepo.dhtSettings.theirPublicKey,
      isNotNull,
      reason: 'Alice knows public key of Bob',
    );
    expect(
        contactBobFromAlicesRepo.sharedProfile?.details.names.keys.firstOrNull,
        batchNameIdA);

    // Bob learns about Alice and starts sharing back
    expect(_cRepoB.getBatchInvites().length, 1,
        reason: 'Bob received only one batch invite');
    await _cRepoB.batchInviteUpdate(_cRepoB.getBatchInvites().values.first);
    contactAliceFromBobsRepo = _cRepoB.getContacts().values.first;
    expect(
      contactAliceFromBobsRepo.details?.names.values.firstOrNull,
      'UserA',
      reason: 'Details available',
    );

    // Alice sees stuff from Bob
    await _cRepoA.updateContactFromDHT(contactBobFromAlicesRepo);
    contactBobFromAlicesRepo =
        _cRepoA.getContact(contactBobFromAlicesRepo.coagContactId)!;
    expect(
      contactBobFromAlicesRepo.details?.names.values.firstOrNull,
      'UserB',
      reason: 'Details available',
    );
  });
}
