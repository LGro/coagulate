// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:typed_data';

import 'package:veilid_support/veilid_support.dart';

import '../../models/coag_contact.dart';
import 'base.dart';

String? tryUtf8Decode(Uint8List? content) {
  if (content == null) {
    return null;
  }
  try {
    return utf8.decode(content);
  } on FormatException {
    return null;
  }
}

class VeilidDhtStorage extends DistributedStorage {
  /// Create an empty DHT record, return key and writer in string representation
  @override
  Future<(String, String)> createRecord() async {
    final record = await DHTRecordPool.instance.createRecord(
        debugName: 'coag::create', crypto: const VeilidCryptoPublic());
    return (record.key.toString(), record.writer!.toString());
  }

  /// Read DHT record, return decrypted content
  @override
  Future<String> readRecord(
      {required String recordKey,
      String? psk,
      TypedKeyPair? keyPair,
      int maxRetries = 3,
      DHTRecordRefreshMode refreshMode = DHTRecordRefreshMode.network}) async {
    final _recordKey = Typed<FixedEncodedString43>.fromString(recordKey);
    VeilidCryptoPrivate? pskCrypto;
    VeilidCryptoPrivate? asymCrypto;

    if (psk == null && keyPair == null) {
      // TODO: Raise exception
      return '';
    }
    if (psk != null) {
      pskCrypto = await VeilidCryptoPrivate.fromSharedSecret(
          _recordKey.kind, SharedSecret.fromString(psk));
    }
    if (keyPair != null) {
      asymCrypto = await VeilidCryptoPrivate.fromTypedKeyPair(
          keyPair, 'Coagulate Share');
    }

    // TODO: Handle VeilidAPIExceptionKeyNotFound, VeilidAPIExceptionTryAgain
    var retries = 0;
    while (true) {
      try {
        if (asymCrypto != null) {
          final content = await DHTRecordPool.instance
              .openRecordRead(_recordKey,
                  debugName: 'coag::read', crypto: asymCrypto)
              .then((record) => record.get(refreshMode: refreshMode))
              .then(tryUtf8Decode);

          if (content != null) {
            return content;
          }
        }

        if (pskCrypto != null) {
          final content = await DHTRecordPool.instance
              .openRecordRead(_recordKey,
                  debugName: 'coag::read', crypto: pskCrypto)
              .then((record) => record.get(refreshMode: refreshMode))
              .then(tryUtf8Decode);

          if (content != null) {
            return content;
          }
        }

        return '';
      } on VeilidAPIExceptionTryAgain {
        // TODO: Make sure that Veilid offline is detected at a higher level and not triggering errors here
        retries++;
        if (retries <= maxRetries) {
          await Future.delayed(const Duration(milliseconds: 500));
        } else {
          rethrow;
        }
      }
    }
  }

  // TODO: Check and if not handle that the encoded content does (not):
  // exceed e.g. half of the DHT record value limit: 500000 bytes i.e. entries
  /// Encrypt the content with the given secret and write it to the DHT at key
  @override
  Future<void> updateRecord(
      {required String key,
      required String writer,
      required String content,
      String? publicKey,
      String? psk}) async {
    final _recordKey = Typed<FixedEncodedString43>.fromString(key);
    final VeilidCryptoPrivate crypto;

    // Ensure that if available, record is encrypted with public key, not psk
    if (publicKey != null) {
      crypto = await VeilidCryptoPrivate.fromTypedKey(
          TypedKey.fromString(publicKey), 'Coagulate Share');
    } else if (psk != null) {
      // TODO: Is it safe to assume consistent crypto systems between record key
      // and psk or would it make sense to include the crypto system prefix in
      // the psk and using a TypedSecret.fromString() here?
      crypto = await VeilidCryptoPrivate.fromSharedSecret(
          _recordKey.kind, SharedSecret.fromString(psk));
    } else {
      // TODO: Raise Exception
      return;
    }

    await DHTRecordPool.instance
        .openRecordWrite(_recordKey, KeyPair.fromString(writer),
            crypto: crypto, debugName: 'coag::update')
        .then((record) => record.tryWriteBytes(utf8.encode(content)));
  }

  @override
  Future<void> watchRecord(
      String key, Future<void> Function(String key) onNetworkUpdate) async {
    final record = await DHTRecordPool.instance.openRecordRead(
      Typed<FixedEncodedString43>.fromString(key),
      debugName: 'coag::read-to-watch',
    );
    await record
        .watch(subkeys: [ValueSubkeyRange.single(record.subkeyOrDefault(-1))]);
    await record.listen(
        (record, data, subkeys) => onNetworkUpdate(record.key.toString()),
        localChanges: false);
  }

  @override
  Future<CoagContact?> getContact(
      CoagContact contact, TypedKeyPair appUserKeyPair) async {
    if (contact.dhtSettingsForReceiving?.key == null) {
      return null;
    }
    final contactJson = await readRecord(
        recordKey: contact.dhtSettingsForReceiving!.key,
        psk: contact.dhtSettingsForReceiving?.psk,
        keyPair: appUserKeyPair);
    if (contactJson.isEmpty) {
      return null;
    }
    final dhtContact = CoagContactDHTSchema.fromJson(
        json.decode(contactJson) as Map<String, dynamic>);
    return contact.copyWith(
        details: dhtContact.details,
        addressLocations: dhtContact.addressLocations,
        temporaryLocations: dhtContact.temporaryLocations,
        // TODO: Check here if share back pub key is valid?
        dhtSettingsForSharing: contact.dhtSettingsForSharing
            ?.copyWith(pubKey: dhtContact.shareBackPubKey));
  }
}

// TODO: Close all records before going to background / closing the app?
