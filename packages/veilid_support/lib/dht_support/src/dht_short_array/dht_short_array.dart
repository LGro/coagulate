import 'dart:async';
import 'dart:typed_data';

import 'package:mutex/mutex.dart';
import 'package:protobuf/protobuf.dart';

import '../../../veilid_support.dart';
import '../../proto/proto.dart' as proto;

part 'dht_short_array_head.dart';

///////////////////////////////////////////////////////////////////////

class DHTShortArray {
  ////////////////////////////////////////////////////////////////
  // Constructors

  DHTShortArray._({required DHTRecord headRecord})
      : _head = _DHTShortArrayHead(headRecord: headRecord) {}

  // Create a DHTShortArray
  // if smplWriter is specified, uses a SMPL schema with a single writer
  // rather than the key owner
  static Future<DHTShortArray> create(
      {int stride = maxElements,
      VeilidRoutingContext? routingContext,
      TypedKey? parent,
      DHTRecordCrypto? crypto,
      KeyPair? smplWriter}) async {
    assert(stride <= maxElements, 'stride too long');
    final pool = DHTRecordPool.instance;

    late final DHTRecord dhtRecord;
    if (smplWriter != null) {
      final schema = DHTSchema.smpl(
          oCnt: 0,
          members: [DHTSchemaMember(mKey: smplWriter.key, mCnt: stride + 1)]);
      dhtRecord = await pool.create(
          parent: parent,
          routingContext: routingContext,
          schema: schema,
          crypto: crypto,
          writer: smplWriter);
    } else {
      final schema = DHTSchema.dflt(oCnt: stride + 1);
      dhtRecord = await pool.create(
          parent: parent,
          routingContext: routingContext,
          schema: schema,
          crypto: crypto);
    }

    try {
      final dhtShortArray = DHTShortArray._(headRecord: dhtRecord);
      if (!await dhtShortArray._head._tryWriteHead()) {
        throw StateError('Failed to write head at this time');
      }
      return dhtShortArray;
    } on Exception catch (_) {
      await dhtRecord.delete();
      rethrow;
    }
  }

  static Future<DHTShortArray> openRead(TypedKey headRecordKey,
      {VeilidRoutingContext? routingContext,
      TypedKey? parent,
      DHTRecordCrypto? crypto}) async {
    final dhtRecord = await DHTRecordPool.instance.openRead(headRecordKey,
        parent: parent, routingContext: routingContext, crypto: crypto);
    try {
      final dhtShortArray = DHTShortArray._(headRecord: dhtRecord);
      await dhtShortArray._head._refreshInner();
      return dhtShortArray;
    } on Exception catch (_) {
      await dhtRecord.close();
      rethrow;
    }
  }

  static Future<DHTShortArray> openWrite(
    TypedKey headRecordKey,
    KeyPair writer, {
    VeilidRoutingContext? routingContext,
    TypedKey? parent,
    DHTRecordCrypto? crypto,
  }) async {
    final dhtRecord = await DHTRecordPool.instance.openWrite(
        headRecordKey, writer,
        parent: parent, routingContext: routingContext, crypto: crypto);
    try {
      final dhtShortArray = DHTShortArray._(headRecord: dhtRecord);
      await dhtShortArray._head._refreshInner();
      return dhtShortArray;
    } on Exception catch (_) {
      await dhtRecord.close();
      rethrow;
    }
  }

  static Future<DHTShortArray> openOwned(
    OwnedDHTRecordPointer ownedDHTRecordPointer, {
    required TypedKey parent,
    VeilidRoutingContext? routingContext,
    DHTRecordCrypto? crypto,
  }) =>
      openWrite(
        ownedDHTRecordPointer.recordKey,
        ownedDHTRecordPointer.owner,
        routingContext: routingContext,
        parent: parent,
        crypto: crypto,
      );

  ////////////////////////////////////////////////////////////////////////////
  // Public API

  // External references for the shortarray
  TypedKey get recordKey => _head.headRecord.key;
  OwnedDHTRecordPointer get recordPointer =>
      _head.headRecord.ownedDHTRecordPointer;

  /// Returns the number of elements in the DHTShortArray
  int get length => _head.index.length;

  /// Free all resources for the DHTShortArray
  Future<void> close() async {
    await _watchController?.close();
    await _head.close();
  }

  /// Free all resources for the DHTShortArray and delete it from the DHT
  Future<void> delete() async {
    await _watchController?.close();
    await _head.delete();
  }

  /// Runs a closure that guarantees the DHTShortArray
  /// will be closed upon exit, even if an uncaught exception is thrown
  Future<T> scope<T>(Future<T> Function(DHTShortArray) scopeFunction) async {
    try {
      return await scopeFunction(this);
    } finally {
      await close();
    }
  }

  /// Runs a closure that guarantees the DHTShortArray
  /// will be closed upon exit, and deleted if an an
  /// uncaught exception is thrown
  Future<T> deleteScope<T>(
      Future<T> Function(DHTShortArray) scopeFunction) async {
    try {
      final out = await scopeFunction(this);
      await close();
      return out;
    } on Exception catch (_) {
      await delete();
      rethrow;
    }
  }

  /// Return the item at position 'pos' in the DHTShortArray. If 'forceRefresh'
  /// is specified, the network will always be checked for newer values
  /// rather than returning the existing locally stored copy of the elements.
  Future<Uint8List?> getItem(int pos, {bool forceRefresh = false}) async =>
      _head.operate(
          (head) async => _getItemInner(head, pos, forceRefresh: forceRefresh));

  Future<Uint8List?> _getItemInner(_DHTShortArrayHead head, int pos,
      {bool forceRefresh = false}) async {
    if (pos < 0 || pos >= head.index.length) {
      throw IndexError.withLength(pos, head.index.length);
    }

    final index = head.index[pos];
    final recordNumber = index ~/ head.stride;
    final record = head.getLinkedRecord(recordNumber);
    if (record == null) {
      throw StateError('Record does not exist');
    }
    final recordSubkey = (index % head.stride) + ((recordNumber == 0) ? 1 : 0);

    final refresh = forceRefresh || head.indexNeedsRefresh(index);

    final out = record.get(subkey: recordSubkey, forceRefresh: refresh);

    await head.updateIndexSeq(index, false);

    return out;
  }

  /// Return a list of all of the items in the DHTShortArray. If 'forceRefresh'
  /// is specified, the network will always be checked for newer values
  /// rather than returning the existing locally stored copy of the elements.
  Future<List<Uint8List>?> getAllItems({bool forceRefresh = false}) async =>
      _head.operate((head) async {
        final out = <Uint8List>[];

        for (var pos = 0; pos < head.index.length; pos++) {
          final elem =
              await _getItemInner(head, pos, forceRefresh: forceRefresh);
          if (elem == null) {
            return null;
          }
          out.add(elem);
        }

        return out;
      });

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

  /// Try to add an item to the end of the DHTShortArray. Return true if the
  /// element was successfully added, and false if the state changed before
  /// the element could be added or a newer value was found on the network.
  /// This may throw an exception if the number elements added exceeds the
  /// built-in limit of 'maxElements = 256' entries.
  Future<bool> tryAddItem(Uint8List value) async {
    final out = await _head
            .operateWrite((head) async => _tryAddItemInner(head, value)) ??
        false;

    // Send update
    _watchController?.sink.add(null);

    return out;
  }

  Future<bool> _tryAddItemInner(
      _DHTShortArrayHead head, Uint8List value) async {
    // Allocate empty index
    final index = head.emptyIndex();

    // Add new index
    final pos = head.index.length;
    head.index.add(index);

    // Write item
    final (_, wasSet) = await _tryWriteItemInner(head, pos, value);
    if (!wasSet) {
      return false;
    }

    // Get sequence number written
    await head.updateIndexSeq(index, true);

    return true;
  }

  /// Try to insert an item as position 'pos' of the DHTShortArray.
  /// Return true if the element was successfully inserted, and false if the
  /// state changed before the element could be inserted or a newer value was
  /// found on the network.
  /// This may throw an exception if the number elements added exceeds the
  /// built-in limit of 'maxElements = 256' entries.
  Future<bool> tryInsertItem(int pos, Uint8List value) async {
    final out = await _head.operateWrite(
            (head) async => _tryInsertItemInner(head, pos, value)) ??
        false;

    // Send update
    _watchController?.sink.add(null);

    return out;
  }

  Future<bool> _tryInsertItemInner(
      _DHTShortArrayHead head, int pos, Uint8List value) async {
    // Allocate empty index
    final index = head.emptyIndex();

    // Add new index
    _head.index.insert(pos, index);

    // Write item
    final (_, wasSet) = await _tryWriteItemInner(head, pos, value);
    if (!wasSet) {
      return false;
    }

    // Get sequence number written
    await head.updateIndexSeq(index, true);

    return true;
  }

  /// Try to swap items at position 'aPos' and 'bPos' in the DHTShortArray.
  /// Return true if the elements were successfully swapped, and false if the
  /// state changed before the elements could be swapped or newer values were
  /// found on the network.
  /// This may throw an exception if either of the positions swapped exceed
  /// the length of the list

  Future<bool> trySwapItem(int aPos, int bPos) async {
    final out = await _head.operateWrite(
            (head) async => _trySwapItemInner(head, aPos, bPos)) ??
        false;

    // Send update
    _watchController?.sink.add(null);

    return out;
  }

  Future<bool> _trySwapItemInner(
      _DHTShortArrayHead head, int aPos, int bPos) async {
    // No-op case
    if (aPos == bPos) {
      return true;
    }

    // Swap indices
    final aIdx = _head.index[aPos];
    final bIdx = _head.index[bPos];
    _head.index[aPos] = bIdx;
    _head.index[bPos] = aIdx;

    return true;
  }

  /// Try to remove an item at position 'pos' in the DHTShortArray.
  /// Return the element if it was successfully removed, and null if the
  /// state changed before the elements could be removed or newer values were
  /// found on the network.
  /// This may throw an exception if the position removed exceeeds the length of
  /// the list.

  Future<Uint8List?> tryRemoveItem(int pos) async {
    final out =
        _head.operateWrite((head) async => _tryRemoveItemInner(head, pos));

    // Send update
    _watchController?.sink.add(null);

    return out;
  }

  Future<Uint8List> _tryRemoveItemInner(
      _DHTShortArrayHead head, int pos) async {
    final index = _head.index.removeAt(pos);
    final recordNumber = index ~/ head.stride;
    final record = head.getLinkedRecord(recordNumber);
    if (record == null) {
      throw StateError('Record does not exist');
    }
    final recordSubkey = (index % head.stride) + ((recordNumber == 0) ? 1 : 0);

    final result = await record.get(subkey: recordSubkey);
    if (result == null) {
      throw StateError('Element does not exist');
    }

    head.freeIndex(index);
    return result;
  }

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

  /// Try to remove all items in the DHTShortArray.
  /// Return true if it was successfully cleared, and false if the
  /// state changed before the elements could be cleared or newer values were
  /// found on the network.
  Future<bool> tryClear() async {
    final out =
        await _head.operateWrite((head) async => _tryClearInner(head)) ?? false;

    // Send update
    _watchController?.sink.add(null);

    return out;
  }

  Future<bool> _tryClearInner(_DHTShortArrayHead head) async {
    head.index.clear();
    head.free.clear();
    return true;
  }

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
  Future<(Uint8List?, bool)> tryWriteItem(int pos, Uint8List newValue) async {
    final out = await _head
        .operateWrite((head) async => _tryWriteItemInner(head, pos, newValue));
    if (out == null) {
      return (null, false);
    }

    // Send update
    _watchController?.sink.add(null);

    return out;
  }

  Future<(Uint8List?, bool)> _tryWriteItemInner(
      _DHTShortArrayHead head, int pos, Uint8List newValue) async {
    if (pos < 0 || pos >= head.index.length) {
      throw IndexError.withLength(pos, _head.index.length);
    }

    final index = head.index[pos];
    final recordNumber = index ~/ head.stride;
    final record = await head.getOrCreateLinkedRecord(recordNumber);
    final recordSubkey = (index % head.stride) + ((recordNumber == 0) ? 1 : 0);

    final oldValue = await record.get(subkey: recordSubkey);
    final result = await record.tryWriteBytes(newValue, subkey: recordSubkey);
    if (result != null) {
      // A result coming back means the element was overwritten already
      return (result, false);
    }
    return (oldValue, true);
  }

  /// Set an item at position 'pos' of the DHTShortArray. Retries until the
  /// value being written is successfully made the newest value of the element.
  /// This may throw an exception if the position elements the built-in limit of
  /// 'maxElements = 256' entries.
  Future<void> eventualWriteItem(int pos, Uint8List newValue,
      {Duration? timeout}) async {
    await _head.operateWriteEventual((head) async {
      bool wasSet;
      (_, wasSet) = await _tryWriteItemInner(head, pos, newValue);
      return wasSet;
    }, timeout: timeout);

    // Send update
    _watchController?.sink.add(null);
  }

  /// Change an item at position 'pos' of the DHTShortArray.
  /// Runs with the value of the old element at that position such that it can
  /// be changed to the returned value from tha closure. Retries until the
  /// value being written is successfully made the newest value of the element.
  /// This may throw an exception if the position elements the built-in limit of
  /// 'maxElements = 256' entries.

  Future<void> eventualUpdateItem(
      int pos, Future<Uint8List> Function(Uint8List? oldValue) update,
      {Duration? timeout}) async {
    await _head.operateWriteEventual((head) async {
      final oldData = await getItem(pos);

      // Update the data
      final updatedData = await update(oldData);

      // Set it back
      bool wasSet;
      (_, wasSet) = await _tryWriteItemInner(head, pos, updatedData);
      return wasSet;
    }, timeout: timeout);

    // Send update
    _watchController?.sink.add(null);
  }

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

  /// Convenience function:
  /// Like eventualWriteItem but also encodes the input value as JSON and parses
  /// the returned element as JSON
  Future<void> eventualWriteItemJson<T>(int pos, T newValue,
          {Duration? timeout}) =>
      eventualWriteItem(pos, jsonEncodeBytes(newValue), timeout: timeout);

  /// Convenience function:
  /// Like eventualWriteItem but also encodes the input value as a protobuf
  /// object and parses the returned element as a protobuf object
  Future<void> eventualWriteItemProtobuf<T extends GeneratedMessage>(
          int pos, T newValue,
          {int subkey = -1, Duration? timeout}) =>
      eventualWriteItem(pos, newValue.writeToBuffer(), timeout: timeout);

  /// Convenience function:
  /// Like eventualUpdateItem but also encodes the input value as JSON
  Future<void> eventualUpdateItemJson<T>(
          T Function(dynamic) fromJson, int pos, Future<T> Function(T?) update,
          {Duration? timeout}) =>
      eventualUpdateItem(pos, jsonUpdate(fromJson, update), timeout: timeout);

  /// Convenience function:
  /// Like eventualUpdateItem but also encodes the input value as a protobuf
  /// object
  Future<void> eventualUpdateItemProtobuf<T extends GeneratedMessage>(
          T Function(List<int>) fromBuffer,
          int pos,
          Future<T> Function(T?) update,
          {Duration? timeout}) =>
      eventualUpdateItem(pos, protobufUpdate(fromBuffer, update),
          timeout: timeout);

  Future<StreamSubscription<void>> listen(
    void Function() onChanged,
  ) =>
      _listenMutex.protect(() async {
        // If don't have a controller yet, set it up
        if (_watchController == null) {
          // Set up watch requirements
          _watchController = StreamController<void>.broadcast(onCancel: () {
            // If there are no more listeners then we can get
            // rid of the controller and drop our subscriptions
            unawaited(_listenMutex.protect(() async {
              // Cancel watches of head record
              await _head._cancelWatch();
              _watchController = null;
            }));
          });

          // Start watching head record
          await _head._watch();
        }
        // Return subscription
        return _watchController!.stream.listen((_) => onChanged());
      });

  ////////////////////////////////////////////////////////////////
  // Fields

  static const maxElements = 256;

  // Internal representation refreshed from head record
  final _DHTShortArrayHead _head;

  // Watch mutex to ensure we keep the representation valid
  final Mutex _listenMutex = Mutex();
  // Stream of external changes
  StreamController<void>? _watchController;
}
