// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';
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
  } on FormatException catch (e) {
    dev.log('$e');
    return null;
  }
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

  // Combine the remaining subkeys into the picture
  final pictureParts = await Future.wait(List.generate(31, (i) => i + 1).map(
      (i) async =>
          record.get(crypto: crypto, refreshMode: refreshMode, subkey: i)));
  final picture = Uint8List.fromList(
      pictureParts.map((e) => e ?? Uint8List(0)).expand((x) => x).toList());

  return (jsonString, (picture.isEmpty) ? null : picture);
}

Iterable<Uint8List> chopPictureChunks(Uint8List picture,
        {int chunkMaxBytes = 32000, int numChunks = 31}) =>
    List.generate(
        numChunks,
        (i) => (picture.length > i * chunkMaxBytes)
            ? picture.sublist(
                i * chunkMaxBytes, min(picture.length, (i + 1) * chunkMaxBytes))
            : Uint8List(0));

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
    dev.log(
        'created and wrote once to ${record.key.toString().substring(5, 10)}');
    return (record.key, record.writer!);
  }

  /// Read DHT record, return decrypted content
  @override
  Future<(String?, Uint8List?)> readRecord(
      {required Typed<FixedEncodedString43> recordKey,
      required TypedKeyPair keyPair,
      FixedEncodedString43? psk,
      PublicKey? publicKey,
      int maxRetries = 3,
      DHTRecordRefreshMode refreshMode = DHTRecordRefreshMode.network}) async {
    if (psk == null && publicKey == null) {
      // TODO: Raise exception/log/handle
      return (null, null);
    }

    // Derive DH secret
    final dhSecret = (publicKey == null)
        ? null
        : await Veilid.instance.getCryptoSystem(keyPair.kind).then((cs) async =>
            cs.generateSharedSecret(
                publicKey, keyPair.secret, utf8.encode('dht')));

    // TODO: Handle VeilidAPIExceptionKeyNotFound, VeilidAPIExceptionTryAgain
    var retries = 0;
    while (true) {
      try {
        if (dhSecret != null) {
          final dhCrypto = await VeilidCryptoPrivate.fromSharedSecret(
              recordKey.kind, dhSecret);
          final content = await DHTRecordPool.instance
              .openRecordRead(recordKey,
                  debugName: 'coag::read', crypto: dhCrypto)
              .then((record) async {
            try {
              final (jsonString, picture) =
                  await _getJsonProfileAndPictureFromRecord(
                      record, dhCrypto, refreshMode);
              dev.log('read pub ${recordKey.toString().substring(5, 10)}');
              return (jsonString, picture);
            } on FormatException catch (e) {
              // This can happen due to "not enough data to decrypt" when a record
              // was written empty without encryption during initialization
              // TODO: Only accept "not enough data to decrypt" here, make sure "Unexpected exentsion byte" is passed down as an error
              dev.log('pub ${recordKey.toString().substring(5, 10)} $e');
            } finally {
              await record.close();
            }
          });

          if (content?.$1 != null) {
            return content!;
          }
        }

        if (psk != null) {
          final pskCrypto =
              await VeilidCryptoPrivate.fromSharedSecret(recordKey.kind, psk);
          final content = await DHTRecordPool.instance
              .openRecordRead(recordKey,
                  debugName: 'coag::read', crypto: pskCrypto)
              .then((record) async {
            try {
              final (jsonString, picture) =
                  await _getJsonProfileAndPictureFromRecord(
                      record, pskCrypto, refreshMode);
              dev.log('read psk ${recordKey.toString().substring(5, 10)}');
              return (jsonString, picture);
            } on FormatException catch (e) {
              // This can happen due to "not enough data to decrypt" when a record
              // was written empty without encryption during initialization
              // TODO: Only accept "not enough data to decrypt" here, make sure "Unexpected exentsion byte" is passed down as an error
              dev.log('psk ${recordKey.toString().substring(5, 10)} $e');
            } finally {
              await record.close();
            }
          });

          if (content?.$1 != null) {
            return content!;
          }
        }

        return (null, null);
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
  /// This is used for sharing only (TODO: consider renaming)
  @override
  Future<void> updateRecord(
      CoagContactDHTSchema? sharedProfile, DhtSettings settings) async {
    if (settings.recordKeyMeSharing == null ||
        settings.writerMeSharing == null) {
      // TODO: Log/raise/handle
      return;
    }
    final content = sharedProfile?.toJsonStringWithoutPicture() ?? '';
    final picture = (sharedProfile?.details.picture == null)
        ? Uint8List(0)
        : Uint8List.fromList(sharedProfile!.details.picture!);

    final _recordKey = settings.recordKeyMeSharing;
    final SharedSecret secret;

    // Ensure that if both parties are ready, we encrypt with DH derived key
    if (settings.theirPublicKey != null && settings.theyAckHandshakeComplete) {
      dev.log(
          'using pubkey ${settings.theirPublicKey.toString().substring(0, 6)} '
          'for writing ${_recordKey.toString().substring(5, 10)}');
      // Derive DH secret
      secret = await Veilid.instance
          .getCryptoSystem(settings.myKeyPair.kind)
          .then((cs) async => cs.generateSharedSecret(settings.theirPublicKey!,
              settings.myKeyPair.secret, utf8.encode('dht')));
    } else if (settings.initialSecret != null) {
      // TODO: Is it safe to assume consistent crypto systems between record key
      // and psk or would it make sense to include the crypto system prefix in
      // the psk and using a TypedSecret.fromString() here?
      secret = settings.initialSecret!;
      dev.log('using psk crypto ${secret.toString().substring(0, 6)} '
          'for writing ${_recordKey.toString().substring(5, 10)}');
    } else {
      // TODO: Raise Exception
      dev.log('no crypto for ${_recordKey.toString().substring(5, 10)}');
      return;
    }
    final crypto =
        await VeilidCryptoPrivate.fromSharedSecret(_recordKey!.kind, secret);

    // Open, write and close record
    final record = await DHTRecordPool.instance.openRecordWrite(
        _recordKey, settings.writerMeSharing!,
        crypto: crypto, debugName: 'coag::update');
    // Write main profile info
    final written = await record.tryWriteBytes(
        crypto: crypto, utf8.encode(content), subkey: 0);
    // Write picture chunks to remaining subkeys
    await Future.wait(chopPictureChunks(picture).toList().asMap().entries.map(
        (e) =>
            record.tryWriteBytes(crypto: crypto, e.value, subkey: e.key + 1)));
    await record.close();

    dev.log('wrote ${_recordKey.toString().substring(5, 10)}');
    if (written != null) {
      // This shouldn't happen, but it does sometimes; do we issue parallel update requests?
      dev.log('found newer for ${_recordKey.toString().substring(5, 10)}');
    }
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
    final (contactJson, contactPicture) = await readRecord(
        recordKey: contact.dhtSettings.recordKeyThemSharing!,
        psk: contact.dhtSettings.initialSecret,
        publicKey: contact.dhtSettings.theirPublicKey,
        keyPair: contact.dhtSettings.myKeyPair);
    if (contactJson?.isEmpty ?? true) {
      return null;
    }
    final dhtContact = CoagContactDHTSchema.fromJson(
        json.decode(contactJson!) as Map<String, dynamic>);

    return contact.copyWith(
        theirPersonalUniqueId: dhtContact.personalUniqueId,
        knownPersonalContactIds: dhtContact.knownPersonalContactIds,
        details: dhtContact.details.copyWith(picture: contactPicture),
        addressLocations: dhtContact.addressLocations,
        temporaryLocations: dhtContact.temporaryLocations,
        // TODO: Check here if share back pub key is valid?
        // TODO: Handle parsing fromString issues
        dhtSettings: (dhtContact.shareBackDHTKey == null ||
                dhtContact.shareBackDHTKey == 'null')
            ? null
            : contact.dhtSettings.copyWith(
                theyAckHandshakeComplete: dhtContact.ackHandshakeComplete,
                recordKeyMeSharing: Typed<FixedEncodedString43>.fromString(
                    dhtContact.shareBackDHTKey!),
                writerMeSharing: (dhtContact.shareBackDHTWriter == null ||
                        dhtContact.shareBackDHTWriter == 'null')
                    ? null
                    : KeyPair.fromString(dhtContact.shareBackDHTWriter!),
                theirPublicKey: (dhtContact.shareBackPubKey == null ||
                        dhtContact.shareBackPubKey == 'null')
                    ? null
                    : FixedEncodedString43.fromString(
                        dhtContact.shareBackPubKey!)));
  }
}
