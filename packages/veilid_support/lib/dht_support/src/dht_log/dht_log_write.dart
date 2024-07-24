part of 'dht_log.dart';

////////////////////////////////////////////////////////////////////////////
// Writer implementation

abstract class DHTLogWriteOperations
    implements DHTRandomRead, DHTRandomWrite, DHTAdd, DHTTruncate, DHTClear {}

class _DHTLogWrite extends _DHTLogRead implements DHTLogWriteOperations {
  _DHTLogWrite._(super.spine) : super._();

  @override
  Future<bool> tryWriteItem(int pos, Uint8List newValue,
      {Output<Uint8List>? output}) async {
    if (pos < 0 || pos >= _spine.length) {
      throw IndexError.withLength(pos, _spine.length);
    }
    final lookup = await _spine.lookupPosition(pos);
    if (lookup == null) {
      throw DHTExceptionInvalidData();
    }

    // Write item to the segment
    try {
      await lookup.scope((sa) => sa.operateWrite((write) async {
            final success =
                await write.tryWriteItem(lookup.pos, newValue, output: output);
            if (!success) {
              throw DHTExceptionOutdated();
            }
          }));
    } on DHTExceptionOutdated {
      return false;
    }
    return true;
  }

  @override
  Future<void> swap(int aPos, int bPos) async {
    if (aPos < 0 || aPos >= _spine.length) {
      throw IndexError.withLength(aPos, _spine.length);
    }
    if (bPos < 0 || bPos >= _spine.length) {
      throw IndexError.withLength(bPos, _spine.length);
    }
    final aLookup = await _spine.lookupPosition(aPos);
    if (aLookup == null) {
      throw DHTExceptionInvalidData();
    }
    final bLookup = await _spine.lookupPosition(bPos);
    if (bLookup == null) {
      await aLookup.close();
      throw DHTExceptionInvalidData();
    }

    // Swap items in the segments
    if (aLookup.shortArray == bLookup.shortArray) {
      await bLookup.close();
      return aLookup.scope((sa) => sa.operateWriteEventual(
          (aWrite) async => aWrite.swap(aLookup.pos, bLookup.pos)));
    } else {
      final bItem = Output<Uint8List>();
      return aLookup.scope(
          (sa) => bLookup.scope((sb) => sa.operateWriteEventual((aWrite) async {
                if (bItem.value == null) {
                  final aItem = await aWrite.get(aLookup.pos);
                  if (aItem == null) {
                    throw DHTExceptionInvalidData();
                  }
                  await sb.operateWriteEventual((bWrite) async {
                    final success = await bWrite
                        .tryWriteItem(bLookup.pos, aItem, output: bItem);
                    if (!success) {
                      throw DHTExceptionOutdated();
                    }
                  });
                }
                final success =
                    await aWrite.tryWriteItem(aLookup.pos, bItem.value!);
                if (!success) {
                  throw DHTExceptionOutdated();
                }
              })));
    }
  }

  @override
  Future<void> add(Uint8List value) async {
    // Allocate empty index at the end of the list
    final insertPos = _spine.length;
    _spine.allocateTail(1);
    final lookup = await _spine.lookupPosition(insertPos);
    if (lookup == null) {
      throw StateError("can't write to dht log");
    }

    // Write item to the segment
    return lookup.scope((sa) async => sa.operateWrite((write) async {
          // If this a new segment, then clear it in case we have wrapped around
          if (lookup.pos == 0) {
            await write.clear();
          } else if (lookup.pos != write.length) {
            // We should always be appending at the length
            throw DHTExceptionInvalidData();
          }
          return write.add(value);
        }));
  }

  @override
  Future<void> addAll(List<Uint8List> values) async {
    // Allocate empty index at the end of the list
    final insertPos = _spine.length;
    _spine.allocateTail(values.length);

    // Look up the first position and shortarray
    final dws = DelayedWaitSet<void, void>();

    var success = true;
    for (var valueIdx = 0; valueIdx < values.length;) {
      final remaining = values.length - valueIdx;

      final lookup = await _spine.lookupPosition(insertPos + valueIdx);
      if (lookup == null) {
        throw DHTExceptionInvalidData();
      }

      final sacount = min(remaining, DHTShortArray.maxElements - lookup.pos);
      final sublistValues = values.sublist(valueIdx, valueIdx + sacount);

      dws.add((_) async {
        try {
          await lookup.scope((sa) async => sa.operateWrite((write) async {
                // If this a new segment, then clear it in
                // case we have wrapped around
                if (lookup.pos == 0) {
                  await write.clear();
                } else if (lookup.pos != write.length) {
                  // We should always be appending at the length
                  throw DHTExceptionInvalidData();
                }
                return write.addAll(sublistValues);
              }));
        } on DHTExceptionOutdated {
          success = false;
        }
      });

      valueIdx += sacount;
    }

    await dws();

    if (!success) {
      throw DHTExceptionOutdated();
    }
  }

  @override
  Future<void> truncate(int newLength) async {
    if (newLength < 0) {
      throw StateError('can not truncate to negative length');
    }
    if (newLength >= _spine.length) {
      return;
    }
    await _spine.releaseHead(_spine.length - newLength);
  }

  @override
  Future<void> clear() async {
    await _spine.releaseHead(_spine.length);
  }
}
