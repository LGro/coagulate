// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:veilid/veilid.dart';

import '../../models/coag_contact.dart';

abstract class DistributedStorage {
  /// Create an empty DHT record, return key and writer in string representation
  Future<(String, String)> createRecord();

  /// Read DHT record for given key and secret, return decrypted content
  Future<String> readRecord(
      {required String recordKey, String? psk, TypedKeyPair? keyPair});

  /// Encrypt the content with the given secret and write it to the DHT at key
  Future<void> updateRecord(
      {required String key,
      required String writer,
      required String content,
      String? publicKey,
      String? psk});

  Future<void> watchRecord(
      String key, Future<void> Function(String key) onNetworkUpdate);

  Future<CoagContact?> getContact(
      CoagContact contact, TypedKeyPair appUserKeyPair);
}
