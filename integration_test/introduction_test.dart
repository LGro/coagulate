// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

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

  late ContactsRepository _cRepoIntroducer;
  late ContactsRepository _cRepoA;
  late ContactsRepository _cRepoB;
  late DummyDistributedStorage _distStorage;

  setUp(() async {
    await CoagulateGlobalInit.initialize();
    _distStorage = DummyDistributedStorage(transparent: true);

    _cRepoIntroducer = ContactsRepository(DummyPersistentStorage({}),
        _distStorage, DummySystemContacts([]), 'Introducer',
        initialize: false);
    await _cRepoIntroducer.initialize(listenToVeilidNetworkChanges: false);

    _cRepoA = ContactsRepository(DummyPersistentStorage({}), _distStorage,
        DummySystemContacts([]), 'UserA',
        initialize: false);
    await _cRepoA.initialize(listenToVeilidNetworkChanges: false);

    _cRepoB = ContactsRepository(DummyPersistentStorage({}), _distStorage,
        DummySystemContacts([]), 'UserB',
        initialize: false);
    await _cRepoB.initialize(listenToVeilidNetworkChanges: false);
  });

  test('Introducer connects with Alice and Bob,introduces them, they connect',
      () async {
    // Connect Introducer and UserA
    debugPrint('INTRODUCER + ALICE');
    final contactA = await _cRepoIntroducer.createContactForInvite('A',
        pubKey: _cRepoA.getProfileInfo()!.mainKeyPair!.key,
        awaitDhtSharingAttempt: true);
    final offerLinkForA = profileBasedOfferUrl(
        'Introducer sharing with A',
        contactA.dhtSettings.recordKeyMeSharing!,
        contactA.dhtSettings.myKeyPair!.key);
    await ReceiveRequestCubit(_cRepoA)
        .handleSharingOffer(offerLinkForA.fragment, awaitDhtOperations: true);

    // Connect Introducer and UserB
    debugPrint('---');
    debugPrint('INTRODUCER + BOB');
    final contactB = await _cRepoIntroducer.createContactForInvite('B',
        pubKey: _cRepoB.getProfileInfo()!.mainKeyPair!.key,
        awaitDhtSharingAttempt: true);
    final offerLinkForB = profileBasedOfferUrl(
        'Introducer sharing with B',
        contactB.dhtSettings.recordKeyMeSharing!,
        contactB.dhtSettings.myKeyPair!.key);
    await ReceiveRequestCubit(_cRepoB)
        .handleSharingOffer(offerLinkForB.fragment, awaitDhtOperations: true);

    // Introducer introduces UserA and UserB
    debugPrint('---');
    debugPrint('INTRODUCER ACTING');
    await _cRepoIntroducer.updateContactFromDHT(contactA);
    await _cRepoIntroducer.updateContactFromDHT(contactB);
    final introSucceeded = await _cRepoIntroducer.introduce(
        contactIdA: contactA.coagContactId,
        nameA: 'Intro Alias A',
        contactIdB: contactB.coagContactId,
        nameB: 'Intro Alias B',
        message: 'Intro Message',
        awaitDhtOperations: true);
    expect(introSucceeded, true);

    // Check that Contact A has gotten the invitation to connect with B, accept
    debugPrint('---');
    debugPrint('ALICE ACTING');
    await _cRepoA.updateContactFromDHT(_cRepoA.getContacts().values.first);
    expect(_cRepoA.getContacts().length, 1);
    final introducerA = _cRepoA.getContacts().values.first;
    expect(introducerA.name, 'Introducer sharing with A');
    expect(introducerA.introductionsByThem.firstOrNull?.otherName,
        'Intro Alias B');
    // Accept and share
    final contactIdB = await _cRepoA.acceptIntroduction(
        introducerA, introducerA.introductionsByThem.first,
        awaitUpdateFromDht: true);
    expect(contactIdB, isNotNull,
        reason: 'Expected accepting of introduction to succeed');
    await _cRepoA.updateCirclesForContact(contactIdB!, [defaultInitialCircleId],
        triggerDhtUpdate: false);
    final sharingSuccessA = await _cRepoA.tryShareWithContactDHT(contactIdB);
    expect(sharingSuccessA, true, reason: 'Expected sharing to succeed');

    // Check that Contact B has gotten the invitation to connect with A
    debugPrint('---');
    debugPrint('BOB ACTING');
    await _cRepoB.updateContactFromDHT(_cRepoB.getContacts().values.first);
    expect(_cRepoB.getContacts().length, 1);
    final introducerB = _cRepoB.getContacts().values.first;
    expect(introducerB.name, 'Introducer sharing with B');
    expect(introducerB.introductionsByThem.firstOrNull?.otherName,
        'Intro Alias A');
    // Accept and share back
    final contactIdA = await _cRepoB.acceptIntroduction(
        introducerB, introducerB.introductionsByThem.first,
        awaitUpdateFromDht: true);
    expect(contactIdA, isNotNull,
        reason: 'Expected accepting of introduction to succeed');
    await _cRepoB.updateCirclesForContact(contactIdA!, [defaultInitialCircleId],
        triggerDhtUpdate: false);
    final sharingSuccessB = await _cRepoB.tryShareWithContactDHT(contactIdA);
    expect(sharingSuccessB, true, reason: 'Expected sharing with A to work');
    expect(_cRepoB.getContact(contactIdA)!.details?.names.values.firstOrNull,
        'UserA');

    // Check that sharing succeeded from perspective of A
    debugPrint('---');
    debugPrint('ALICE ACTING');
    final updateSuccessA =
        await _cRepoA.updateContactFromDHT(_cRepoA.getContact(contactIdB)!);
    expect(updateSuccessA, true, reason: 'Expected updating contact B to work');
    expect(_cRepoA.getContact(contactIdB)!.details?.names.values.firstOrNull,
        'UserB');

    // First key rotation
    debugPrint('---');
    debugPrint('BOB ACTING');
    final updateSuccessB =
        await _cRepoB.updateContactFromDHT(_cRepoB.getContact(contactIdA)!);
    expect(updateSuccessB, true, reason: 'Expected updating contact A to work');
    // TODO: Test something that actually matters here
  });
}
