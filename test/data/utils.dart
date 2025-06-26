// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';
import 'dart:typed_data';

import 'package:veilid/veilid.dart';
import 'package:yaml/yaml.dart';

Future<String> readCurrentVersionFromPubspec() async {
  final content = await File('pubspec.yaml').readAsString();
  final yamlMap = loadYaml(content) as YamlMap;
  return yamlMap['version'] as String;
}

Map<String, String> loadAllPreviousSchemaVersionJsons(
        String jsonAssetDirectory) =>
    Map.fromEntries(Directory(jsonAssetDirectory)
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.json'))
        .map((file) => MapEntry(file.path, file.readAsStringSync())));

FixedEncodedString43 dummyFixedEncodedString43(int value) =>
    FixedEncodedString43.fromBytes(
        Uint8List.fromList(List<int>.filled(32, value)));
