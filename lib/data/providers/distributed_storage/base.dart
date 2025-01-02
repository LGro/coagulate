// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import '../../models/coag_contact.dart';

abstract class DistributedStorage {
  /// Create an empty DHT record, return key and writer in string representation
  Future<(String, String)> createDHTRecord();

  /// Read DHT record for given key and secret, return decrypted content
  Future<String> readPasswordEncryptedDHTRecord(
      {required String recordKey, required String secret});

  /// Encrypt the content with the given secret and write it to the DHT at key
  Future<void> updatePasswordEncryptedDHTRecord(
      {required String recordKey,
      required String recordWriter,
      required String secret,
      required String content});

  Future<void> watchDHTRecord(
      String key, Future<void> Function(String key) onNetworkUpdate);

  Future<CoagContact> updateContactSharingDHT(CoagContact contact,
      {Future<String> Function()? pskGenerator});

  Future<CoagContact> updateContactReceivingDHT(CoagContact contact);
}
