import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:async_tools/async_tools.dart';
import 'package:charcode/charcode.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:protobuf/protobuf.dart';

import '../veilid_support.dart';
import 'veilid_log.dart';

@immutable
class TableDBArrayUpdate extends Equatable {
  const TableDBArrayUpdate(
      {required this.headDelta, required this.tailDelta, required this.length})
      : assert(length >= 0, 'should never have negative length');
  final int headDelta;
  final int tailDelta;
  final int length;

  @override
  List<Object?> get props => [headDelta, tailDelta, length];
}

class _TableDBArrayBase {
  _TableDBArrayBase({
    required String table,
    required VeilidCrypto crypto,
  })  : _table = table,
        _crypto = crypto {
    _initWait.add(_init);
  }

  // static Future<TableDBArray> make({
  //   required String table,
  //   required VeilidCrypto crypto,
  // }) async {
  //   final out = TableDBArray(table: table, crypto: crypto);
  //   await out._initWait();
  //   return out;
  // }

  Future<void> initWait() async {
    await _initWait();
  }

  Future<void> _init(Completer<void> _) async {
    // Load the array details
    await _mutex.protect(() async {
      _tableDB = await Veilid.instance.openTableDB(_table, 1);
      await _loadHead();
      _initDone = true;
    });
  }

  Future<void> close({bool delete = false}) async {
    // Ensure the init finished
    await _initWait();

    // Allow multiple attempts to close
    if (_open) {
      await _mutex.protect(() async {
        await _changeStream.close();
        _tableDB.close();
        _open = false;
      });
    }
    if (delete) {
      await Veilid.instance.deleteTableDB(_table);
    }
  }

  Future<void> delete() async {
    await _initWait();
    if (_open) {
      throw StateError('should be closed first');
    }
    await Veilid.instance.deleteTableDB(_table);
  }

  Future<StreamSubscription<void>> listen(
          void Function(TableDBArrayUpdate) onChanged) async =>
      _changeStream.stream.listen(onChanged);

  ////////////////////////////////////////////////////////////
  // Public interface

  int get length {
    if (!_open) {
      throw StateError('not open');
    }
    if (!_initDone) {
      throw StateError('not initialized');
    }

    return _length;
  }

  bool get isOpen => _open;

  Future<void> _add(Uint8List value) async {
    await _initWait();
    return _writeTransaction((t) => _addInner(t, value));
  }

  Future<void> _addAll(List<Uint8List> values) async {
    await _initWait();
    return _writeTransaction((t) => _addAllInner(t, values));
  }

  Future<void> _insert(int pos, Uint8List value) async {
    await _initWait();
    return _writeTransaction((t) => _insertInner(t, pos, value));
  }

  Future<void> _insertAll(int pos, List<Uint8List> values) async {
    await _initWait();
    return _writeTransaction((t) => _insertAllInner(t, pos, values));
  }

  Future<Uint8List> _get(int pos) async {
    await _initWait();
    return _mutex.protect(() {
      if (!_open) {
        throw StateError('not open');
      }
      return _getInner(pos);
    });
  }

  Future<List<Uint8List>> _getRange(int start, [int? end]) async {
    await _initWait();
    return _mutex.protect(() {
      if (!_open) {
        throw StateError('not open');
      }
      return _getRangeInner(start, end ?? _length);
    });
  }

  Future<void> _remove(int pos, {Output<Uint8List>? out}) async {
    await _initWait();
    return _writeTransaction((t) => _removeInner(t, pos, out: out));
  }

  Future<void> _removeRange(int start, int end,
      {Output<List<Uint8List>>? out}) async {
    await _initWait();
    return _writeTransaction((t) => _removeRangeInner(t, start, end, out: out));
  }

  Future<void> clear() async {
    await _initWait();
    return _writeTransaction((t) async {
      final keys = await _tableDB.getKeys(0);
      for (final key in keys) {
        await t.delete(0, key);
      }
      _length = 0;
      _nextFree = 0;
      _maxEntry = 0;
      _dirtyChunks.clear();
      _chunkCache.clear();
    });
  }

  ////////////////////////////////////////////////////////////
  // Inner interface

  Future<void> _addInner(VeilidTableDBTransaction t, Uint8List value) async {
    // Allocate an entry to store the value
    final entry = await _allocateEntry();
    await _storeEntry(t, entry, value);

    // Put the entry in the index
    final pos = _length;
    _length++;
    _tailDelta++;
    await _setIndexEntry(pos, entry);
  }

  Future<void> _addAllInner(
      VeilidTableDBTransaction t, List<Uint8List> values) async {
    var pos = _length;
    _length += values.length;
    _tailDelta += values.length;
    for (final value in values) {
      // Allocate an entry to store the value
      final entry = await _allocateEntry();
      await _storeEntry(t, entry, value);

      // Put the entry in the index
      await _setIndexEntry(pos, entry);
      pos++;
    }
  }

  Future<void> _insertInner(
      VeilidTableDBTransaction t, int pos, Uint8List value) async {
    if (pos == _length) {
      return _addInner(t, value);
    }
    if (pos < 0 || pos >= _length) {
      throw IndexError.withLength(pos, _length);
    }
    // Allocate an entry to store the value
    final entry = await _allocateEntry();
    await _storeEntry(t, entry, value);

    // Put the entry in the index
    await _insertIndexEntry(pos);
    await _setIndexEntry(pos, entry);
  }

  Future<void> _insertAllInner(
      VeilidTableDBTransaction t, int pos, List<Uint8List> values) async {
    if (pos == _length) {
      return _addAllInner(t, values);
    }
    if (pos < 0 || pos >= _length) {
      throw IndexError.withLength(pos, _length);
    }
    await _insertIndexEntries(pos, values.length);
    for (final value in values) {
      // Allocate an entry to store the value
      final entry = await _allocateEntry();
      await _storeEntry(t, entry, value);

      // Put the entry in the index
      await _setIndexEntry(pos, entry);
      pos++;
    }
  }

  Future<Uint8List> _getInner(int pos) async {
    if (pos < 0 || pos >= _length) {
      throw IndexError.withLength(pos, _length);
    }
    final entry = await _getIndexEntry(pos);
    return (await _loadEntry(entry))!;
  }

  Future<List<Uint8List>> _getRangeInner(int start, int end) async {
    final length = end - start;
    if (length < 0) {
      throw StateError('length should not be negative');
    }
    if (start < 0 || start >= _length) {
      throw IndexError.withLength(start, _length);
    }
    if (end > _length) {
      throw IndexError.withLength(end, _length);
    }

    final out = <Uint8List>[];
    const batchSize = 16;

    for (var pos = start; pos < end;) {
      var batchLen = min(batchSize, end - pos);
      final dws = DelayedWaitSet<Uint8List, void>();
      while (batchLen > 0) {
        final entry = await _getIndexEntry(pos);
        dws.add((_) async {
          try {
            return (await _loadEntry(entry))!;
            // Need some way to debug ParallelWaitError
            // ignore: avoid_catches_without_on_clauses
          } catch (e, st) {
            veilidLoggy.error('$e\n$st\n');
            rethrow;
          }
        });
        pos++;
        batchLen--;
      }
      final batchOut = await dws();
      out.addAll(batchOut);
    }

    return out;
  }

  Future<void> _removeInner(VeilidTableDBTransaction t, int pos,
      {Output<Uint8List>? out}) async {
    if (pos < 0 || pos >= _length) {
      throw IndexError.withLength(pos, _length);
    }

    final entry = await _getIndexEntry(pos);
    if (out != null) {
      final value = (await _loadEntry(entry))!;
      out.save(value);
    }

    await _freeEntry(t, entry);
    await _removeIndexEntry(pos);
  }

  Future<void> _removeRangeInner(VeilidTableDBTransaction t, int start, int end,
      {Output<List<Uint8List>>? out}) async {
    final length = end - start;
    if (length < 0) {
      throw StateError('length should not be negative');
    }
    if (start < 0) {
      throw IndexError.withLength(start, _length);
    }
    if (end > _length) {
      throw IndexError.withLength(end, _length);
    }

    final outList = <Uint8List>[];
    for (var pos = start; pos < end; pos++) {
      final entry = await _getIndexEntry(pos);
      if (out != null) {
        final value = (await _loadEntry(entry))!;
        outList.add(value);
      }
      await _freeEntry(t, entry);
    }
    if (out != null) {
      out.save(outList);
    }

    await _removeIndexEntries(start, length);
  }

  ////////////////////////////////////////////////////////////
  // Private implementation

  static final _headKey = Uint8List.fromList([$_, $H, $E, $A, $D]);
  static Uint8List _entryKey(int k) =>
      (ByteData(4)..setUint32(0, k)).buffer.asUint8List();
  static Uint8List _chunkKey(int n) =>
      (ByteData(2)..setUint16(0, n)).buffer.asUint8List();

  Future<T> _writeTransaction<T>(
          Future<T> Function(VeilidTableDBTransaction) closure) =>
      _mutex.protect(() async {
        if (!_open) {
          throw StateError('not open');
        }

        final oldLength = _length;
        final oldNextFree = _nextFree;
        final oldMaxEntry = _maxEntry;
        final oldHeadDelta = _headDelta;
        final oldTailDelta = _tailDelta;
        try {
          final out = await transactionScope(_tableDB, (t) async {
            final out = await closure(t);
            await _saveHead(t);
            await _flushDirtyChunks(t);
            // Send change
            _changeStream.add(TableDBArrayUpdate(
                headDelta: _headDelta, tailDelta: _tailDelta, length: _length));
            _headDelta = 0;
            _tailDelta = 0;
            return out;
          });

          return out;
        } on Exception {
          // restore head
          _length = oldLength;
          _nextFree = oldNextFree;
          _maxEntry = oldMaxEntry;
          _headDelta = oldHeadDelta;
          _tailDelta = oldTailDelta;
          // invalidate caches because they could have been written to
          _chunkCache.clear();
          _dirtyChunks.clear();
          // propagate exception
          rethrow;
        }
      });

  Future<void> _storeEntry(
          VeilidTableDBTransaction t, int entry, Uint8List value) async =>
      t.store(0, _entryKey(entry), await _crypto.encrypt(value));

  Future<Uint8List?> _loadEntry(int entry) async {
    final encryptedValue = await _tableDB.load(0, _entryKey(entry));
    return (encryptedValue == null)
        ? null
        : await _crypto.decrypt(encryptedValue);
  }

  Future<int> _getIndexEntry(int pos) async {
    if (pos < 0 || pos >= _length) {
      throw IndexError.withLength(pos, _length);
    }
    final chunkNumber = pos ~/ _indexStride;
    final chunkOffset = pos % _indexStride;

    final chunk = await _loadIndexChunk(chunkNumber);

    return chunk.buffer.asByteData().getUint32(chunkOffset * 4);
  }

  Future<void> _setIndexEntry(int pos, int entry) async {
    if (pos < 0 || pos >= _length) {
      throw IndexError.withLength(pos, _length);
    }

    final chunkNumber = pos ~/ _indexStride;
    final chunkOffset = pos % _indexStride;

    final chunk = await _loadIndexChunk(chunkNumber);
    chunk.buffer.asByteData().setUint32(chunkOffset * 4, entry);

    _dirtyChunks[chunkNumber] = chunk;
  }

  Future<void> _insertIndexEntry(int pos) => _insertIndexEntries(pos, 1);

  Future<void> _insertIndexEntries(int start, int length) async {
    if (length == 0) {
      return;
    }
    if (length < 0) {
      throw StateError('length should not be negative');
    }
    if (start < 0 || start >= _length) {
      throw IndexError.withLength(start, _length);
    }

    // Slide everything over in reverse
    var src = _length - 1;
    var dest = src + length;

    (int, Uint8List)? lastSrcChunk;
    (int, Uint8List)? lastDestChunk;
    while (src >= start) {
      final remaining = (src - start) + 1;
      final srcChunkNumber = src ~/ _indexStride;
      final srcIndex = src % _indexStride;
      final srcLength = min(remaining, srcIndex + 1);

      final srcChunk =
          (lastSrcChunk != null && (lastSrcChunk.$1 == srcChunkNumber))
              ? lastSrcChunk.$2
              : await _loadIndexChunk(srcChunkNumber);
      _dirtyChunks[srcChunkNumber] = srcChunk;
      lastSrcChunk = (srcChunkNumber, srcChunk);

      final destChunkNumber = dest ~/ _indexStride;
      final destIndex = dest % _indexStride;
      final destLength = min(remaining, destIndex + 1);

      final destChunk =
          (lastDestChunk != null && (lastDestChunk.$1 == destChunkNumber))
              ? lastDestChunk.$2
              : await _loadIndexChunk(destChunkNumber);
      _dirtyChunks[destChunkNumber] = destChunk;
      lastDestChunk = (destChunkNumber, destChunk);

      final toCopy = min(srcLength, destLength);
      destChunk.setRange((destIndex - (toCopy - 1)) * 4, (destIndex + 1) * 4,
          srcChunk, (srcIndex - (toCopy - 1)) * 4);

      dest -= toCopy;
      src -= toCopy;
    }

    // Then add to length
    _length += length;
    if (start == 0) {
      _headDelta += length;
    }
    _tailDelta += length;
  }

  Future<void> _removeIndexEntry(int pos) => _removeIndexEntries(pos, 1);

  Future<void> _removeIndexEntries(int start, int length) async {
    if (length == 0) {
      return;
    }
    if (length < 0) {
      throw StateError('length should not be negative');
    }
    if (start < 0 || start >= _length) {
      throw IndexError.withLength(start, _length);
    }
    final end = start + length - 1;
    if (end < 0 || end >= _length) {
      throw IndexError.withLength(end, _length);
    }

    // Slide everything over
    var dest = start;
    var src = end + 1;
    (int, Uint8List)? lastSrcChunk;
    (int, Uint8List)? lastDestChunk;
    while (src < _length) {
      final srcChunkNumber = src ~/ _indexStride;
      final srcIndex = src % _indexStride;
      final srcLength = _indexStride - srcIndex;

      final srcChunk =
          (lastSrcChunk != null && (lastSrcChunk.$1 == srcChunkNumber))
              ? lastSrcChunk.$2
              : await _loadIndexChunk(srcChunkNumber);
      _dirtyChunks[srcChunkNumber] = srcChunk;
      lastSrcChunk = (srcChunkNumber, srcChunk);

      final destChunkNumber = dest ~/ _indexStride;
      final destIndex = dest % _indexStride;
      final destLength = _indexStride - destIndex;

      final destChunk =
          (lastDestChunk != null && (lastDestChunk.$1 == destChunkNumber))
              ? lastDestChunk.$2
              : await _loadIndexChunk(destChunkNumber);
      _dirtyChunks[destChunkNumber] = destChunk;
      lastDestChunk = (destChunkNumber, destChunk);

      final toCopy = min(srcLength, destLength);
      destChunk.setRange(
          destIndex * 4, (destIndex + toCopy) * 4, srcChunk, srcIndex * 4);

      dest += toCopy;
      src += toCopy;
    }

    // Then truncate
    _length -= length;
    if (start == 0) {
      _headDelta -= length;
    }
    _tailDelta -= length;
  }

  Future<Uint8List> _loadIndexChunk(int chunkNumber) async {
    // Get it from the dirty chunks if we have it
    final dirtyChunk = _dirtyChunks[chunkNumber];
    if (dirtyChunk != null) {
      return dirtyChunk;
    }

    // Get from cache if we have it
    for (var i = 0; i < _chunkCache.length; i++) {
      if (_chunkCache[i].$1 == chunkNumber) {
        // Touch the element
        final x = _chunkCache.removeAt(i);
        _chunkCache.add(x);
        // Return the chunk for this position
        return x.$2;
      }
    }

    // Get chunk from disk
    var chunk = await _tableDB.load(0, _chunkKey(chunkNumber));
    chunk ??= Uint8List(_indexStride * 4);

    // Cache the chunk
    _chunkCache.add((chunkNumber, chunk));
    if (_chunkCache.length > _chunkCacheLength) {
      // Trim the LRU cache
      final (_, _) = _chunkCache.removeAt(0);
    }

    return chunk;
  }

  Future<void> _flushDirtyChunks(VeilidTableDBTransaction t) async {
    for (final ec in _dirtyChunks.entries) {
      await t.store(0, _chunkKey(ec.key), ec.value);
    }
    _dirtyChunks.clear();
  }

  Future<void> _loadHead() async {
    assert(_mutex.isLocked, 'should be locked');
    final headBytes = await _tableDB.load(0, _headKey);
    if (headBytes == null) {
      _length = 0;
      _nextFree = 0;
      _maxEntry = 0;
    } else {
      final b = headBytes.buffer.asByteData();
      _length = b.getUint32(0);
      _nextFree = b.getUint32(4);
      _maxEntry = b.getUint32(8);
    }
  }

  Future<void> _saveHead(VeilidTableDBTransaction t) async {
    assert(_mutex.isLocked, 'should be locked');
    final b = ByteData(12)
      ..setUint32(0, _length)
      ..setUint32(4, _nextFree)
      ..setUint32(8, _maxEntry);
    await t.store(0, _headKey, b.buffer.asUint8List());
  }

  Future<int> _allocateEntry() async {
    assert(_mutex.isLocked, 'should be locked');
    if (_nextFree == 0) {
      return _maxEntry++;
    }
    // pop endogenous free list
    final free = _nextFree;
    final nextFreeBytes = await _tableDB.load(0, _entryKey(free));
    _nextFree = nextFreeBytes!.buffer.asByteData().getUint8(0);
    return free;
  }

  Future<void> _freeEntry(VeilidTableDBTransaction t, int entry) async {
    assert(_mutex.isLocked, 'should be locked');
    // push endogenous free list
    final b = ByteData(4)..setUint32(0, _nextFree);
    await t.store(0, _entryKey(entry), b.buffer.asUint8List());
    _nextFree = entry;
  }

  final String _table;
  late final VeilidTableDB _tableDB;
  var _open = true;
  var _initDone = false;
  final VeilidCrypto _crypto;
  final WaitSet<void, void> _initWait = WaitSet();
  final _mutex = Mutex(debugLockTimeout: kIsDebugMode ? 60 : null);

  // Change tracking
  var _headDelta = 0;
  var _tailDelta = 0;

  // Head state
  var _length = 0;
  var _nextFree = 0;
  var _maxEntry = 0;
  static const _indexStride = 16384;
  final List<(int, Uint8List)> _chunkCache = [];
  final Map<int, Uint8List> _dirtyChunks = {};
  static const _chunkCacheLength = 3;

  final StreamController<TableDBArrayUpdate> _changeStream =
      StreamController.broadcast();
}

//////////////////////////////////////////////////////////////////////////////

class TableDBArray extends _TableDBArrayBase {
  TableDBArray({
    required super.table,
    required super.crypto,
  });

  static Future<TableDBArray> make({
    required String table,
    required VeilidCrypto crypto,
  }) async {
    final out = TableDBArray(table: table, crypto: crypto);
    await out._initWait();
    return out;
  }

  ////////////////////////////////////////////////////////////
  // Public interface

  Future<void> add(Uint8List value) => _add(value);

  Future<void> addAll(List<Uint8List> values) => _addAll(values);

  Future<void> insert(int pos, Uint8List value) => _insert(pos, value);

  Future<void> insertAll(int pos, List<Uint8List> values) =>
      _insertAll(pos, values);

  Future<Uint8List?> get(
    int pos,
  ) =>
      _get(pos);

  Future<List<Uint8List>> getRange(int start, [int? end]) =>
      _getRange(start, end);

  Future<void> remove(int pos, {Output<Uint8List>? out}) =>
      _remove(pos, out: out);

  Future<void> removeRange(int start, int end,
          {Output<List<Uint8List>>? out}) =>
      _removeRange(start, end, out: out);
}
//////////////////////////////////////////////////////////////////////////////

class TableDBArrayJson<T> extends _TableDBArrayBase {
  TableDBArrayJson(
      {required super.table,
      required super.crypto,
      required T Function(dynamic) fromJson})
      : _fromJson = fromJson;

  static Future<TableDBArrayJson<T>> make<T>(
      {required String table,
      required VeilidCrypto crypto,
      required T Function(dynamic) fromJson}) async {
    final out =
        TableDBArrayJson<T>(table: table, crypto: crypto, fromJson: fromJson);
    await out._initWait();
    return out;
  }

  ////////////////////////////////////////////////////////////
  // Public interface

  Future<void> add(T value) => _add(jsonEncodeBytes(value));

  Future<void> addAll(List<T> values) =>
      _addAll(values.map(jsonEncodeBytes).toList());

  Future<void> insert(int pos, T value) => _insert(pos, jsonEncodeBytes(value));

  Future<void> insertAll(int pos, List<T> values) =>
      _insertAll(pos, values.map(jsonEncodeBytes).toList());

  Future<T> get(
    int pos,
  ) =>
      _get(pos).then((out) => jsonDecodeBytes(_fromJson, out));

  Future<List<T>> getRange(int start, [int? end]) =>
      _getRange(start, end).then((out) => out.map(_fromJson).toList());

  Future<void> remove(int pos, {Output<T>? out}) async {
    final outJson = (out != null) ? Output<Uint8List>() : null;
    await _remove(pos, out: outJson);
    if (outJson != null && outJson.value != null) {
      out!.save(jsonDecodeBytes(_fromJson, outJson.value!));
    }
  }

  Future<void> removeRange(int start, int end, {Output<List<T>>? out}) async {
    final outJson = (out != null) ? Output<List<Uint8List>>() : null;
    await _removeRange(start, end, out: outJson);
    if (outJson != null && outJson.value != null) {
      out!.save(
          outJson.value!.map((x) => jsonDecodeBytes(_fromJson, x)).toList());
    }
  }

  ////////////////////////////////////////////////////////////////////////////
  final T Function(dynamic) _fromJson;
}

//////////////////////////////////////////////////////////////////////////////

class TableDBArrayProtobuf<T extends GeneratedMessage>
    extends _TableDBArrayBase {
  TableDBArrayProtobuf(
      {required super.table,
      required super.crypto,
      required T Function(List<int>) fromBuffer})
      : _fromBuffer = fromBuffer;

  static Future<TableDBArrayProtobuf<T>> make<T extends GeneratedMessage>(
      {required String table,
      required VeilidCrypto crypto,
      required T Function(List<int>) fromBuffer}) async {
    final out = TableDBArrayProtobuf<T>(
        table: table, crypto: crypto, fromBuffer: fromBuffer);
    await out._initWait();
    return out;
  }

  ////////////////////////////////////////////////////////////
  // Public interface

  Future<void> add(T value) => _add(value.writeToBuffer());

  Future<void> addAll(List<T> values) =>
      _addAll(values.map((x) => x.writeToBuffer()).toList());

  Future<void> insert(int pos, T value) => _insert(pos, value.writeToBuffer());

  Future<void> insertAll(int pos, List<T> values) =>
      _insertAll(pos, values.map((x) => x.writeToBuffer()).toList());

  Future<T> get(
    int pos,
  ) =>
      _get(pos).then(_fromBuffer);

  Future<List<T>> getRange(int start, [int? end]) =>
      _getRange(start, end).then((out) => out.map(_fromBuffer).toList());

  Future<void> remove(int pos, {Output<T>? out}) async {
    final outProto = (out != null) ? Output<Uint8List>() : null;
    await _remove(pos, out: outProto);
    if (outProto != null && outProto.value != null) {
      out!.save(_fromBuffer(outProto.value!));
    }
  }

  Future<void> removeRange(int start, int end, {Output<List<T>>? out}) async {
    final outProto = (out != null) ? Output<List<Uint8List>>() : null;
    await _removeRange(start, end, out: outProto);
    if (outProto != null && outProto.value != null) {
      out!.save(outProto.value!.map(_fromBuffer).toList());
    }
  }

  ////////////////////////////////////////////////////////////////////////////
  final T Function(List<int>) _fromBuffer;
}
