// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:coagulate/data/models/coag_contact.dart';
import 'package:coagulate/data/models/contact_update.dart';
import 'package:coagulate/data/providers/distributed_storage/base.dart';
import 'package:coagulate/data/providers/persistent_storage/base.dart';

class DummyPersistentStorage extends PersistentStorage {
  DummyPersistentStorage(this.contacts, {this.profileContactId});

  Map<String, CoagContact> contacts;
  String? profileContactId;

  @override
  Future<void> addUpdate(ContactUpdate update) {
    // TODO: implement addUpdate
    throw UnimplementedError();
  }

  @override
  Future<Map<String, CoagContact>> getAllContacts() => Future.value(contacts);

  @override
  Future<CoagContact> getContact(String coagContactId) =>
      Future.value(contacts[coagContactId]);

  @override
  Future<String?> getProfileContactId() => Future.value(profileContactId);

  @override
  Future<List<ContactUpdate>> getUpdates() => Future.value([]);

  @override
  Future<void> removeContact(String coagContactId) async {
    contacts.remove(coagContactId);
  }

  @override
  Future<void> setProfileContactId(String profileContactId) {
    // TODO: implement setProfileContactId
    throw UnimplementedError();
  }

  @override
  Future<void> updateContact(CoagContact contact) async {
    contacts[contact.coagContactId] = contact;
  }
}

class DummyDistributedStorage extends DistributedStorage {
  @override
  Future<(String, String)> createDHTRecord() {
    // TODO: implement createDHTRecord
    throw UnimplementedError();
  }

  @override
  Future<bool> isUpToDateSharingDHT(CoagContact contact) {
    // TODO: implement isUpToDateSharingDHT
    throw UnimplementedError();
  }

  @override
  Future<String> readPasswordEncryptedDHTRecord(
      {required String recordKey, required String secret}) {
    // TODO: implement readPasswordEncryptedDHTRecord
    throw UnimplementedError();
  }

  @override
  Future<CoagContact> updateContactReceivingDHT(CoagContact contact) {
    // TODO: implement updateContactReceivingDHT
    throw UnimplementedError();
  }

  @override
  Future<CoagContact> updateContactSharingDHT(CoagContact contact) {
    // TODO: implement updateContactSharingDHT
    throw UnimplementedError();
  }

  @override
  Future<void> updatePasswordEncryptedDHTRecord(
      {required String recordKey,
      required String recordWriter,
      required String secret,
      required String content}) {
    // TODO: implement updatePasswordEncryptedDHTRecord
    throw UnimplementedError();
  }

  @override
  Future<void> watchDHTRecord(String key) {
    // TODO: implement watchDHTRecord
    throw UnimplementedError();
  }
}
