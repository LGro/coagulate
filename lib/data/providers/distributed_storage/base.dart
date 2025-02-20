// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:veilid/veilid.dart';

import '../../models/coag_contact.dart';

abstract class DistributedStorage {
  /// Create an empty DHT record, return key and writer in string representation
  Future<(Typed<FixedEncodedString43>, KeyPair)> createRecord({String? writer});

  /// Read DHT record for given key and secret, return decrypted content
  Future<String> readRecord(
      {required Typed<FixedEncodedString43> recordKey,
      required TypedKeyPair keyPair,
      FixedEncodedString43? psk,
      PublicKey? publicKey});

  /// Encrypt the content with the given secret and write it to the DHT at key
  Future<void> updateRecord(String content, DhtSettings settings);

  Future<void> watchRecord(Typed<FixedEncodedString43> key,
      Future<void> Function(Typed<FixedEncodedString43> key) onNetworkUpdate);

  Future<CoagContact?> getContact(CoagContact contact);
}
