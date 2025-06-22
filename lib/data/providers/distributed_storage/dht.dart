// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../models/backup.dart';
import '../../models/coag_contact.dart';
import '../../utils.dart';
import 'base.dart';

String? tryUtf8Decode(Uint8List? content) {
  if (content == null) {
    return null;
  }
  try {
    return utf8.decode(content);
  } on FormatException catch (e) {
    debugPrint('UTF-8 decode attempt lead to $e');
    return null;
  }
}

Future<Uint8List> getChunkedPayload(
    DHTRecord record, VeilidCrypto crypto, DHTRecordRefreshMode refreshMode,
    {required int numChunks, int chunkOffset = 0}) async {
  // Combine the remaining subkeys into the picture
  final chunks = await Future.wait(
      List.generate(numChunks, (i) => i + chunkOffset).map((i) async =>
          record.get(crypto: crypto, refreshMode: refreshMode, subkey: i)));
  final payload = Uint8List.fromList(
      chunks.map((e) => e ?? Uint8List(0)).expand((x) => x).toList());
  return payload;
}

/// From an opened record, get coagulate specific content and picture data from
/// corresponding subkeys
Future<(String?, Uint8List?)> _getJsonProfileAndPictureFromRecord(
    DHTRecord record,
    VeilidCrypto crypto,
    DHTRecordRefreshMode refreshMode) async {
  // Get main profile content from first subkey
  final mainContent =
      await record.get(crypto: crypto, refreshMode: refreshMode, subkey: 0);
  final jsonString = tryUtf8Decode(mainContent);

  final picture = await getChunkedPayload(record, crypto, refreshMode,
      numChunks: 31, chunkOffset: 1);

  return (jsonString, (picture.isEmpty) ? null : picture);
}

Iterable<Uint8List> chopPayloadChunks(Uint8List payload,
        {int chunkMaxBytes = 32000, int numChunks = 31}) =>
    List.generate(
        numChunks,
        (i) => (payload.length > i * chunkMaxBytes)
            ? payload.sublist(
                i * chunkMaxBytes, min(payload.length, (i + 1) * chunkMaxBytes))
            : Uint8List(0));

Future<DhtSettings> rotateKeysInDhtSettings(
    DhtSettings settings,
    PublicKey? usedPublicKey,
    TypedKeyPair? usedKeyPair,
    bool ackHandshakeComplete) async {
  // If either we haven't established a key pair but received handshake complete
  // signal, or our next key pair's public key was used
  final rotateKeyPair = (ackHandshakeComplete && settings.myKeyPair == null) ||
      (usedKeyPair != null && settings.myNextKeyPair == usedKeyPair);

  // If their next public key was used
  final rotatePublicKey =
      usedPublicKey != null && settings.theirNextPublicKey == usedPublicKey;

  if (rotateKeyPair) debugPrint('Rotating my key pair');
  if (rotatePublicKey) debugPrint('Rotating their public key');

  return DhtSettings(
    // If the next key pair was used or acknowledged, rotate it
    myKeyPair: rotateKeyPair ? settings.myNextKeyPair : settings.myKeyPair,
    myNextKeyPair: rotateKeyPair
        ? await generateTypedKeyPairBest()
        : settings.myNextKeyPair,
    // If the next public key was used, rotate it
    theirPublicKey: rotatePublicKey ? usedPublicKey : settings.theirPublicKey,
    theirNextPublicKey: rotatePublicKey ? null : settings.theirNextPublicKey,
    // If anything asymmetric crypto related was rotated, discard symmetric key
    initialSecret:
        (rotateKeyPair || rotatePublicKey) ? null : settings.initialSecret,
    // Leave all other attributes as is
    // TODO: How can we ensure that we don't miss transferring new settings attributes here?
    recordKeyMeSharing: settings.recordKeyMeSharing,
    writerMeSharing: settings.writerMeSharing,
    recordKeyThemSharing: settings.recordKeyThemSharing,
    writerThemSharing: settings.writerThemSharing,
  );
}

DhtSettings updateDhtSettingsFromContactUpdate(
    DhtSettings settings, CoagContactDHTSchema update) {
  // Try deserializing shareBackPublicKey
  late PublicKey? shareBackPublicKey;
  try {
    shareBackPublicKey =
        (update.shareBackPubKey != null && update.shareBackPubKey != 'null')
            ? PublicKey.fromString(update.shareBackPubKey!)
            : null;
  } catch (e) {
    debugPrint('Error decoding share back pub key: $e');
  }

  // Try deserializing shareBackDhtKey
  late Typed<FixedEncodedString43>? shareBackDhtKey;
  try {
    shareBackDhtKey =
        (update.shareBackDHTKey != null && update.shareBackDHTKey != 'null')
            ? Typed<FixedEncodedString43>.fromString(update.shareBackDHTKey!)
            : null;
  } catch (e) {
    debugPrint('Error decoding share back dht key: $e');
  }

  // Try deserializing shareBackDHTKey
  late KeyPair? shareBackDhtWriter;
  try {
    shareBackDhtWriter = (update.shareBackDHTWriter != null &&
            update.shareBackDHTWriter != 'null')
        ? KeyPair.fromString(update.shareBackDHTWriter!)
        : null;
  } catch (e) {
    debugPrint('Error decoding share back writer: $e');
  }

  // Update settings
  return settings.copyWith(
    // If the update contains a public key and it is not already the one in
    // use, add it as the next candidate public key
    theirNextPublicKey: (shareBackPublicKey != null &&
            shareBackPublicKey != settings.theirPublicKey)
        ? shareBackPublicKey
        : null,
    recordKeyMeSharing: shareBackDhtKey,
    writerMeSharing: shareBackDhtWriter,
    theyAckHandshakeComplete: update.ackHandshakeComplete,
  );
}

class VeilidDhtStorage extends DistributedStorage {
  /// Create an empty DHT record, return key and writer in string representation
  @override
  Future<(Typed<FixedEncodedString43>, KeyPair)> createRecord(
      {String? writer}) async {
    final record = await DHTRecordPool.instance.createRecord(
        debugName: 'coag::create',
        // Create subkeys allowing max size of 32KiB per subkey given max record
        // limit of 1MiB, so that we can store a picture in subkeys 2:32
        schema: const DHTSchema.dflt(oCnt: 32),
        crypto: const VeilidCryptoPublic(),
        writer: (writer != null) ? KeyPair.fromString(writer) : null);
    // Write to it once, so push it into the network. (Is this really needed?)
    await record.tryWriteBytes(Uint8List(0));
    await record.close();
    debugPrint(
        'created and wrote once to ${record.key.toString().substring(5, 10)}');
    return (record.key, record.writer!);
  }

  /// Read DHT record, return decrypted content
  @override
  Future<(PublicKey?, TypedKeyPair?, String?, Uint8List?)> readRecord({
    required Typed<FixedEncodedString43> recordKey,
    TypedKeyPair? keyPair,
    TypedKeyPair? nextKeyPair,
    SecretKey? psk,
    PublicKey? publicKey,
    PublicKey? nextPublicKey,
    int maxRetries = 3,
    DHTRecordRefreshMode refreshMode = DHTRecordRefreshMode.network,
  }) async {
    // Derive all available DH secrets to try in addition to the pre shared key
    final domain = utf8.encode('dht');
    final secrets = <(PublicKey?, TypedKeyPair?, SecretKey)>[
      if (psk != null) (null, null, psk),
      if (publicKey != null && keyPair != null)
        (
          publicKey,
          keyPair,
          await Veilid.instance.getCryptoSystem(keyPair.kind).then((cs) async =>
              cs.generateSharedSecret(publicKey, keyPair.secret, domain))
        ),
      if (publicKey != null && nextKeyPair != null)
        (
          publicKey,
          nextKeyPair,
          await Veilid.instance.getCryptoSystem(nextKeyPair.kind).then(
              (cs) async => cs.generateSharedSecret(
                  publicKey, nextKeyPair.secret, domain))
        ),
      if (nextPublicKey != null && keyPair != null)
        (
          nextPublicKey,
          keyPair,
          await Veilid.instance.getCryptoSystem(keyPair.kind).then((cs) async =>
              cs.generateSharedSecret(nextPublicKey, keyPair.secret, domain))
        ),
      if (nextPublicKey != null && nextKeyPair != null)
        (
          nextPublicKey,
          nextKeyPair,
          await Veilid.instance.getCryptoSystem(nextKeyPair.kind).then(
              (cs) async => cs.generateSharedSecret(
                  nextPublicKey, nextKeyPair.secret, domain))
        ),
    ];

    var retries = 0;
    while (true) {
      try {
        debugPrint(
            'trying ${secrets.length} secrets for ${recordKey.toString().substring(5, 10)}');
        for (final secret in secrets) {
          debugPrint('trying pub ${secret.$1?.toString().substring(0, 10)} '
              'kp ${secret.$2?.toString().substring(0, 10)}');

          final crypto = await VeilidCryptoPrivate.fromSharedSecret(
              recordKey.kind, secret.$3);

          final content = await DHTRecordPool.instance
              .openRecordRead(recordKey,
                  debugName: 'coag::read', crypto: crypto)
              .then((record) async {
            try {
              final (jsonString, picture) =
                  await _getJsonProfileAndPictureFromRecord(
                      record, crypto, refreshMode);
              return (jsonString, picture);
            } on FormatException catch (e) {
              // This can happen due to "not enough data to decrypt" when a
              // record was written empty without encryption during init
              // TODO: Only accept "not enough data to decrypt" here, make sure "Unexpected exentsion byte" is passed down as an error
              debugPrint(
                  'error reading ${recordKey.toString().substring(5, 10)} $e');
            } finally {
              await record.close();
            }
          });

          // TODO: Why can't we check for schema_version here?
          if (content?.$1?.contains('details') ?? false) {
            debugPrint('got ${recordKey.toString().substring(5, 10)}');
            return (secret.$1, secret.$2, content?.$1, content?.$2);
          }
        }

        debugPrint('nothing for ${recordKey.toString().substring(5, 10)}');
        return (null, null, null, null);
      } on VeilidAPIExceptionTryAgain {
        // TODO: Handle VeilidAPIExceptionKeyNotFound
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
  /// This is used for sharing only (TODO: consider renaming)
  @override
  Future<void> updateRecord(
      CoagContactDHTSchema? sharedProfile, DhtSettings settings) async {
    if (settings.recordKeyMeSharing == null ||
        settings.writerMeSharing == null) {
      // TODO: Log/raise/handle
      return;
    }
    final _recordKey = settings.recordKeyMeSharing!;

    final content = sharedProfile?.toJsonStringWithoutPicture() ?? '';
    final picture = (sharedProfile?.details.picture == null)
        ? Uint8List(0)
        : Uint8List.fromList(sharedProfile!.details.picture!);

    // Prefer their next public key over the established one for sending updates
    final theirPublicKey =
        settings.theirNextPublicKey ?? settings.theirPublicKey;

    // TODO: Is it safe to assume consistent crypto systems between record key
    //       and psk/public keys or would it make sense to use typed instances?
    final SharedSecret secret;
    if (settings.initialSecret != null && !settings.theyAckHandshakeComplete) {
      // Otherwise, if an initial secret is present, use it for symmetric crypto
      secret = settings.initialSecret!;
      debugPrint('using psk ${secret.toString().substring(0, 6)} '
          'for writing ${_recordKey.toString().substring(5, 10)}');
    } else if (theirPublicKey != null && settings.myKeyPair != null) {
      // If a next public key is queued, use it to confirm
      debugPrint(
          'using their pubkey ${theirPublicKey.toString().substring(0, 6)} '
          'and my kp ${settings.myKeyPair!.key.toString().substring(0, 6)} '
          'for writing ${_recordKey.toString().substring(5, 10)}');
      // Derive DH secret with next public key
      secret = await Veilid.instance
          .getCryptoSystem(settings.myKeyPair!.kind)
          .then((cs) async => cs.generateSharedSecret(
              theirPublicKey, settings.myKeyPair!.secret, utf8.encode('dht')));
    } else {
      // TODO: Raise Exception / signal to user that something is broken
      debugPrint('no crypto for ${_recordKey.toString().substring(5, 10)}');
      return;
    }

    final crypto =
        await VeilidCryptoPrivate.fromSharedSecret(_recordKey.kind, secret);

    // Open, write and close record
    final record = await DHTRecordPool.instance.openRecordWrite(
        _recordKey, settings.writerMeSharing!,
        crypto: crypto, debugName: 'coag::update');
    // Write main profile info
    await record.eventualWriteBytes(
        crypto: crypto, utf8.encode(content), subkey: 0);
    // Write picture chunks to remaining subkeys
    await Future.wait(chopPayloadChunks(picture).toList().asMap().entries.map(
        (e) => record.eventualWriteBytes(
            crypto: crypto, e.value, subkey: e.key + 1)));
    await record.close();

    debugPrint('wrote ${_recordKey.toString().substring(5, 10)}');
  }

  @override
  Future<void> watchRecord(
      Typed<FixedEncodedString43> key,
      Future<void> Function(Typed<FixedEncodedString43> key)
          onNetworkUpdate) async {
    // final record = await DHTRecordPool.instance
    //     .openRecordRead(key, debugName: 'coag::read-to-watch');
    // await record.watch(subkeys: [const ValueSubkeyRange(low: 0, high: 32)]);
    // await record.listen((record, data, subkeys) => onNetworkUpdate(record.key),
    //     localChanges: false);
  }

  @override
  Future<CoagContact?> getContact(CoagContact contact) async {
    if (contact.dhtSettings.recordKeyThemSharing == null) {
      return null;
    }
    final (usedPublicKey, usedKeyPair, contactJson, contactPicture) =
        await readRecord(
      recordKey: contact.dhtSettings.recordKeyThemSharing!,
      psk: contact.dhtSettings.initialSecret,
      publicKey: contact.dhtSettings.theirPublicKey,
      nextPublicKey: contact.dhtSettings.theirNextPublicKey,
      keyPair: contact.dhtSettings.myKeyPair,
      nextKeyPair: contact.dhtSettings.myNextKeyPair,
    );
    if ((contactJson?.isEmpty ?? true) || contactJson == 'null') {
      debugPrint(
          'empty or null ${contact.dhtSettings.recordKeyThemSharing.toString().substring(5, 10)}: $contactJson');
      return null;
    }

    late CoagContactDHTSchema? dhtContact;
    try {
      dhtContact = CoagContactDHTSchema.fromJson(
          json.decode(contactJson!) as Map<String, dynamic>);
    } catch (e) {
      // TODO: Report to user?
      debugPrint(
          'error deserializing ${contact.dhtSettings.recordKeyThemSharing.toString().substring(5, 10)} $e');
      return null;
    }

    final dhtSettingsWithRotatedKeys = await rotateKeysInDhtSettings(
        contact.dhtSettings,
        usedPublicKey,
        usedKeyPair,
        dhtContact.ackHandshakeComplete);

    final updatedDhtSettings = updateDhtSettingsFromContactUpdate(
        dhtSettingsWithRotatedKeys, dhtContact);

    return contact.copyWith(
      theirIdentity: dhtContact.identityKey,
      connectionAttestations: dhtContact.connectionAttestations,
      details: dhtContact.details.copyWith(picture: contactPicture),
      addressLocations: dhtContact.addressLocations,
      temporaryLocations: dhtContact.temporaryLocations,
      introductionsByThem: dhtContact.introductions,
      dhtSettings: updatedDhtSettings,
    );
  }

  @override
  Future<void> updateBackupRecord(
      AccountBackup backup,
      Typed<FixedEncodedString43> recordKey,
      KeyPair writer,
      FixedEncodedString43 secret) async {
    final crypto =
        await VeilidCryptoPrivate.fromSharedSecret(recordKey.kind, secret);
    final record = await DHTRecordPool.instance.openRecordWrite(
        recordKey, writer,
        crypto: crypto, debugName: 'coag::backup');
    await Future.wait(chopPayloadChunks(
            utf8.encode(jsonEncode(backup.toJson())),
            numChunks: 32)
        .toList()
        .asMap()
        .entries
        .map((e) =>
            record.eventualWriteBytes(crypto: crypto, e.value, subkey: e.key)));
    await record.close();
  }

  /// Read backup DHT record, return decrypted content
  @override
  Future<String?> readBackupRecord(
      Typed<FixedEncodedString43> recordKey, FixedEncodedString43 secret,
      {int maxRetries = 3,
      DHTRecordRefreshMode refreshMode = DHTRecordRefreshMode.network}) async {
    // TODO: Handle VeilidAPIExceptionKeyNotFound, VeilidAPIExceptionTryAgain
    var retries = 0;
    while (true) {
      try {
        final pskCrypto =
            await VeilidCryptoPrivate.fromSharedSecret(recordKey.kind, secret);
        final content = await DHTRecordPool.instance
            .openRecordRead(recordKey,
                debugName: 'coag::backup::read', crypto: pskCrypto)
            .then((record) async {
          try {
            final payload = await getChunkedPayload(
                record, pskCrypto, refreshMode,
                numChunks: 32);
            debugPrint('read psk ${recordKey.toString().substring(5, 10)}');
            return tryUtf8Decode(payload);
          } on FormatException catch (e) {
            // This can happen due to "not enough data to decrypt" when a record
            // was written empty without encryption during initialization
            // TODO: Only accept "not enough data to decrypt" here, make sure "Unexpected exentsion byte" is passed down as an error
            debugPrint('psk ${recordKey.toString().substring(5, 10)} $e');
          } finally {
            await record.close();
          }
        });

        return content;
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
}
