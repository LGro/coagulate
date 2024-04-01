part of 'dht_short_array.dart';

////////////////////////////////////////////////////////////////////////////
// Reader interface
abstract class DHTShortArrayRead {
  /// Returns the number of elements in the DHTShortArray
  int get length;

  /// Return the item at position 'pos' in the DHTShortArray. If 'forceRefresh'
  /// is specified, the network will always be checked for newer values
  /// rather than returning the existing locally stored copy of the elements.
  Future<Uint8List?> getItem(int pos, {bool forceRefresh = false});

  /// Return a list of all of the items in the DHTShortArray. If 'forceRefresh'
  /// is specified, the network will always be checked for newer values
  /// rather than returning the existing locally stored copy of the elements.
  Future<List<Uint8List>?> getAllItems({bool forceRefresh = false});
}

extension DHTShortArrayReadExt on DHTShortArrayRead {
  /// Convenience function:
  /// Like getItem but also parses the returned element as JSON
  Future<T?> getItemJson<T>(T Function(dynamic) fromJson, int pos,
          {bool forceRefresh = false}) =>
      getItem(pos, forceRefresh: forceRefresh)
          .then((out) => jsonDecodeOptBytes(fromJson, out));

  /// Convenience function:
  /// Like getAllItems but also parses the returned elements as JSON
  Future<List<T>?> getAllItemsJson<T>(T Function(dynamic) fromJson,
          {bool forceRefresh = false}) =>
      getAllItems(forceRefresh: forceRefresh)
          .then((out) => out?.map(fromJson).toList());

  /// Convenience function:
  /// Like getItem but also parses the returned element as a protobuf object
  Future<T?> getItemProtobuf<T extends GeneratedMessage>(
          T Function(List<int>) fromBuffer, int pos,
          {bool forceRefresh = false}) =>
      getItem(pos, forceRefresh: forceRefresh)
          .then((out) => (out == null) ? null : fromBuffer(out));

  /// Convenience function:
  /// Like getAllItems but also parses the returned elements as protobuf objects
  Future<List<T>?> getAllItemsProtobuf<T extends GeneratedMessage>(
          T Function(List<int>) fromBuffer,
          {bool forceRefresh = false}) =>
      getAllItems(forceRefresh: forceRefresh)
          .then((out) => out?.map(fromBuffer).toList());
}

////////////////////////////////////////////////////////////////////////////
// Reader-only implementation

class _DHTShortArrayRead implements DHTShortArrayRead {
  _DHTShortArrayRead._(_DHTShortArrayHead head) : _head = head;

  /// Returns the number of elements in the DHTShortArray
  @override
  int get length => _head.length;

  /// Return the item at position 'pos' in the DHTShortArray. If 'forceRefresh'
  /// is specified, the network will always be checked for newer values
  /// rather than returning the existing locally stored copy of the elements.
  @override
  Future<Uint8List?> getItem(int pos, {bool forceRefresh = false}) async {
    if (pos < 0 || pos >= length) {
      throw IndexError.withLength(pos, length);
    }

    final (record, recordSubkey) = await _head.lookupPosition(pos);

    final refresh = forceRefresh || _head.positionNeedsRefresh(pos);
    final out = record.get(subkey: recordSubkey, forceRefresh: refresh);
    await _head.updatePositionSeq(pos, false);

    return out;
  }

  /// Return a list of all of the items in the DHTShortArray. If 'forceRefresh'
  /// is specified, the network will always be checked for newer values
  /// rather than returning the existing locally stored copy of the elements.
  @override
  Future<List<Uint8List>?> getAllItems({bool forceRefresh = false}) async {
    final out = <Uint8List>[];

    for (var pos = 0; pos < _head.length; pos++) {
      final elem = await getItem(pos, forceRefresh: forceRefresh);
      if (elem == null) {
        return null;
      }
      out.add(elem);
    }

    return out;
  }

  ////////////////////////////////////////////////////////////////////////////
  // Fields
  final _DHTShortArrayHead _head;
}
