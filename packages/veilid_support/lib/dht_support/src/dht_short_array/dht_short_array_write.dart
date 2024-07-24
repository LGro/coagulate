part of 'dht_short_array.dart';

////////////////////////////////////////////////////////////////////////////
// Writer implementation

abstract class DHTShortArrayWriteOperations
    implements
        DHTRandomRead,
        DHTRandomWrite,
        DHTInsertRemove,
        DHTAdd,
        DHTClear {}

class _DHTShortArrayWrite extends _DHTShortArrayRead
    implements DHTShortArrayWriteOperations {
  _DHTShortArrayWrite._(super.head) : super._();

  @override
  Future<void> add(Uint8List value) => insert(_head.length, value);

  @override
  Future<void> addAll(List<Uint8List> values) =>
      insertAll(_head.length, values);

  @override
  Future<void> insert(int pos, Uint8List value) async {
    if (pos < 0 || pos > _head.length) {
      throw IndexError.withLength(pos, _head.length);
    }

    // Allocate empty index at position
    _head.allocateIndex(pos);
    var success = false;
    try {
      // Write item
      success = await tryWriteItem(pos, value);
    } finally {
      if (!success) {
        _head.freeIndex(pos);
      }
    }
    if (!success) {
      throw DHTExceptionTryAgain();
    }
  }

  @override
  Future<void> insertAll(int pos, List<Uint8List> values) async {
    if (pos < 0 || pos > _head.length) {
      throw IndexError.withLength(pos, _head.length);
    }

    // Allocate empty indices
    for (var i = 0; i < values.length; i++) {
      _head.allocateIndex(pos + i);
    }

    var success = true;
    final outSeqNums = List.generate(values.length, (_) => Output<int>());
    final lookups = <DHTShortArrayHeadLookup>[];
    try {
      // do all lookups
      for (var i = 0; i < values.length; i++) {
        final lookup = await _head.lookupPosition(pos + i, true);
        lookups.add(lookup);
      }

      // Write items in parallel
      final dws = DelayedWaitSet<void>();
      for (var i = 0; i < values.length; i++) {
        final lookup = lookups[i];
        final value = values[i];
        final outSeqNum = outSeqNums[i];
        dws.add(() async {
          final outValue = await lookup.record.tryWriteBytes(value,
              subkey: lookup.recordSubkey, outSeqNum: outSeqNum);
          if (outValue != null) {
            success = false;
          }
        });
      }

      await dws(chunkSize: maxDHTConcurrency, onChunkDone: (_) => success);
    } finally {
      // Update sequence numbers
      for (var i = 0; i < values.length; i++) {
        if (outSeqNums[i].value != null) {
          _head.updatePositionSeq(pos + i, true, outSeqNums[i].value!);
        }
      }

      // Free indices if this was a failure
      if (!success) {
        for (var i = 0; i < values.length; i++) {
          _head.freeIndex(pos);
        }
      }
    }
    if (!success) {
      throw DHTExceptionTryAgain();
    }
  }

  @override
  Future<void> swap(int aPos, int bPos) async {
    if (aPos < 0 || aPos >= _head.length) {
      throw IndexError.withLength(aPos, _head.length);
    }
    if (bPos < 0 || bPos >= _head.length) {
      throw IndexError.withLength(bPos, _head.length);
    }
    // Swap indices
    _head.swapIndex(aPos, bPos);
  }

  @override
  Future<void> remove(int pos, {Output<Uint8List>? output}) async {
    if (pos < 0 || pos >= _head.length) {
      throw IndexError.withLength(pos, _head.length);
    }
    final lookup = await _head.lookupPosition(pos, true);

    final outSeqNum = Output<int>();

    final result = lookup.seq == 0xFFFFFFFF
        ? null
        : await lookup.record.get(subkey: lookup.recordSubkey);

    if (outSeqNum.value != null) {
      _head.updatePositionSeq(pos, false, outSeqNum.value!);
    }

    if (result == null) {
      throw StateError('Element does not exist');
    }
    _head.freeIndex(pos);
    output?.save(result);
  }

  @override
  Future<void> clear() async {
    _head.clearIndex();
  }

  @override
  Future<bool> tryWriteItem(int pos, Uint8List newValue,
      {Output<Uint8List>? output}) async {
    if (pos < 0 || pos >= _head.length) {
      throw IndexError.withLength(pos, _head.length);
    }
    final lookup = await _head.lookupPosition(pos, true);

    final outSeqNumRead = Output<int>();
    final oldValue = lookup.seq == 0xFFFFFFFF
        ? null
        : await lookup.record
            .get(subkey: lookup.recordSubkey, outSeqNum: outSeqNumRead);
    if (outSeqNumRead.value != null) {
      _head.updatePositionSeq(pos, false, outSeqNumRead.value!);
    }

    final outSeqNumWrite = Output<int>();
    final result = await lookup.record.tryWriteBytes(newValue,
        subkey: lookup.recordSubkey, outSeqNum: outSeqNumWrite);
    if (outSeqNumWrite.value != null) {
      _head.updatePositionSeq(pos, true, outSeqNumWrite.value!);
    }

    if (result != null) {
      // A result coming back means the element was overwritten already
      output?.save(result);
      return false;
    }
    output?.save(oldValue);
    return true;
  }
}
