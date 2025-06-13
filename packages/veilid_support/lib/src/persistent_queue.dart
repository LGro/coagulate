import 'dart:async';
import 'dart:typed_data';

import 'package:async_tools/async_tools.dart';
import 'package:buffer/buffer.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import 'config.dart';
import 'table_db.dart';
import 'veilid_log.dart';

const _ksfSyncAdd = 'ksfSyncAdd';

class PersistentQueue<T> with TableDBBackedFromBuffer<IList<T>> {
  //
  PersistentQueue(
      {required String table,
      required String key,
      required T Function(Uint8List) fromBuffer,
      required Uint8List Function(T) toBuffer,
      required Future<void> Function(IList<T>) closure,
      bool deleteOnClose = false,
      void Function(Object, StackTrace)? onError})
      : _table = table,
        _key = key,
        _fromBuffer = fromBuffer,
        _toBuffer = toBuffer,
        _closure = closure,
        _deleteOnClose = deleteOnClose,
        _onError = onError {
    _initWait.add(_init);
  }

  Future<void> close() async {
    // Ensure the init finished
    await _initWait();

    // Finish all sync adds
    await serialFutureClose((this, _ksfSyncAdd));

    // Stop the processing trigger
    await _sspQueueReady.close();
    await _queueReady.close();

    // No more queue actions
    await _queueMutex.acquire();

    // Clean up table if desired
    if (_deleteOnClose) {
      await delete();
    }
  }

  set deleteOnClose(bool d) {
    _deleteOnClose = d;
  }

  bool get deleteOnClose => _deleteOnClose;

  Future<void> get waitEmpty async {
    // Ensure the init finished
    await _initWait();

    if (_queue.isEmpty) {
      return;
    }
    final completer = Completer<void>();
    _queueDoneCompleter = completer;
    await completer.future;
  }

  Future<void> _init(Completer<void> _) async {
    // Start the processor
    _sspQueueReady.follow(_queueReady.stream, true, (more) async {
      await _initWait();
      if (more) {
        await _process();
      }
    });

    // Load the queue if we have one
    try {
      await _queueMutex.protect(() async {
        _queue = await load() ?? await store(IList<T>.empty());
        _sendUpdateEventsInner();
      });
    } on Exception catch (e, st) {
      if (_onError != null) {
        _onError(e, st);
      } else {
        rethrow;
      }
    }
  }

  void _sendUpdateEventsInner() {
    assert(_queueMutex.isLocked, 'must be locked');
    if (_queue.isNotEmpty) {
      if (!_queueReady.isClosed) {
        _queueReady.sink.add(true);
      }
    } else {
      _queueDoneCompleter?.complete();
    }
  }

  Future<void> _updateQueueInner(IList<T> newQueue) async {
    _queue = await store(newQueue);
    _sendUpdateEventsInner();
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
    serialFuture((this, _ksfSyncAdd), () async {
      await add(item);
    });
  }

  void addAllSync(Iterable<T> items) {
    serialFuture((this, _ksfSyncAdd), () async {
      await addAll(items);
    });
  }

  Future<void> pause() async {
    await _sspQueueReady.pause();
  }

  Future<void> resume() async {
    await _sspQueueReady.resume();
  }

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
      final reader = ByteDataReader()..add(bytes);
      while (reader.remainingLength != 0) {
        final count = reader.readUint32();
        final bytes = reader.read(count);
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
    final writer = ByteDataWriter();
    for (final elem in val) {
      final bytes = _toBuffer(elem);
      final count = bytes.lengthInBytes;
      writer
        ..writeUint32(count)
        ..write(bytes);
    }
    return writer.toBytes();
  }

  final String _table;
  final String _key;
  final T Function(Uint8List) _fromBuffer;
  final Uint8List Function(T) _toBuffer;
  bool _deleteOnClose;
  final WaitSet<void, void> _initWait = WaitSet();
  final _queueMutex = Mutex(debugLockTimeout: kIsDebugMode ? 60 : null);
  var _queue = IList<T>.empty();
  final Future<void> Function(IList<T>) _closure;
  final void Function(Object, StackTrace)? _onError;
  Completer<void>? _queueDoneCompleter;

  final StreamController<bool> _queueReady = StreamController();
  final _sspQueueReady = SingleStateProcessor<bool>();
}
