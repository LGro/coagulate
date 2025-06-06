part of 'dht_short_array.dart';

////////////////////////////////////////////////////////////////////////////
// Reader-only implementation

abstract class DHTShortArrayReadOperations implements DHTRandomRead {}

class _DHTShortArrayRead implements DHTShortArrayReadOperations {
  _DHTShortArrayRead._(_DHTShortArrayHead head) : _head = head;

  @override
  int get length => _head.length;

  @override
  Future<Uint8List?> get(int pos, {bool forceRefresh = false}) async {
    if (pos < 0 || pos >= length) {
      throw IndexError.withLength(pos, length);
    }

    try {
      final lookup = await _head.lookupPosition(pos, false);

      final refresh = forceRefresh || _head.positionNeedsRefresh(pos);
      final outSeqNum = Output<int>();
      final out = await lookup.record.get(
          subkey: lookup.recordSubkey,
          refreshMode: refresh
              ? DHTRecordRefreshMode.network
              : DHTRecordRefreshMode.cached,
          outSeqNum: outSeqNum);
      if (outSeqNum.value != null) {
        _head.updatePositionSeq(pos, false, outSeqNum.value!);
      }
      return out;
    } on DHTExceptionNotAvailable {
      // If any element is not available, return null
      return null;
    }
  }

  (int, int) _clampStartLen(int start, int? len) {
    len ??= _head.length;
    if (start < 0) {
      throw IndexError.withLength(start, _head.length);
    }
    if (start > _head.length) {
      throw IndexError.withLength(start, _head.length);
    }
    if ((len + start) > _head.length) {
      len = _head.length - start;
    }
    return (start, len);
  }

  @override
  Future<List<Uint8List>?> getRange(int start,
      {int? length, bool forceRefresh = false}) async {
    final out = <Uint8List>[];
    (start, length) = _clampStartLen(start, length);

    final chunks = Iterable<int>.generate(length)
        .slices(kMaxDHTConcurrency)
        .map((chunk) => chunk.map((pos) async {
              try {
                return await get(pos + start, forceRefresh: forceRefresh);
                // Need some way to debug ParallelWaitError
                // ignore: avoid_catches_without_on_clauses
              } catch (e, st) {
                veilidLoggy.error('$e\n$st\n');
                rethrow;
              }
            }));

    for (final chunk in chunks) {
      var elems = await chunk.wait;

      // Return only the first contiguous range, anything else is garbage
      // due to a representational error in the head or shortarray legnth
      final nullPos = elems.indexOf(null);
      if (nullPos != -1) {
        elems = elems.sublist(0, nullPos);
      }

      out.addAll(elems.cast<Uint8List>());

      if (nullPos != -1) {
        break;
      }
    }

    return out;
  }

  @override
  Future<Set<int>> getOfflinePositions() async {
    final (start, length) = _clampStartLen(0, DHTShortArray.maxElements);

    final indexOffline = <int>{};
    final inspects = await [
      _head._headRecord.inspect(),
      ..._head._linkedRecords.map((lr) => lr.inspect())
    ].wait;

    // Add to offline index
    var strideOffset = 0;
    for (final inspect in inspects) {
      for (final r in inspect.offlineSubkeys) {
        for (var i = r.low; i <= r.high; i++) {
          // If this is the head record, ignore the first head subkey
          if (strideOffset != 0 || i != 0) {
            indexOffline.add(i + ((strideOffset == 0) ? -1 : strideOffset));
          }
        }
      }
      strideOffset += _head._stride;
    }

    // See which positions map to offline indexes
    final positionOffline = <int>{};
    for (var i = start; i < (start + length); i++) {
      final idx = _head._index[i];
      if (indexOffline.contains(idx)) {
        positionOffline.add(i);
      }
    }
    return positionOffline;
  }

  ////////////////////////////////////////////////////////////////////////////
  // Fields
  final _DHTShortArrayHead _head;
}
