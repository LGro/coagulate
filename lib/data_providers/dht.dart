// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:math';

import 'package:veilid_support/veilid_support.dart';

import '../data/models/coag_contact.dart';

String _getRandomString(int length) {
  const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final _rnd = Random.secure();
  return String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
}

/// Create an empty DHT record, return key and writer in string representation
Future<(String, String)> createDHTRecord() async {
  final pool = DHTRecordPool.instance;
  final record = await pool.create(crypto: const DHTRecordCryptoPublic());
  await record.close();
  return (record.key.toString(), record.writer!.toString());
}

/// Read DHT record for given key and secret, return decrypted content
Future<String> readPasswordEncryptedDHTRecord(
    {required String recordKey, required String secret}) async {
  final pool = DHTRecordPool.instance;
  final record = await pool.openRead(
      Typed<FixedEncodedString43>.fromString(recordKey),
      crypto: const DHTRecordCryptoPublic());
  final raw = await record.get();

  final cs = await pool.veilid.bestCryptoSystem();
  // TODO: Detect if secret is pubkey and use asymmetric encryption here?
  // TODO: Error handling
  final decrypted = await cs.decryptAeadWithPassword(raw!, secret);

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
      Typed<FixedEncodedString43>.fromString(recordKey),
      KeyPair.fromString(recordWriter),
      crypto: const DHTRecordCryptoPublic());

  final cs = await pool.veilid.bestCryptoSystem();
  // TODO: Detect if secret is pubkey and use asymmetric encryption here?
  final encryptedProfile =
      await cs.encryptAeadWithPassword(utf8.encode(content), secret);

  await record.tryWriteBytes(encryptedProfile);
  await record.close();
}

/// Delete DHT record for given key that is writable by recordWriter
// Future<void> deleteDHTRecord(
//     {required String recordKey, required String recordWriter}) async {
//   final pool = DHTRecordPool.instance;
//   final record = await pool.openWrite(
//       Typed<FixedEncodedString43>.fromString(recordKey),
//       KeyPair.fromString(recordWriter),
//       crypto: const DHTRecordCryptoPublic());
//   await record.delete();
//   // TODO: Do we need to await close after delete?
//   // await record.close();
// }

// TODO: Can we just liberally call this also when not necessary
//       or is there a risk for an update to slip through
//       the interval between unwatch and watch?
Future<void> watchDHTRecord(String key) async {
  final _key = Typed<FixedEncodedString43>.fromString(key);
  final rc = await Veilid.instance.routingContext();
  await rc.cancelDHTWatch(_key);
  await rc.watchDHTValues(_key);
}

Future<CoagContact> updateContactDHT(CoagContact contact) async {
  if (contact.dhtSettings == null || contact.dhtSettings!.writer == null) {
    final (key, writer) = await createDHTRecord();
    contact = contact.copyWith(
        dhtSettings: ContactDHTSettings(key: key, writer: writer));
  }

  if (contact.dhtSettings!.psk == null) {
    contact = contact.copyWith(
        dhtSettings: contact.dhtSettings!.copyWith(psk: _getRandomString(16)));
  }

  if (contact.sharedProfile != null) {
    await updatePasswordEncryptedDHTRecord(
        recordKey: contact.dhtSettings!.key,
        recordWriter: contact.dhtSettings!.writer!,
        secret: contact.dhtSettings!.psk!,
        content: contact.sharedProfile!);
  }

  return contact;
}
