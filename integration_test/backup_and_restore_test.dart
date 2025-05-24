// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:coagulate/data/models/coag_contact.dart';
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
    // Initialize repositories
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

  test('Backup and restore user account A', () async {
    // Profile based connection flow between A and B
    // Alice prepares invite for Bob using Bob's profile public key and shares
    // via the default circle
    final rrCubitA = ReceiveRequestCubit(_cRepoA);
    await rrCubitA.handleProfileLink(
        profileUrl('Bob Profile', _cRepoB.getProfileInfo()!.mainKeyPair!.key)
            .fragment,
        awaitDhtOperations: true);
    var contactBobFromProfile = _cRepoA.getContacts().values.first;
    await _cRepoA.updateCirclesForContact(
        contactBobFromProfile.coagContactId, [defaultInitialCircleId],
        triggerDhtUpdate: false);
    await _cRepoA.tryShareWithContactDHT(contactBobFromProfile.coagContactId);
    final profileBasedOfferLinkFromAliceForBob = profileBasedOfferUrl(
        'Alice Sharing',
        contactBobFromProfile.dhtSettings.recordKeyMeSharing!,
        contactBobFromProfile.dhtSettings.myKeyPair.key);

    // Bob accepts profile based offer from Alice
    await ReceiveRequestCubit(_cRepoB).handleSharingOffer(
        profileBasedOfferLinkFromAliceForBob.fragment,
        awaitDhtOperations: true);
    final contactAliceFromBobsRepo = _cRepoB.getContacts().values.first;
    expect(
      contactAliceFromBobsRepo.details?.names.values.firstOrNull,
      'UserA',
      reason: 'Name from sharing profile',
    );
    // Bob shares name and phone number via default circle
    await _cRepoB.updateCirclesForContact(
        contactAliceFromBobsRepo.coagContactId, [defaultInitialCircleId],
        triggerDhtUpdate: false);
    await _cRepoB.setProfileInfo(
        _cRepoB.getProfileInfo()!.copyWith(
            details:
                (_cRepoB.getProfileInfo()?.details ?? const ContactDetails())
                    .copyWith(phones: {'bananaphone': '123'})),
        triggerDhtUpdate: false);
    await _cRepoB.setProfileInfo(_cRepoB.getProfileInfo()!.copyWith(
            sharingSettings:
                _cRepoB.getProfileInfo()!.sharingSettings.copyWith(phones: {
          'bananaphone': [defaultInitialCircleId]
        })));
    await _cRepoB
        .tryShareWithContactDHT(contactAliceFromBobsRepo.coagContactId);

    // Alice checks for Bob sharing back
    contactBobFromProfile =
        _cRepoA.getContact(contactBobFromProfile.coagContactId)!;
    await _cRepoA.updateContactFromDHT(contactBobFromProfile);
    contactBobFromProfile =
        _cRepoA.getContact(contactBobFromProfile.coagContactId)!;
    expect(
      contactBobFromProfile.details?.names.values.firstOrNull,
      'UserB',
      reason: 'Name from sharing profile',
    );
    expect(
      contactBobFromProfile.details?.phones.values.firstOrNull,
      '123',
      reason: 'Phone number from shared details',
    );

    // Backup
    final backupInfo = await _cRepoA.backup(waitForRecordSync: false);
    expect(backupInfo, isNotNull,
        reason: 'Expecting successful backup record creation.');

    // Restore
    final restoredRepo = ContactsRepository(
        DummyPersistentStorage({}), _distStorage, DummySystemContacts([]), '',
        initialize: false);
    final restoreSuccess = await restoredRepo
        .restore(backupInfo!.$1, backupInfo.$2, awaitDhtOperations: true);
    expect(restoreSuccess, true, reason: 'Expected restore to succeed');
    expect(restoredRepo.getProfileInfo()?.details.names.values.firstOrNull,
        'UserA');
    final restoredContactB =
        restoredRepo.getContact(_cRepoA.getContacts().keys.first);
    expect(restoredContactB?.name, 'Bob Profile');
    expect(restoredContactB?.details?.phones.values.first, '123');
    expect(restoredContactB?.details?.names.values.first, 'UserB');
    expect(
        restoredContactB?.sharedProfile?.details.names.values.first, 'UserA');
  });
}
