part of 'dht_log.dart';

////////////////////////////////////////////////////////////////////////////
// Reader-only implementation

abstract class DHTLogReadOperations implements DHTRandomRead {}

class _DHTLogRead implements DHTLogReadOperations {
  _DHTLogRead._(_DHTLogSpine spine) : _spine = spine;

  @override
  int get length => _spine.length;

  @override
  Future<Uint8List?> get(int pos, {bool forceRefresh = false}) async {
    if (pos < 0 || pos >= length) {
      throw IndexError.withLength(pos, length);
    }
    final lookup = await _spine.lookupPosition(pos);
    if (lookup == null) {
      return null;
    }

    return lookup.scope((sa) => sa.operate((read) async {
          if (lookup.pos >= read.length) {
            veilidLoggy.error('DHTLog shortarray read @ ${lookup.pos}'
                ' >= length ${read.length}');
            return null;
          }
          return read.get(lookup.pos, forceRefresh: forceRefresh);
        }));
  }

  (int, int) _clampStartLen(int start, int? len) {
    len ??= _spine.length;
    if (start < 0) {
      throw IndexError.withLength(start, _spine.length);
    }
    if (start > _spine.length) {
      throw IndexError.withLength(start, _spine.length);
    }
    if ((len + start) > _spine.length) {
      len = _spine.length - start;
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
    final positionOffline = <int>{};

    // Iterate positions backward from most recent
    for (var pos = _spine.length - 1; pos >= 0; pos--) {
      // Get position
      final lookup = await _spine.lookupPosition(pos);
      // If position doesn't exist then it definitely wasn't written to offline
      if (lookup == null) {
        continue;
      }

      // Check each segment for offline positions
      var foundOffline = false;
      await lookup.scope((sa) => sa.operate((read) async {
            final segmentOffline = await read.getOfflinePositions();

            // For each shortarray segment go through their segment positions
            // in reverse order and see if they are offline
            for (var segmentPos = lookup.pos;
                segmentPos >= 0 && pos >= 0;
                segmentPos--, pos--) {
              // If the position in the segment is offline, then
              // mark the position in the log as offline
              if (segmentOffline.contains(segmentPos)) {
                positionOffline.add(pos);
                foundOffline = true;
              }
            }
          }));
      // If we found nothing offline in this segment then we can stop
      if (!foundOffline) {
        break;
      }
    }

    return positionOffline;
  }

  ////////////////////////////////////////////////////////////////////////////
  // Fields
  final _DHTLogSpine _spine;
}
