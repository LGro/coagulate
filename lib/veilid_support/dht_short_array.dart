import 'dart:typed_data';

import 'package:protobuf/protobuf.dart';
import 'package:veilid/veilid.dart';

import '../entities/proto.dart' as proto;
import '../tools/tools.dart';
import 'veilid_support.dart';

class _DHTShortArrayCache {
  _DHTShortArrayCache()
      : linkedRecords = List<DHTRecord>.empty(growable: true),
        index = List<int>.empty(growable: true),
        free = List<int>.empty(growable: true);

  final List<DHTRecord> linkedRecords;
  final List<int> index;
  final List<int> free;
}

class DHTShortArray {
  DHTShortArray({required DHTRecord dhtRecord})
      : _headRecord = dhtRecord,
        _head = _DHTShortArrayCache() {
    late final int stride;
    switch (dhtRecord.schema) {
      case DHTSchemaDFLT(oCnt: final oCnt):
        stride = oCnt - 1;
        if (stride <= 0) {
          throw StateError('Invalid stride in DHTShortArray');
        }
      case DHTSchemaSMPL():
        throw StateError('Wrote kind of DHT record for DHTShortArray');
    }
    assert(stride <= maxElements, 'stride too long');
    _stride = stride;
  }

  static const maxElements = 256;

  // Head DHT record
  final DHTRecord _headRecord;
  late final int _stride;

  // Cached representation refreshed from head record
  _DHTShortArrayCache _head;

  static Future<DHTShortArray> create(VeilidRoutingContext dhtctx, int stride,
      {DHTRecordCrypto? crypto}) async {
    assert(stride <= maxElements, 'stride too long');
    final dhtRecord = await DHTRecord.create(dhtctx,
        schema: DHTSchema.dflt(oCnt: stride + 1), crypto: crypto);
    try {
      final dhtShortArray = DHTShortArray(dhtRecord: dhtRecord);
      return dhtShortArray;
    } on Exception catch (_) {
      await dhtRecord.delete();
      rethrow;
    }
  }

  static Future<DHTShortArray> openRead(
      VeilidRoutingContext dhtctx, TypedKey dhtRecordKey,
      {DHTRecordCrypto? crypto}) async {
    final dhtRecord =
        await DHTRecord.openRead(dhtctx, dhtRecordKey, crypto: crypto);
    try {
      final dhtShortArray = DHTShortArray(dhtRecord: dhtRecord);
      await dhtShortArray._refreshHead();
      return dhtShortArray;
    } on Exception catch (_) {
      await dhtRecord.close();
      rethrow;
    }
  }

  static Future<DHTShortArray> openWrite(
    VeilidRoutingContext dhtctx,
    TypedKey dhtRecordKey,
    KeyPair writer, {
    DHTRecordCrypto? crypto,
  }) async {
    final dhtRecord =
        await DHTRecord.openWrite(dhtctx, dhtRecordKey, writer, crypto: crypto);
    try {
      final dhtShortArray = DHTShortArray(dhtRecord: dhtRecord);
      await dhtShortArray._refreshHead();
      return dhtShortArray;
    } on Exception catch (_) {
      await dhtRecord.close();
      rethrow;
    }
  }

  ////////////////////////////////////////////////////////////////

  /// Write the current head cache out to a protobuf to be serialized
  Uint8List _headToBuffer() {
    final head = proto.DHTShortArray();
    head.keys.addAll(_head.linkedRecords.map((lr) => lr.key.toProto()));
    head.index.addAll(_head.index);
    return head.writeToBuffer();
  }

  Future<DHTRecord> _openLinkedRecord(TypedKey recordKey) async {
    final writer = _headRecord.writer;
    return (writer != null)
        ? await DHTRecord.openWrite(
            _headRecord.routingContext, recordKey, writer)
        : await DHTRecord.openRead(_headRecord.routingContext, recordKey);
  }

  /// Validate the head from the DHT is properly formatted
  /// and calculate the free list from it while we're here
  List<int> _validateHeadCacheData(
      List<Typed<FixedEncodedString43>> linkedKeys, List<int> index) {
    // Ensure nothing is duplicated in the linked keys set
    final newKeys = linkedKeys.toSet();
    assert(newKeys.length <= (maxElements + (_stride - 1)) ~/ _stride,
        'too many keys');
    assert(newKeys.length == linkedKeys.length, 'duplicated linked keys');
    final newIndex = index.toSet();
    assert(newIndex.length <= maxElements, 'too many indexes');
    assert(newIndex.length == index.length, 'duplicated index locations');
    // Ensure all the index keys fit into the existing records
    final indexCapacity = (linkedKeys.length + 1) * _stride;
    int? maxIndex;
    for (final idx in newIndex) {
      assert(idx >= 0 || idx < indexCapacity, 'index out of range');
      if (maxIndex == null || idx > maxIndex) {
        maxIndex = idx;
      }
    }
    final free = <int>[];
    if (maxIndex != null) {
      for (var i = 0; i < maxIndex; i++) {
        if (!newIndex.contains(i)) {
          free.add(i);
        }
      }
    }
    return free;
  }

  Future<bool> _refreshHead(
      {bool forceRefresh = false, bool onlyUpdates = false}) async {
    // Get an updated head record copy if one exists
    final head = await _headRecord.getProtobuf(proto.DHTShortArray.fromBuffer,
        forceRefresh: forceRefresh, onlyUpdates: onlyUpdates);
    if (head == null) {
      if (onlyUpdates) {
        // No update
        return false;
      }
      throw StateError('head missing during initial refresh');
    }

    // Get the set of new linked keys and validate it
    final linkedKeys = head.keys.map(proto.TypedKeyProto.fromProto).toList();
    final index = head.index;
    final free = _validateHeadCacheData(linkedKeys, index);

    // See which records are actually new
    final oldRecords = Map<TypedKey, DHTRecord>.fromEntries(
        _head.linkedRecords.map((lr) => MapEntry(lr.key, lr)));
    final newRecords = <TypedKey, DHTRecord>{};
    final sameRecords = <TypedKey, DHTRecord>{};
    try {
      for (var n = 0; n < linkedKeys.length; n++) {
        final newKey = linkedKeys[n];
        final oldRecord = oldRecords[newKey];
        if (oldRecord == null) {
          // Open the new record
          final newRecord = await _openLinkedRecord(newKey);
          newRecords[newKey] = newRecord;
        } else {
          sameRecords[newKey] = oldRecord;
        }
      }
    } on Exception catch (_) {
      // On any exception close the records we have opened
      await Future.wait(newRecords.entries.map((e) => e.value.close()));
    }

    // From this point forward we should not throw an exception or everything
    // is possibly invalid. Just pass the exception up it happens and the caller
    // will have to delete this short array and reopen it if it can
    await Future.wait(oldRecords.entries
        .where((e) => !sameRecords.containsKey(e.key))
        .map((e) => e.value.close()));

    // Figure out which indices are free

    // Make the new head cache
    _head = _DHTShortArrayCache()
      ..linkedRecords.addAll(
          linkedKeys.map((key) => (sameRecords[key] ?? newRecords[key])!))
      ..index.addAll(index)
      ..free.addAll(free);
    return true;
  }

  ////////////////////////////////////////////////////////////////

  Future<void> close() async {
    final futures = <Future<void>>[_headRecord.close()];
    for (final lr in _head.linkedRecords) {
      futures.add(lr.close());
    }
    await Future.wait(futures);
  }

  Future<void> delete() async {
    final futures = <Future<void>>[_headRecord.close()];
    for (final lr in _head.linkedRecords) {
      futures.add(lr.delete());
    }
    await Future.wait(futures);
  }

  Future<T> scope<T>(Future<T> Function(DHTShortArray) scopeFunction) async {
    try {
      return await scopeFunction(this);
    } finally {
      await close();
    }
  }

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

  DHTRecord? _getRecord(int recordNumber) {
    if (recordNumber == 0) {
      return _headRecord;
    }
    recordNumber--;
    if (recordNumber >= _head.linkedRecords.length) {
      return null;
    }
    return _head.linkedRecords[recordNumber];
  }

  // xxx: add
  // xxx: insert
  // xxx: swap
  // xxx: remove
  // xxx: clear
  // xxx ensure these write the head back out because they change it

  Future<Uint8List?> getItem(int index, {bool forceRefresh = false}) async {
    await _refreshHead(forceRefresh: forceRefresh, onlyUpdates: true);

    if (index < 0 || index >= _head.index.length) {
      throw IndexError.withLength(index, _head.index.length);
    }
    final recordNumber = index ~/ _stride;
    final record = _getRecord(recordNumber);
    assert(record != null, 'Record does not exist');

    final recordSubkey = (index % _stride) + ((recordNumber == 0) ? 1 : 0);
    return record!.get(subkey: recordSubkey, forceRefresh: forceRefresh);
  }

  Future<Uint8List?> tryWriteItem(int index, Uint8List newValue) async {
    if (await _refreshHead(onlyUpdates: true)) {
      throw StateError('structure changed');
    }

    if (index < 0 || index >= _head.index.length) {
      throw IndexError.withLength(index, _head.index.length);
    }
    final recordNumber = index ~/ _stride;
    final record = _getRecord(recordNumber);
    assert(record != null, 'Record does not exist');

    final recordSubkey = (index % _stride) + ((recordNumber == 0) ? 1 : 0);
    return record!.tryWriteBytes(newValue, subkey: recordSubkey);
  }

  Future<void> eventualWriteItem(int index, Uint8List newValue) async {
    Uint8List? oldData;
    do {
      // Set it back
      oldData = await tryWriteItem(index, newValue);

      // Repeat if newer data on the network was found
    } while (oldData != null);
  }

  Future<void> eventualUpdateItem(
      int index, Future<Uint8List> Function(Uint8List oldValue) update) async {
    var oldData = await getItem(index);
    // Ensure it exists already
    if (oldData == null) {
      throw const FormatException('value does not exist');
    }
    do {
      // Update the data
      final updatedData = await update(oldData!);

      // Set it back
      oldData = await tryWriteItem(index, updatedData);

      // Repeat if newer data on the network was found
    } while (oldData != null);
  }

  Future<T?> tryWriteItemJson<T>(
    T Function(dynamic) fromJson,
    int index,
    T newValue,
  ) =>
      tryWriteItem(index, jsonEncodeBytes(newValue)).then((out) {
        if (out == null) {
          return null;
        }
        return jsonDecodeBytes(fromJson, out);
      });

  Future<T?> tryWriteItemProtobuf<T extends GeneratedMessage>(
    T Function(List<int>) fromBuffer,
    int index,
    T newValue,
  ) =>
      tryWriteItem(index, newValue.writeToBuffer()).then((out) {
        if (out == null) {
          return null;
        }
        return fromBuffer(out);
      });

  Future<void> eventualWriteItemJson<T>(int index, T newValue) =>
      eventualWriteItem(index, jsonEncodeBytes(newValue));

  Future<void> eventualWriteItemProtobuf<T extends GeneratedMessage>(
          int index, T newValue,
          {int subkey = -1}) =>
      eventualWriteItem(index, newValue.writeToBuffer());

  Future<void> eventualUpdateItemJson<T>(
    T Function(dynamic) fromJson,
    int index,
    Future<T> Function(T) update,
  ) =>
      eventualUpdateItem(index, jsonUpdate(fromJson, update));

  Future<void> eventualUpdateItemProtobuf<T extends GeneratedMessage>(
    T Function(List<int>) fromBuffer,
    int index,
    Future<T> Function(T) update,
  ) =>
      eventualUpdateItem(index, protobufUpdate(fromBuffer, update));
}
