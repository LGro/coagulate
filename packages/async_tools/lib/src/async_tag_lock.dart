import 'package:mutex/mutex.dart';

class _AsyncTagLockEntry {
  _AsyncTagLockEntry()
      : mutex = Mutex.locked(),
        waitingCount = 0;
  //
  Mutex mutex;
  int waitingCount;
}

class AsyncTagLock<T> {
  AsyncTagLock()
      : _tableLock = Mutex(),
        _locks = {};

  Future<void> lockTag(T tag) async {
    await _tableLock.protect(() async {
      final lockEntry = _locks[tag];
      if (lockEntry != null) {
        lockEntry.waitingCount++;
        await lockEntry.mutex.acquire();
        lockEntry.waitingCount--;
      } else {
        _locks[tag] = _AsyncTagLockEntry();
      }
    });
  }

  bool isLocked(T tag) => _locks.containsKey(tag);

  bool tryLock(T tag) {
    final lockEntry = _locks[tag];
    if (lockEntry != null) {
      return false;
    }
    _locks[tag] = _AsyncTagLockEntry();
    return true;
  }

  void unlockTag(T tag) {
    final lockEntry = _locks[tag]!;
    if (lockEntry.waitingCount == 0) {
      // If nobody is waiting for the mutex we can just drop it
      _locks.remove(tag);
    } else {
      // Someone's waiting for the tag lock so release the mutex for it
      lockEntry.mutex.release();
    }
  }

  Future<R> protect<R>(T tag, {required Future<R> Function() closure}) async {
    await lockTag(tag);
    try {
      return await closure();
    } finally {
      unlockTag(tag);
    }
  }

  //
  final Mutex _tableLock;
  final Map<T, _AsyncTagLockEntry> _locks;
}
