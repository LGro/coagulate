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
    await _cRepoIntroducer.initialize();

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
    // Connect Introducer and UserA
    final contactA = await _cRepoIntroducer.createContactForInvite('A',
        pubKey: _cRepoA.getProfileInfo()!.mainKeyPair!.key,
        awaitDhtSharingAttempt: true);
    final offerLinkForA = profileBasedOfferUrl(
        'Introducer sharing with A',
        contactA.dhtSettings.recordKeyMeSharing!,
        contactA.dhtSettings.myKeyPair.key);
    await ReceiveRequestCubit(_cRepoA)
        .handleSharingOffer(offerLinkForA.fragment, awaitDhtOperations: true);

    // Connect Introducer and UserB
    final contactB = await _cRepoIntroducer.createContactForInvite('B',
        pubKey: _cRepoB.getProfileInfo()!.mainKeyPair!.key,
        awaitDhtSharingAttempt: true);
    final offerLinkForB = profileBasedOfferUrl(
        'Introducer sharing with B',
        contactB.dhtSettings.recordKeyMeSharing!,
        contactB.dhtSettings.myKeyPair.key);
    await ReceiveRequestCubit(_cRepoB)
        .handleSharingOffer(offerLinkForB.fragment, awaitDhtOperations: true);

    // Introducer introduces UserA and UserB
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

    // Check that Contact A has gotten the invitation to connect with B
    await _cRepoA.updateContactFromDHT(_cRepoA.getContacts().values.first);
    expect(_cRepoA.getContacts().length, 1);
    expect(
        _cRepoA.getContacts().values.first.name, 'Introducer sharing with A');
    expect(
        _cRepoA.getContacts().values.first.introductionsByThem.first.otherName,
        'Intro Alias B');

    // Check that Contact B has gotten the invitation to connect with A
    await _cRepoB.updateContactFromDHT(_cRepoB.getContacts().values.first);
    expect(_cRepoB.getContacts().length, 1);
    expect(
        _cRepoB.getContacts().values.first.name, 'Introducer sharing with B');
    expect(
        _cRepoB.getContacts().values.first.introductionsByThem.first.otherName,
        'Intro Alias A');
  });
}
