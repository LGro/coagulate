import 'dart:typed_data';

import 'package:protobuf/protobuf.dart';

import '../../../veilid_support.dart';

////////////////////////////////////////////////////////////////////////////
// Writer interface
// ignore: one_member_abstracts
abstract class DHTRandomWrite {
  /// Try to set an item at position 'pos' of the DHT container.
  /// If the set was successful this returns:
  ///   * A boolean true
  ///   * outValue will return the prior contents of the element,
  ///     or null if there was no value yet
  ///
  /// If the set was found a newer value on the network this returns:
  ///   * A boolean false
  ///   * outValue will return the newer value of the element,
  ///     or null if the head record changed.
  ///
  /// Throws an IndexError if the position is not within the length
  /// of the container.
  Future<bool> tryWriteItem(int pos, Uint8List newValue,
      {Output<Uint8List>? output});

  /// Swap items at position 'aPos' and 'bPos' in the DHTArray.
  /// Throws an IndexError if either of the positions swapped exceeds the length
  /// of the container
  Future<void> swap(int aPos, int bPos);
}

extension DHTRandomWriteExt on DHTRandomWrite {
  /// Convenience function:
  /// Like tryWriteItem but also encodes the input value as JSON and parses the
  /// returned element as JSON
  Future<bool> tryWriteItemJson<T>(
      T Function(dynamic) fromJson, int pos, T newValue,
      {Output<T>? output}) async {
    final outValueBytes = output == null ? null : Output<Uint8List>();
    final out = await tryWriteItem(pos, jsonEncodeBytes(newValue),
        output: outValueBytes);
    output.mapSave(outValueBytes, (b) => jsonDecodeBytes(fromJson, b));
    return out;
  }

  /// Convenience function:
  /// Like tryWriteItem but also encodes the input value as a protobuf object
  /// and parses the returned element as a protobuf object
  Future<bool> tryWriteItemProtobuf<T extends GeneratedMessage>(
      T Function(List<int>) fromBuffer, int pos, T newValue,
      {Output<T>? output}) async {
    final outValueBytes = output == null ? null : Output<Uint8List>();
    final out = await tryWriteItem(pos, newValue.writeToBuffer(),
        output: outValueBytes);
    output.mapSave(outValueBytes, fromBuffer);
    return out;
  }
}
