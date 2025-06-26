// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:io';

import 'package:coagulate/data/models/contact_introduction.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veilid/veilid.dart';

import '../utils.dart';

const jsonAssetDirectory = 'test/assets/models/contact_introduction';

void main() {
  test('save current json schema version', () async {
    final version = await readCurrentVersionFromPubspec();
    final file = File('$jsonAssetDirectory/$version.json');

    final contactIntro = ContactIntroduction(
        otherName: 'other name',
        otherPublicKey: dummyFixedEncodedString43(1),
        publicKey: dummyFixedEncodedString43(2),
        dhtRecordKeyReceiving: Typed<FixedEncodedString43>(
            kind: 1447838768, value: dummyFixedEncodedString43(3)),
        dhtRecordKeySharing: Typed<FixedEncodedString43>(
            kind: 1447838768, value: dummyFixedEncodedString43(4)),
        dhtWriterSharing: KeyPair(
            key: dummyFixedEncodedString43(5),
            secret: dummyFixedEncodedString43(6)));

    final jsonString = json.encode(contactIntro.toJson());

    if (!loadAllPreviousSchemaVersionJsons(jsonAssetDirectory)
        .values
        .toSet()
        .contains(jsonString)) {
      await file.writeAsString(jsonString);
    }
  });

  test('test loading previous json schema versions', () async {
    for (final jsonEntry
        in loadAllPreviousSchemaVersionJsons(jsonAssetDirectory).entries) {
      try {
        final jsonData =
            await jsonDecode(jsonEntry.value) as Map<String, dynamic>;
        ContactIntroduction.fromJson(jsonData);
      } catch (e, stackTrace) {
        fail('Failed to deserialize ${jsonEntry.key}:\n$e\n$stackTrace');
      }
    }
  });
}
