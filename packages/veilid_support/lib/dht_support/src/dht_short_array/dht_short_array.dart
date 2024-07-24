import 'dart:async';
import 'dart:typed_data';

import 'package:async_tools/async_tools.dart';
import 'package:collection/collection.dart';

import '../../../veilid_support.dart';
import '../../proto/proto.dart' as proto;

part 'dht_short_array_head.dart';
part 'dht_short_array_read.dart';
part 'dht_short_array_write.dart';

///////////////////////////////////////////////////////////////////////

class DHTShortArray implements DHTDeleteable<DHTShortArray> {
  ////////////////////////////////////////////////////////////////
  // Constructors

  DHTShortArray._({required DHTRecord headRecord})
      : _head = _DHTShortArrayHead(headRecord: headRecord),
        _openCount = 1 {
    _head.onUpdatedHead = () {
      _watchController?.sink.add(null);
    };
  }

  // Create a DHTShortArray
  // if smplWriter is specified, uses a SMPL schema with a single writer
  // rather than the key owner
  static Future<DHTShortArray> create(
      {required String debugName,
      int stride = maxElements,
      VeilidRoutingContext? routingContext,
      TypedKey? parent,
      VeilidCrypto? crypto,
      KeyPair? writer}) async {
    assert(stride <= maxElements, 'stride too long');
    final pool = DHTRecordPool.instance;

    late final DHTRecord dhtRecord;
    if (writer != null) {
      final schema = DHTSchema.smpl(
          oCnt: 0,
          members: [DHTSchemaMember(mKey: writer.key, mCnt: stride + 1)]);
      dhtRecord = await pool.createRecord(
          debugName: debugName,
          parent: parent,
          routingContext: routingContext,
          schema: schema,
          crypto: crypto,
          writer: writer);
    } else {
      final schema = DHTSchema.dflt(oCnt: stride + 1);
      dhtRecord = await pool.createRecord(
          debugName: debugName,
          parent: parent,
          routingContext: routingContext,
          schema: schema,
          crypto: crypto);
    }

    try {
      final dhtShortArray = DHTShortArray._(headRecord: dhtRecord);
      await dhtShortArray._head.operate((head) async {
        if (!await head._writeHead()) {
          throw StateError('Failed to write head at this time');
        }
      });
      return dhtShortArray;
    } on Exception catch (_) {
      await dhtRecord.close();
      await pool.deleteRecord(dhtRecord.key);
      rethrow;
    }
  }

  static Future<DHTShortArray> openRead(TypedKey headRecordKey,
      {required String debugName,
      VeilidRoutingContext? routingContext,
      TypedKey? parent,
      VeilidCrypto? crypto}) async {
    final dhtRecord = await DHTRecordPool.instance.openRecordRead(headRecordKey,
        debugName: debugName,
        parent: parent,
        routingContext: routingContext,
        crypto: crypto);
    try {
      final dhtShortArray = DHTShortArray._(headRecord: dhtRecord);
      await dhtShortArray._head.operate((head) => head._loadHead());
      return dhtShortArray;
    } on Exception catch (_) {
      await dhtRecord.close();
      rethrow;
    }
  }

  static Future<DHTShortArray> openWrite(
    TypedKey headRecordKey,
    KeyPair writer, {
    required String debugName,
    VeilidRoutingContext? routingContext,
    TypedKey? parent,
    VeilidCrypto? crypto,
  }) async {
    final dhtRecord = await DHTRecordPool.instance.openRecordWrite(
        headRecordKey, writer,
        debugName: debugName,
        parent: parent,
        routingContext: routingContext,
        crypto: crypto);
    try {
      final dhtShortArray = DHTShortArray._(headRecord: dhtRecord);
      await dhtShortArray._head.operate((head) => head._loadHead());
      return dhtShortArray;
    } on Exception catch (_) {
      await dhtRecord.close();
      rethrow;
    }
  }

  static Future<DHTShortArray> openOwned(
    OwnedDHTRecordPointer ownedShortArrayRecordPointer, {
    required String debugName,
    required TypedKey parent,
    VeilidRoutingContext? routingContext,
    VeilidCrypto? crypto,
  }) =>
      openWrite(
        ownedShortArrayRecordPointer.recordKey,
        ownedShortArrayRecordPointer.owner,
        debugName: debugName,
        routingContext: routingContext,
        parent: parent,
        crypto: crypto,
      );

  ////////////////////////////////////////////////////////////////////////////
  // DHTCloseable

  /// Check if the shortarray is open
  @override
  bool get isOpen => _openCount > 0;

  /// The type of the openable scope
  @override
  FutureOr<DHTShortArray> scoped() => this;

  /// Add a reference to this shortarray
  @override
  Future<void> ref() async => _mutex.protect(() async {
        _openCount++;
      });

  /// Free all resources for the DHTShortArray
  @override
  Future<bool> close() async => _mutex.protect(() async {
        if (_openCount == 0) {
          throw StateError('already closed');
        }
        _openCount--;
        if (_openCount != 0) {
          return false;
        }

        await _watchController?.close();
        _watchController = null;
        await _head.close();
        return true;
      });

  /// Free all resources for the DHTShortArray and delete it from the DHT
  /// Will wait until the short array is closed to delete it
  @override
  Future<void> delete() async {
    await _head.delete();
  }

  ////////////////////////////////////////////////////////////////////////////
  // Public API

  /// Get the record key for this shortarray
  TypedKey get recordKey => _head.recordKey;

  /// Get the writer for the log
  KeyPair? get writer => _head._headRecord.writer;

  /// Get the record pointer foir this shortarray
  OwnedDHTRecordPointer get recordPointer => _head.recordPointer;

  /// Refresh this DHTShortArray
  /// Useful if you aren't 'watching' the array and want to poll for an update
  Future<void> refresh() async {
    if (!isOpen) {
      throw StateError('short array is not open"');
    }
    await _head.operate((head) async {
      await head._loadHead();
    });
  }

  /// Runs a closure allowing read-only access to the shortarray
  Future<T> operate<T>(
      Future<T> Function(DHTShortArrayReadOperations) closure) async {
    if (!isOpen) {
      throw StateError('short array is not open"');
    }

    return _head.operate((head) async {
      final reader = _DHTShortArrayRead._(head);
      return closure(reader);
    });
  }

  /// Runs a closure allowing read-write access to the shortarray
  /// Makes only one attempt to consistently write the changes to the DHT
  /// Returns result of the closure if the write could be performed
  /// Throws DHTOperateException if the write could not be performed
  /// at this time
  Future<T> operateWrite<T>(
      Future<T> Function(DHTShortArrayWriteOperations) closure) async {
    if (!isOpen) {
      throw StateError('short array is not open"');
    }

    return _head.operateWrite((head) async {
      final writer = _DHTShortArrayWrite._(head);
      return closure(writer);
    });
  }

  /// Runs a closure allowing read-write access to the shortarray
  /// Will execute the closure multiple times if a consistent write to the DHT
  /// is not achieved. Timeout if specified will be thrown as a
  /// TimeoutException. The closure should return a value if its changes also
  /// succeeded, and throw DHTExceptionTryAgain to trigger another
  /// eventual consistency pass.
  Future<T> operateWriteEventual<T>(
      Future<T> Function(DHTShortArrayWriteOperations) closure,
      {Duration? timeout}) async {
    if (!isOpen) {
      throw StateError('short array is not open"');
    }

    return _head.operateWriteEventual((head) async {
      final writer = _DHTShortArrayWrite._(head);
      return closure(writer);
    }, timeout: timeout);
  }

  /// Listen to and any all changes to the structure of this short array
  /// regardless of where the changes are coming from
  Future<StreamSubscription<void>> listen(
    void Function() onChanged,
  ) {
    if (!isOpen) {
      throw StateError('short array is not open"');
    }

    return _listenMutex.protect(() async {
      // If don't have a controller yet, set it up
      if (_watchController == null) {
        // Set up watch requirements
        _watchController = StreamController<void>.broadcast(onCancel: () {
          // If there are no more listeners then we can get
          // rid of the controller and drop our subscriptions
          unawaited(_listenMutex.protect(() async {
            // Cancel watches of head record
            await _head.cancelWatch();
            _watchController = null;
          }));
        });

        // Start watching head record
        await _head.watch();
      }
      // Return subscription
      return _watchController!.stream.listen((_) => onChanged());
    });
  }

  ////////////////////////////////////////////////////////////////
  // Fields

  static const maxElements = 256;

  // Internal representation refreshed from head record
  final _DHTShortArrayHead _head;

  // Openable
  int _openCount;
  final _mutex = Mutex();

  // Watch mutex to ensure we keep the representation valid
  final Mutex _listenMutex = Mutex();
  // Stream of external changes
  StreamController<void>? _watchController;
}
