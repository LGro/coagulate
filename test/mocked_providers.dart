// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:coagulate/data/models/batch_invites.dart';
import 'package:coagulate/data/models/coag_contact.dart';
import 'package:coagulate/data/models/contact_update.dart';
import 'package:coagulate/data/models/profile_sharing_settings.dart';
import 'package:coagulate/data/providers/distributed_storage/dht.dart';
import 'package:coagulate/data/providers/persistent_storage/base.dart';
import 'package:coagulate/data/providers/system_contacts/base.dart';
import 'package:coagulate/data/providers/system_contacts/system_contacts.dart';
import 'package:coagulate/data/repositories/contacts.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:veilid_support/veilid_support.dart';

const dummyAppUserName = 'App User Name';

Uint8List randomUint8List(int length) {
  final random = Random.secure();
  return Uint8List.fromList(List.generate(length, (_) => random.nextInt(256)));
}

Typed<FixedEncodedString43> dummyDhtRecordKey([int? i]) =>
    Typed<FixedEncodedString43>(
        kind: cryptoKindVLD0,
        value: (i == null)
            ? FixedEncodedString43.fromBytes(randomUint8List(32))
            : FixedEncodedString43.fromBytes(
                Uint8List.fromList(List.filled(32, i))));

FixedEncodedString43 dummyPsk(int i) =>
    FixedEncodedString43.fromBytes(Uint8List.fromList(List.filled(32, i)));

Future<ContactsRepository> contactsRepositoryFromContacts(
        {required List<CoagContact> contacts,
        required Map<Typed<FixedEncodedString43>, CoagContactDHTSchema?>
            initialDht,
        String appUserName = dummyAppUserName}) async =>
    ContactsRepository(
        DummyPersistentStorage(
            Map.fromEntries(contacts.map((c) => MapEntry(c.coagContactId, c)))),
        DummyDistributedStorage(initialDht: initialDht),
        DummySystemContacts([]),
        appUserName);

class DummyPersistentStorage extends PersistentStorage {
  DummyPersistentStorage(this.contacts, {this.profileContactId});

  Map<String, CoagContact> contacts;
  String? profileContactId;
  List<String> log = [];
  Map<String, String> circles = {};
  ProfileSharingSettings profileSharingSettings =
      const ProfileSharingSettings();
  Map<String, List<String>> circleMemberships = {};
  List<ContactUpdate> updates = [];
  ProfileInfo? profileInfo;
  List<BatchInvite> batches = [];

  @override
  Future<void> addUpdate(ContactUpdate update) async {
    log.add('addUpdate');
    updates.add(update);
  }

  @override
  Future<Map<String, CoagContact>> getAllContacts() async {
    log.add('getAllContacts');
    return contacts;
  }

  @override
  Future<CoagContact> getContact(String coagContactId) async {
    log.add('getContact:$coagContactId');
    final c = contacts[coagContactId];
    if (c == null) {
      // TODO: handle error case more specifically
      throw Exception('Contact ID $coagContactId could not be found');
    }
    return c;
  }

  @override
  Future<String?> getProfileContactId() async {
    log.add('getProfileContactId');
    return profileContactId;
  }

  @override
  Future<List<ContactUpdate>> getUpdates() async {
    log.add('getUpdates');
    return [];
  }

  @override
  Future<void> removeContact(String coagContactId) async {
    log.add('removeContact:$coagContactId');
    contacts.remove(coagContactId);
  }

  @override
  Future<void> setProfileContactId(String profileContactId) async {
    log.add('setProfileContactId:$profileContactId');
    this.profileContactId = profileContactId;
  }

  @override
  Future<void> updateContact(CoagContact contact) async {
    log.add('updateContact:${contact.coagContactId}');
    contacts[contact.coagContactId] = contact;
  }

  @override
  Future<Map<String, List<String>>> getCircleMemberships() async =>
      circleMemberships;

  @override
  Future<Map<String, String>> getCircles() async => circles;

  @override
  Future<void> updateCircleMemberships(
      Map<String, List<String>> circleMemberships) async {
    log.add('updateCircleMemberships');
    this.circleMemberships = circleMemberships;
  }

  @override
  Future<void> updateCircles(Map<String, String> circles) async {
    log.add('updateCircles');
    this.circles = circles;
  }

  @override
  Future<void> removeProfileContactId() async {
    profileContactId = null;
  }

  @override
  Future<void> addBatch(BatchInvite batch) async {
    batches.add(batch);
  }

  @override
  Future<List<BatchInvite>> getBatches() async => batches;

  @override
  Future<ProfileInfo?> getProfileInfo() async => profileInfo;

  @override
  Future<void> updateProfileInfo(ProfileInfo info) async {
    profileInfo = info;
  }
}

class DummyDistributedStorage extends VeilidDhtStorage {
  DummyDistributedStorage(
      {Map<Typed<FixedEncodedString43>, CoagContactDHTSchema?>? initialDht,
      this.transparent = false}) {
    if (initialDht != null) {
      dht = {...initialDht};
    }
  }
  final bool transparent;
  List<String> log = [];
  Map<Typed<FixedEncodedString43>, CoagContactDHTSchema?> dht = {};
  Map<Typed<FixedEncodedString43>,
          Future<void> Function(Typed<FixedEncodedString43> key)>
      watchedRecords = {};

  @override
  Future<(Typed<FixedEncodedString43>, KeyPair)> createRecord(
      {String? writer}) async {
    log.add('createDHTRecord');
    if (transparent) {
      final recordAndWriter = await super.createRecord(writer: writer);
      dht[recordAndWriter.$1] = null;
      return recordAndWriter;
    }
    final recordKey = dummyDhtRecordKey();
    dht[recordKey] = null;
    return (
      recordKey,
      await generateTypedKeyPairBest().then((tkp) => tkp.toKeyPair())
    );
  }

  @override
  Future<(String?, Uint8List?)> readRecord(
      {required Typed<FixedEncodedString43> recordKey,
      required TypedKeyPair keyPair,
      FixedEncodedString43? psk,
      PublicKey? publicKey,
      int maxRetries = 3,
      DHTRecordRefreshMode refreshMode = DHTRecordRefreshMode.network}) async {
    if (transparent) {
      return super.readRecord(
          recordKey: recordKey,
          keyPair: keyPair,
          psk: psk,
          publicKey: publicKey,
          maxRetries: maxRetries,
          refreshMode: DHTRecordRefreshMode.local);
    }
    return (jsonEncode(dht[recordKey]?.toJson()), null);
  }

  @override
  Future<void> updateRecord(
      CoagContactDHTSchema? sharedProfile, DhtSettings settings) async {
    if (settings.recordKeyMeSharing == null ||
        settings.writerMeSharing == null) {
      return;
    }
    log.add('updateRecord:${settings.recordKeyMeSharing}');
    dht[settings.recordKeyMeSharing!] = sharedProfile;
    if (transparent) {
      return super.updateRecord(sharedProfile, settings);
    }
  }

  @override
  Future<void> watchRecord(
      Typed<FixedEncodedString43> key,
      Future<void> Function(Typed<FixedEncodedString43> key)
          onNetworkUpdate) async {
    log.add('watchRecord:$key');
    if (transparent) {
      return super.watchRecord(key, onNetworkUpdate);
    }
    // TODO: Also call the updates when updates happen
    watchedRecords[key] = onNetworkUpdate;
  }
}

class DummySystemContacts extends SystemContactsBase {
  DummySystemContacts(this.contacts, {this.permissionGranted = true});

  List<Contact> contacts;
  List<String> log = [];
  bool permissionGranted;

  @override
  Future<Contact> getContact(String id) async {
    if (!permissionGranted) {
      throw MissingSystemContactsPermissionError();
    }
    log.add('getContact:$id');
    return Future.value(contacts.where((c) => c.id == id).first);
  }

  @override
  Future<List<Contact>> getContacts() async {
    if (!permissionGranted) {
      throw MissingSystemContactsPermissionError();
    }
    log.add('getContacts');
    return Future.value(contacts);
  }

  @override
  Future<Contact> updateContact(Contact contact) {
    if (!permissionGranted) {
      throw MissingSystemContactsPermissionError();
    }
    log.add('updateContact:${json.encode(contact.toJson())}');
    if (contacts.where((c) => c.id == contact.id).isNotEmpty) {
      contacts =
          contacts.map((c) => (c.id == contact.id) ? contact : c).asList();
    } else {
      contacts.add(contact);
    }
    return Future.value(contact);
  }

  @override
  Future<Contact> insertContact(Contact contact) {
    if (!permissionGranted) {
      throw MissingSystemContactsPermissionError();
    }
    contacts.add(contact);
    return Future.value(contact);
  }

  @override
  Future<bool> requestPermission() async => permissionGranted;
}
