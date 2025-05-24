import 'dart:typed_data';

import 'package:protobuf/protobuf.dart';

import '../../../veilid_support.dart';

////////////////////////////////////////////////////////////////////////////
// Reader interface
abstract class DHTRandomRead {
  /// Returns the number of elements in the DHT container
  int get length;

  /// Return the item at position 'pos' in the DHT container. If 'forceRefresh'
  /// is specified, the network will always be checked for newer values
  /// rather than returning the existing locally stored copy of the elements.
  /// Throws an IndexError if the 'pos' is not within the length
  /// of the container. May return null if the item is not available at this
  /// time.
  Future<Uint8List?> get(int pos, {bool forceRefresh = false});

  /// Return a list of a range of items in the DHTArray. If 'forceRefresh'
  /// is specified, the network will always be checked for newer values
  /// rather than returning the existing locally stored copy of the elements.
  /// Throws an IndexError if either 'start' or '(start+length)' is not within
  /// the length of the container. May return fewer items than the length
  /// expected if the requested items are not available, but will always
  /// return a contiguous range starting at 'start'.
  Future<List<Uint8List>?> getRange(int start,
      {int? length, bool forceRefresh = false});

  /// Get a list of the positions that were written offline and not flushed yet
  Future<Set<int>> getOfflinePositions();
}

extension DHTRandomReadExt on DHTRandomRead {
  /// Convenience function:
  /// Like get but also parses the returned element as JSON
  Future<T?> getJson<T>(T Function(dynamic) fromJson, int pos,
          {bool forceRefresh = false}) =>
      get(pos, forceRefresh: forceRefresh)
          .then((out) => jsonDecodeOptBytes(fromJson, out));

  /// Convenience function:
  /// Like getRange but also parses the returned elements as JSON
  Future<List<T>?> getRangeJson<T>(T Function(dynamic) fromJson, int start,
          {int? length, bool forceRefresh = false}) =>
      getRange(start, length: length, forceRefresh: forceRefresh)
          .then((out) => out?.map(fromJson).toList());

  /// Convenience function:
  /// Like get but also parses the returned element as a protobuf object
  Future<T?> getProtobuf<T extends GeneratedMessage>(
          T Function(List<int>) fromBuffer, int pos,
          {bool forceRefresh = false}) =>
      get(pos, forceRefresh: forceRefresh)
          .then((out) => (out == null) ? null : fromBuffer(out));

  /// Convenience function:
  /// Like getRange but also parses the returned elements as protobuf objects
  Future<List<T>?> getRangeProtobuf<T extends GeneratedMessage>(
          T Function(List<int>) fromBuffer, int start,
          {int? length, bool forceRefresh = false}) =>
      getRange(start, length: length, forceRefresh: forceRefresh)
          .then((out) => out?.map(fromBuffer).toList());
}
