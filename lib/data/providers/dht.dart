// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:typed_data';

import 'package:veilid_support/veilid_support.dart';

import '../models/coag_contact.dart';

/// Create an empty DHT record, return key and writer in string representation
Future<(String, String)> createDHTRecord() async {
  final pool = DHTRecordPool.instance;
  final record = await pool.create(
      debugName: 'coag::create', crypto: const DHTRecordCryptoPublic());
  await record.close();
  return (record.key.toString(), record.writer!.toString());
}

/// Read DHT record for given key and secret, return decrypted content
Future<String> readPasswordEncryptedDHTRecord(
    {required String recordKey, required String secret}) async {
  final pool = DHTRecordPool.instance;
  // TODO: Handle VeilidAPIExceptionKeyNotFound, VeilidAPIExceptionTryAgain
  final record = await pool.openRead(
      debugName: 'coag::read',
      Typed<FixedEncodedString43>.fromString(recordKey),
      crypto: const DHTRecordCryptoPublic());
  // TODO: What is the onlyUpdates argument for?
  final raw = await record.get(forceRefresh: true);

  // TODO: Detect if secret is pubkey and use asymmetric encryption here?
  // TODO: Error handling
  final cs = await pool.veilid.bestCryptoSystem();
  final bodyBytes = raw!.sublist(0, raw.length - Nonce.decodedLength());
  final saltBytes = raw.sublist(raw.length - Nonce.decodedLength());
  final decrypted = await cs.decryptAead(bodyBytes, Nonce.fromBytes(saltBytes),
      SharedSecret.fromString(secret), null);

  await record.close();

  return utf8.decode(decrypted);
}

/// Encrypt the content with the given secret and write it to the DHT at key
Future<void> updatePasswordEncryptedDHTRecord(
    {required String recordKey,
    required String recordWriter,
    required String secret,
    required String content}) async {
  final pool = DHTRecordPool.instance;
  final record = await pool.openWrite(
      debugName: 'coag::update',
      Typed<FixedEncodedString43>.fromString(recordKey),
      KeyPair.fromString(recordWriter),
      crypto: const DHTRecordCryptoPublic());

  // TODO: Detect if secret is pubkey and use asymmetric encryption here?
  final cs = await pool.veilid.bestCryptoSystem();
  final nonce = await cs.randomNonce();
  final saltBytes = nonce.decode();
  final encrypted = Uint8List.fromList((await cs.encryptAead(
          utf8.encode(content), nonce, SharedSecret.fromString(secret), null)) +
      saltBytes);

  await record.tryWriteBytes(encrypted);
  await record.close();
}

// TODO: Can we just liberally call this also when not necessary
//       or is there a risk for an update to slip through
//       the interval between unwatch and watch?
Future<void> watchDHTRecord(String key) async {
  final _key = Typed<FixedEncodedString43>.fromString(key);
  final rc = await Veilid.instance.routingContext();
  await rc.cancelDHTWatch(_key);
  await rc.watchDHTValues(_key);
}

Future<bool> isUpToDateSharingDHT(CoagContact contact) async {
  if (contact.dhtSettingsForSharing?.psk == null ||
      contact.sharedProfile == null) {
    return true;
  }

  final record = await readPasswordEncryptedDHTRecord(
      recordKey: contact.dhtSettingsForSharing!.key,
      secret: contact.dhtSettingsForSharing!.psk!);
  return record != contact.sharedProfile;
}

Future<CoagContact> updateContactSharingDHT(CoagContact contact) async {
  if (contact.dhtSettingsForSharing == null ||
      contact.dhtSettingsForSharing!.writer == null) {
    final (key, writer) = await createDHTRecord();
    contact = contact.copyWith(
        dhtSettingsForSharing: ContactDHTSettings(key: key, writer: writer));
  }

  if (contact.dhtSettingsForReceiving == null ||
      contact.dhtSettingsForReceiving!.writer == null) {
    final (key, writer) = await createDHTRecord();
    contact = contact.copyWith(
        dhtSettingsForReceiving: ContactDHTSettings(key: key, writer: writer));
  }

  if (contact.dhtSettingsForSharing!.psk == null) {
    final cs = await DHTRecordPool.instance.veilid.bestCryptoSystem();
    final sharedSecret = await cs.randomSharedSecret();
    contact = contact.copyWith(
        dhtSettingsForSharing: contact.dhtSettingsForSharing!
            .copyWith(psk: sharedSecret.toString()));
  }

  if (contact.sharedProfile != null) {
    await updatePasswordEncryptedDHTRecord(
        recordKey: contact.dhtSettingsForSharing!.key,
        recordWriter: contact.dhtSettingsForSharing!.writer!,
        secret: contact.dhtSettingsForSharing!.psk!,
        content: contact.sharedProfile!);

    // Just to check that writing the record was successful
    // might want to log or raise for debug purposes
    // on sharedProfile != actuallyShareProfile
    final actuallySharedProfile = await readPasswordEncryptedDHTRecord(
        recordKey: contact.dhtSettingsForSharing!.key,
        secret: contact.dhtSettingsForSharing!.psk!);
    contact = contact.copyWith(sharedProfile: actuallySharedProfile);
  }

  return contact;
}

Future<bool> _isAvailableAndWritable(
    ContactDHTSettings? dhtSettingsForSharing) async {
  try {
    // TODO: Try to open in write mode
    return true;
    // TODO: Which other exceptions are relevant?
  } on VeilidAPIExceptionKeyNotFound {
    return false;
  }
}

// TODO: Schema version check and migration for backwards compatibility
Future<CoagContact> updateContactReceivingDHT(CoagContact contact) async {
  if (contact.dhtSettingsForReceiving?.psk == null) {
    return contact;
  }
  final contactJson = await readPasswordEncryptedDHTRecord(
      recordKey: contact.dhtSettingsForReceiving!.key,
      secret: contact.dhtSettingsForReceiving!.psk!);
  if (contactJson.isEmpty) {
    return contact;
  }
  final dhtContact = CoagContactDHTSchemaV1.fromJson(
      json.decode(contactJson) as Map<String, dynamic>);
  return contact.copyWith(
      details: dhtContact.details,
      locations: dhtContact.locations,
      dhtSettingsForSharing: (dhtContact.shareBackDHTKey == null)
          ? null
          : ContactDHTSettings(
              key: dhtContact.shareBackDHTKey!,
              writer: dhtContact.shareBackDHTWriter,
              // TODO: Switch to symmetric crypto as well?
              pubKey: dhtContact.shareBackPubKey));
}
