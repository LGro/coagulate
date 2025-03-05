// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:typed_data';

import 'package:coagulate/data/providers/distributed_storage/dht.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('chop picture chunks for picture smaller than chunk size', () {
    final chunks =
        chopPictureChunks(Uint8List(2), chunkMaxBytes: 4, numChunks: 3)
            .toList();
    expect(chunks.length, 3);
    expect(chunks[0].length, 2);
    expect(chunks[1].length, 0);
    expect(chunks[2].length, 0);
  });

  test('chop picture chunks for picture max size', () {
    final chunks = chopPictureChunks(Uint8List.fromList([0, 1, 2, 3]),
            chunkMaxBytes: 2, numChunks: 2)
        .toList();
    expect(chunks.length, 2);
    expect(chunks[0], [0, 1]);
    expect(chunks[1], [2, 3]);
  });
}
