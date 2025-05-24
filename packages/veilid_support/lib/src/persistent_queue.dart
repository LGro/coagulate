import 'dart:async';
import 'dart:typed_data';

import 'package:async_tools/async_tools.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:protobuf/protobuf.dart';

import 'config.dart';
import 'table_db.dart';
import 'veilid_log.dart';

class PersistentQueue<T extends GeneratedMessage>
    with TableDBBackedFromBuffer<IList<T>> {
  //
  PersistentQueue(
      {required String table,
      required String key,
      required T Function(Uint8List) fromBuffer,
      required Future<void> Function(IList<T>) closure,
      bool deleteOnClose = true,
      void Function(Object, StackTrace)? onError})
      : _table = table,
        _key = key,
        _fromBuffer = fromBuffer,
        _closure = closure,
        _deleteOnClose = deleteOnClose,
        _onError = onError {
    _initWait.add(_init);
  }

  Future<void> close() async {
    // Ensure the init finished
    await _initWait();

    // Close the sync add stream
    await _syncAddController.close();

    // Stop the processing trigger
    await _queueReady.close();

    // Wait for any setStates to finish
    await _queueMutex.acquire();

    // Clean up table if desired
    if (_deleteOnClose) {
      await delete();
    }
  }

  Future<void> _init(Completer<void> _) async {
    // Start the processor
    unawaited(Future.delayed(Duration.zero, () async {
      await _initWait();
      await for (final _ in _queueReady.stream) {
        await _process();
      }
    }));

    // Start the sync add controller
    unawaited(Future.delayed(Duration.zero, () async {
      await _initWait();
      await for (final elem in _syncAddController.stream) {
        await addAll(elem);
      }
    }));

    // Load the queue if we have one
    try {
      await _queueMutex.protect(() async {
        _queue = await load() ?? await store(IList<T>.empty());
      });
    } on Exception catch (e, st) {
      if (_onError != null) {
        _onError(e, st);
      } else {
        rethrow;
      }
    }
  }

  Future<void> _updateQueueInner(IList<T> newQueue) async {
    _queue = await store(newQueue);
    if (_queue.isNotEmpty) {
      _queueReady.sink.add(null);
    }
  }

  Future<void> add(T item) async {
    await _initWait();
    await _queueMutex.protect(() async {
      final newQueue = _queue.add(item);
      await _updateQueueInner(newQueue);
    });
  }

  Future<void> addAll(Iterable<T> items) async {
    await _initWait();
    await _queueMutex.protect(() async {
      final newQueue = _queue.addAll(items);
      await _updateQueueInner(newQueue);
    });
  }

  void addSync(T item) {
    _syncAddController.sink.add([item]);
  }

  void addAllSync(Iterable<T> items) {
    _syncAddController.sink.add(items);
  }

  // Future<bool> get isEmpty async {
  //   await _initWait();
  //   return state.asData!.value.isEmpty;
  // }

  // Future<bool> get isNotEmpty async {
  //   await _initWait();
  //   return state.asData!.value.isNotEmpty;
  // }

  // Future<int> get length async {
  //   await _initWait();
  //   return state.asData!.value.length;
  // }

  // Future<T?> pop() async {
  //   await _initWait();
  //   return _processingMutex.protect(() async => _stateMutex.protect(() async {
  //         final removedItem = Output<T>();
  //         final queue = state.asData!.value.removeAt(0, removedItem);
  //         await _setStateInner(queue);
  //         return removedItem.value;
  //       }));
  // }

  // Future<IList<T>> popAll() async {
  //   await _initWait();
  //   return _processingMutex.protect(() async => _stateMutex.protect(() async {
  //         final queue = state.asData!.value;
  //         await _setStateInner(IList<T>.empty);
  //         return queue;
  //       }));
  // }

  Future<void> _process() async {
    try {
      // Take a copy of the current queue
      // (doesn't need queue mutex because this is a sync operation)
      final toProcess = _queue;
      final processCount = toProcess.length;
      if (processCount == 0) {
        return;
      }

      // Run the processing closure
      await _closure(toProcess);

      // If there was no exception, remove the processed items
      await _queueMutex.protect(() async {
        // Get the queue from the state again as items could
        // have been added during processing
        final newQueue = _queue.skip(processCount).toIList();
        await _updateQueueInner(newQueue);
      });
    } on Exception catch (e, sp) {
      if (_onError != null) {
        _onError(e, sp);
      } else {
        rethrow;
      }
    }
  }

  IList<T> get queue => _queue;

  // TableDBBacked
  @override
  String tableKeyName() => _key;

  @override
  String tableName() => _table;

  @override
  IList<T> valueFromBuffer(Uint8List bytes) {
    var out = IList<T>();
    try {
      final reader = CodedBufferReader(bytes);
      while (!reader.isAtEnd()) {
        final bytes = reader.readBytesAsView();
        try {
          final item = _fromBuffer(bytes);
          out = out.add(item);
        } on Exception catch (e, st) {
          veilidLoggy.debug(
              'Dropping invalid item from persistent queue: $bytes\n'
              'tableName=${tableName()}:tableKeyName=${tableKeyName()}\n',
              e,
              st);
        }
      }
    } on Exception catch (e, st) {
      veilidLoggy.debug(
          'Dropping remainder of invalid persistent queue\n'
          'tableName=${tableName()}:tableKeyName=${tableKeyName()}\n',
          e,
          st);
    }
    return out;
  }

  @override
  Uint8List valueToBuffer(IList<T> val) {
    final writer = CodedBufferWriter();
    for (final elem in val) {
      writer.writeRawBytes(elem.writeToBuffer());
    }
    return writer.toBuffer();
  }

  final String _table;
  final String _key;
  final T Function(Uint8List) _fromBuffer;
  final bool _deleteOnClose;
  final WaitSet<void, void> _initWait = WaitSet();
  final Mutex _queueMutex = Mutex(debugLockTimeout: kIsDebugMode ? 60 : null);
  IList<T> _queue = IList<T>.empty();
  final StreamController<Iterable<T>> _syncAddController = StreamController();
  final StreamController<void> _queueReady = StreamController();
  final Future<void> Function(IList<T>) _closure;
  final void Function(Object, StackTrace)? _onError;
}
