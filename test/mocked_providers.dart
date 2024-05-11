// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';

import 'package:coagulate/data/models/coag_contact.dart';
import 'package:coagulate/data/models/contact_update.dart';
import 'package:coagulate/data/models/profile_sharing_settings.dart';
import 'package:coagulate/data/providers/distributed_storage/base.dart';
import 'package:coagulate/data/providers/persistent_storage/base.dart';
import 'package:coagulate/data/providers/system_contacts/base.dart';
import 'package:coagulate/data/providers/system_contacts/system_contacts.dart';
import 'package:coagulate/data/repositories/contacts.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class DummyPersistentStorage extends PersistentStorage {
  DummyPersistentStorage(this.contacts, {this.profileContactId});

  Map<String, CoagContact> contacts;
  String? profileContactId;
  List<String> log = [];

  @override
  Future<void> addUpdate(ContactUpdate update) {
    log.add('addUpdate');
    // TODO: implement addUpdate
    throw UnimplementedError();
  }

  @override
  Future<Map<String, CoagContact>> getAllContacts() async {
    log.add('getAllContacts');
    return Future.value(contacts);
  }

  @override
  Future<CoagContact> getContact(String coagContactId) async {
    log.add('getContact:$coagContactId');
    return Future.value(contacts[coagContactId]);
  }

  @override
  Future<String?> getProfileContactId() async {
    log.add('getProfileContactId');
    return Future.value(profileContactId);
  }

  @override
  Future<List<ContactUpdate>> getUpdates() async {
    log.add('getUpdates');
    return Future.value([]);
  }

  @override
  Future<void> removeContact(String coagContactId) async {
    log.add('removeContact:$coagContactId');
    contacts.remove(coagContactId);
  }

  @override
  Future<void> setProfileContactId(String profileContactId) {
    log.add('setProfileContactId:$profileContactId');
    this.profileContactId = profileContactId;
    return Future.value();
  }

  @override
  Future<void> updateContact(CoagContact contact) async {
    log.add('updateContact:${contact.coagContactId}');
    contacts[contact.coagContactId] = contact;
  }
}

class DummyDistributedStorage extends DistributedStorage {
  List<String> log = [];
  Map<String, CoagContact> dht = {};

  @override
  Future<(String, String)> createDHTRecord() {
    log.add('createDHTRecord');
    // TODO: implement createDHTRecord
    throw UnimplementedError();
  }

  @override
  Future<bool> isUpToDateSharingDHT(CoagContact contact) {
    log.add('isUpToDateSharingDHT:${contact.coagContactId}');
    // TODO: implement isUpToDateSharingDHT
    throw UnimplementedError();
  }

  @override
  Future<String> readPasswordEncryptedDHTRecord(
      {required String recordKey, required String secret}) async {
    log.add('readPasswordEncryptedDHTRecord:$recordKey:$secret');
    return Future.value(json.encode(removeNullOrEmptyValues(
        filterAccordingToSharingProfile(
                profile: CoagContact(
                    coagContactId: '',
                    systemContact: Contact(displayName: 'Contact From DHT')),
                settings:
                    const ProfileSharingSettings(displayName: ['Circle1']),
                activeCircles: ['Circle1'],
                shareBackSettings: null)
            .toJson())));
  }

  @override
  Future<CoagContact> updateContactReceivingDHT(CoagContact contact) {
    log.add('updateContactReceivingDHT:${contact.coagContactId}');
    dht[contact.coagContactId] = contact;
    return Future.value(contact);
  }

  @override
  Future<CoagContact> updateContactSharingDHT(CoagContact contact) {
    log.add('updateContactSharingDHT:${contact.coagContactId}');
    dht[contact.coagContactId] = contact;
    return Future.value(contact);
  }

  @override
  Future<void> updatePasswordEncryptedDHTRecord(
      {required String recordKey,
      required String recordWriter,
      required String secret,
      required String content}) {
    log.add('updatePasswordEncryptedDHTRecord:$recordKey');
    // TODO: implement updatePasswordEncryptedDHTRecord
    throw UnimplementedError();
  }

  @override
  Future<void> watchDHTRecord(String key) {
    log.add('watchDHTRecord:$key');
    // TODO: implement watchDHTRecord
    throw UnimplementedError();
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
