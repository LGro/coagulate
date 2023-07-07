import 'dart:typed_data';

import 'package:change_case/change_case.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:veilid/veilid.dart';

part 'dht.freezed.dart';
part 'dht.g.dart';

// Header in subkey 0 for Fixed DHT Data
// Subkeys 1..=stride on the first key are concatenated chunks
// Subkeys 0..stride on the 'keys' keys are concatenated chunks
@freezed
class DHTData with _$DHTData {
  const factory DHTData({
    // Other keys to concatenate
    required List<TypedKey> keys,
    // Total data size
    required int size,
    // Chunk size per subkey
    required int chunk,
    // Subkeys per key
    required int stride,
  }) = _DHTData;
  factory DHTData.fromJson(Map<String, dynamic> json) => _$DHTData(json);
}
