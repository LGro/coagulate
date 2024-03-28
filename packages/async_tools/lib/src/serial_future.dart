// Process a single future at a time per tag queued serially
//
// The closure function is called to produce the future that is to be executed.
// If a future with a particular tag is still executing, it is queued serially
// and executed when the previous tagged future completes.
// When a tagged serialFuture finishes executing, the onDone callback is called.
// If an unhandled exception happens in the closure future, the onError callback
// is called.

import 'dart:async';
import 'dart:collection';

import 'async_tag_lock.dart';

AsyncTagLock<Object> _keys = AsyncTagLock();
typedef SerialFutureQueueItem = Future<void> Function();
Map<Object, Queue<SerialFutureQueueItem>> _queues = {};

SerialFutureQueueItem _makeSerialFutureQueueItem<T>(
        Future<T> Function() closure,
        void Function(T)? onDone,
        void Function(Object e, StackTrace? st)? onError) =>
    () async {
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
      }
    };

void serialFuture<T>(Object tag, Future<T> Function() closure,
    {void Function(T)? onDone,
    void Function(Object e, StackTrace? st)? onError}) {
  final queueItem = _makeSerialFutureQueueItem(closure, onDone, onError);
  if (!_keys.tryLock(tag)) {
    final queue = _queues[tag];
    queue!.add(queueItem);
    return;
  }
  final queue = _queues[tag] = Queue.from([queueItem]);
  unawaited(() async {
    do {
      final queueItem = queue.removeFirst();
      await queueItem();
    } while (queue.isNotEmpty);
    _queues.remove(tag);
    _keys.unlockTag(tag);
  }());
}
