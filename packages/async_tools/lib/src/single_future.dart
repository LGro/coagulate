import 'dart:async';

import 'async_tag_lock.dart';

AsyncTagLock<Object> _keys = AsyncTagLock();

// Process a single future at a time per tag
//
// The closure function is called to produce the future that is to be executed.
// If a future with a particular tag is still executing, the onBusy callback
// is called.
// When a tagged singleFuture finishes executing, the onDone callback is called.
// If an unhandled exception happens in the closure future, the onError callback
// is called.
void singleFuture<T>(Object tag, Future<T> Function() closure,
    {void Function()? onBusy,
    void Function(T)? onDone,
    void Function(Object e, StackTrace? st)? onError}) {
  if (!_keys.tryLock(tag)) {
    if (onBusy != null) {
      onBusy();
    }
    return;
  }
  unawaited(() async {
    try {
      final out = await closure();
      if (onDone != null) {
        onDone(out);
      }
      // ignore: avoid_catches_without_on_clauses
    } catch (e, sp) {
      if (onError != null) {
        onError(e, sp);
      } else {
        rethrow;
      }
    } finally {
      _keys.unlockTag(tag);
    }
  }());
}
