part of 'dht_short_array.dart';

////////////////////////////////////////////////////////////////////////////
// Writer interface
abstract class DHTShortArrayWrite implements DHTShortArrayRead {
  /// Try to add an item to the end of the DHTShortArray. Return true if the
  /// element was successfully added, and false if the state changed before
  /// the element could be added or a newer value was found on the network.
  /// This may throw an exception if the number elements added exceeds the
  /// built-in limit of 'maxElements = 256' entries.
  Future<bool> tryAddItem(Uint8List value);

  /// Try to insert an item as position 'pos' of the DHTShortArray.
  /// Return true if the element was successfully inserted, and false if the
  /// state changed before the element could be inserted or a newer value was
  /// found on the network.
  /// This may throw an exception if the number elements added exceeds the
  /// built-in limit of 'maxElements = 256' entries.
  Future<bool> tryInsertItem(int pos, Uint8List value);

  /// Try to swap items at position 'aPos' and 'bPos' in the DHTShortArray.
  /// Return true if the elements were successfully swapped, and false if the
  /// state changed before the elements could be swapped or newer values were
  /// found on the network.
  /// This may throw an exception if either of the positions swapped exceed
  /// the length of the list
  Future<bool> trySwapItem(int aPos, int bPos);

  /// Try to remove an item at position 'pos' in the DHTShortArray.
  /// Return the element if it was successfully removed, and null if the
  /// state changed before the elements could be removed or newer values were
  /// found on the network.
  /// This may throw an exception if the position removed exceeeds the length of
  /// the list.
  Future<Uint8List?> tryRemoveItem(int pos);

  /// Try to remove all items in the DHTShortArray.
  /// Return true if it was successfully cleared, and false if the
  /// state changed before the elements could be cleared or newer values were
  /// found on the network.
  Future<bool> tryClear();

  /// Try to set an item at position 'pos' of the DHTShortArray.
  /// If the set was successful this returns:
  ///   * The prior contents of the element, or null if there was no value yet
  ///   * A boolean true
  /// If the set was found a newer value on the network:
  ///   * The newer value of the element, or null if the head record
  ///     changed.
  ///   * A boolean false
  /// This may throw an exception if the position exceeds the built-in limit of
  /// 'maxElements = 256' entries.
  Future<(Uint8List?, bool)> tryWriteItem(int pos, Uint8List newValue);
}

extension DHTShortArrayWriteExt on DHTShortArrayWrite {
  /// Convenience function:
  /// Like removeItem but also parses the returned element as JSON
  Future<T?> tryRemoveItemJson<T>(
    T Function(dynamic) fromJson,
    int pos,
  ) =>
      tryRemoveItem(pos).then((out) => jsonDecodeOptBytes(fromJson, out));

  /// Convenience function:
  /// Like removeItem but also parses the returned element as JSON
  Future<T?> tryRemoveItemProtobuf<T extends GeneratedMessage>(
          T Function(List<int>) fromBuffer, int pos) =>
      getItem(pos).then((out) => (out == null) ? null : fromBuffer(out));

  /// Convenience function:
  /// Like tryWriteItem but also encodes the input value as JSON and parses the
  /// returned element as JSON
  Future<(T?, bool)> tryWriteItemJson<T>(
    T Function(dynamic) fromJson,
    int pos,
    T newValue,
  ) =>
      tryWriteItem(pos, jsonEncodeBytes(newValue))
          .then((out) => (jsonDecodeOptBytes(fromJson, out.$1), out.$2));

  /// Convenience function:
  /// Like tryWriteItem but also encodes the input value as a protobuf object
  /// and parses the returned element as a protobuf object
  Future<(T?, bool)> tryWriteItemProtobuf<T extends GeneratedMessage>(
    T Function(List<int>) fromBuffer,
    int pos,
    T newValue,
  ) =>
      tryWriteItem(pos, newValue.writeToBuffer()).then(
          (out) => ((out.$1 == null ? null : fromBuffer(out.$1!)), out.$2));
}

////////////////////////////////////////////////////////////////////////////
// Writer-only implementation

class _DHTShortArrayWrite implements DHTShortArrayWrite {
  _DHTShortArrayWrite._(_DHTShortArrayHead head)
      : _head = head,
        _reader = _DHTShortArrayRead._(head);

  @override
  Future<bool> tryAddItem(Uint8List value) async {
    // Allocate empty index at the end of the list
    final pos = _head.length;
    _head.allocateIndex(pos);

    // Write item
    final (_, wasSet) = await tryWriteItem(pos, value);
    if (!wasSet) {
      return false;
    }

    // Get sequence number written
    await _head.updatePositionSeq(pos, true);

    return true;
  }

  @override
  Future<bool> tryInsertItem(int pos, Uint8List value) async {
    // Allocate empty index at position
    _head.allocateIndex(pos);

    // Write item
    final (_, wasSet) = await tryWriteItem(pos, value);
    if (!wasSet) {
      return false;
    }

    // Get sequence number written
    await _head.updatePositionSeq(pos, true);

    return true;
  }

  @override
  Future<bool> trySwapItem(int aPos, int bPos) async {
    // Swap indices
    _head.swapIndex(aPos, bPos);

    return true;
  }

  @override
  Future<Uint8List> tryRemoveItem(int pos) async {
    final (record, recordSubkey) = await _head.lookupPosition(pos);
    final result = await record.get(subkey: recordSubkey);
    if (result == null) {
      throw StateError('Element does not exist');
    }
    _head.freeIndex(pos);
    return result;
  }

  @override
  Future<bool> tryClear() async {
    _head.clearIndex();
    return true;
  }

  @override
  Future<(Uint8List?, bool)> tryWriteItem(int pos, Uint8List newValue) async {
    if (pos < 0 || pos >= _head.length) {
      throw IndexError.withLength(pos, _head.length);
    }
    final (record, recordSubkey) = await _head.lookupPosition(pos);
    final oldValue = await record.get(subkey: recordSubkey);
    final result = await record.tryWriteBytes(newValue, subkey: recordSubkey);
    if (result != null) {
      // A result coming back means the element was overwritten already
      return (result, false);
    }
    return (oldValue, true);
  }

  ////////////////////////////////////////////////////////////////////////////
  // Reader passthrough

  @override
  int get length => _reader.length;

  @override
  Future<Uint8List?> getItem(int pos, {bool forceRefresh = false}) =>
      _reader.getItem(pos, forceRefresh: forceRefresh);

  @override
  Future<List<Uint8List>?> getAllItems({bool forceRefresh = false}) =>
      _reader.getAllItems(forceRefresh: forceRefresh);

  ////////////////////////////////////////////////////////////////////////////
  // Fields
  final _DHTShortArrayHead _head;
  final _DHTShortArrayRead _reader;
}
