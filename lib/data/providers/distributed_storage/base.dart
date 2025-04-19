// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:typed_data';

import 'package:veilid/veilid.dart';

import '../../models/backup.dart';
import '../../models/coag_contact.dart';

abstract class DistributedStorage {
  /// Create an empty DHT record, return key and writer in string representation
  Future<(Typed<FixedEncodedString43>, KeyPair)> createRecord({String? writer});

  /// Read DHT record for given key and secret, return decrypted content
  Future<(String?, Uint8List?)> readRecord(
      {required Typed<FixedEncodedString43> recordKey,
      TypedKeyPair? keyPair,
      FixedEncodedString43? psk,
      PublicKey? publicKey});

  /// Encrypt the content with the given secret and write it to the DHT at key
  Future<void> updateRecord(
      CoagContactDHTSchema? sharedProfile, DhtSettings settings);

  Future<void> watchRecord(Typed<FixedEncodedString43> key,
      Future<void> Function(Typed<FixedEncodedString43> key) onNetworkUpdate);

  Future<CoagContact?> getContact(CoagContact contact);

  Future<void> updateBackupRecord(
      AccountBackup backup,
      Typed<FixedEncodedString43> recordKey,
      KeyPair writer,
      FixedEncodedString43 secret);

  Future<String?> readBackupRecord(
      Typed<FixedEncodedString43> recordKey, FixedEncodedString43 secret);
}
