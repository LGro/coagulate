import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:async_tools/async_tools.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../src/veilid_log.dart';
import '../../../veilid_support.dart';
import '../../proto/proto.dart' as proto;

part 'dht_log_spine.dart';
part 'dht_log_read.dart';
part 'dht_log_write.dart';

///////////////////////////////////////////////////////////////////////

@immutable
class DHTLogUpdate extends Equatable {
  const DHTLogUpdate(
      {required this.headDelta, required this.tailDelta, required this.length})
      : assert(headDelta >= 0, 'should never have negative head delta'),
        assert(tailDelta >= 0, 'should never have negative tail delta'),
        assert(length >= 0, 'should never have negative length');
  final int headDelta;
  final int tailDelta;
  final int length;

  @override
  List<Object?> get props => [headDelta, tailDelta, length];
}

/// DHTLog is a ring-buffer queue like data structure with the following
/// operations:
///  * Add elements to the tail
///  * Remove elements from the head
/// The structure has a 'spine' record that acts as an indirection table of
/// DHTShortArray record pointers spread over its subkeys.
/// Subkey 0 of the DHTLog is a head subkey that contains housekeeping data:
///  * The head and tail position of the log
///    - subkeyIdx = pos / recordsPerSubkey
///    - recordIdx = pos % recordsPerSubkey
class DHTLog implements DHTDeleteable<DHTLog> {
  ////////////////////////////////////////////////////////////////
  // Constructors

  DHTLog._({required _DHTLogSpine spine})
      : _spine = spine,
        _openCount = 1 {
    _spine.onUpdatedSpine = (update) {
      _watchController?.sink.add(update);
    };
  }

  /// Create a DHTLog
  static Future<DHTLog> create(
      {required String debugName,
      int stride = DHTShortArray.maxElements,
      VeilidRoutingContext? routingContext,
      TypedKey? parent,
      VeilidCrypto? crypto,
      KeyPair? writer}) async {
    assert(stride <= DHTShortArray.maxElements, 'stride too long');
    final pool = DHTRecordPool.instance;

    late final DHTRecord spineRecord;
    if (writer != null) {
      final schema = DHTSchema.smpl(
          oCnt: 0,
          members: [DHTSchemaMember(mKey: writer.key, mCnt: spineSubkeys + 1)]);
      spineRecord = await pool.createRecord(
          debugName: debugName,
          parent: parent,
          routingContext: routingContext,
          schema: schema,
          crypto: crypto,
          writer: writer);
    } else {
      const schema = DHTSchema.dflt(oCnt: spineSubkeys + 1);
      spineRecord = await pool.createRecord(
          debugName: debugName,
          parent: parent,
          routingContext: routingContext,
          schema: schema,
          crypto: crypto);
    }

    try {
      final spine = await _DHTLogSpine.create(
          spineRecord: spineRecord, segmentStride: stride);
      return DHTLog._(spine: spine);
    } on Exception catch (_) {
      await spineRecord.close();
      await spineRecord.delete();
      rethrow;
    }
  }

  static Future<DHTLog> openRead(TypedKey logRecordKey,
      {required String debugName,
      VeilidRoutingContext? routingContext,
      TypedKey? parent,
      VeilidCrypto? crypto}) async {
    final spineRecord = await DHTRecordPool.instance.openRecordRead(
        logRecordKey,
        debugName: debugName,
        parent: parent,
        routingContext: routingContext,
        crypto: crypto);
    try {
      final spine = await _DHTLogSpine.load(spineRecord: spineRecord);
      final dhtLog = DHTLog._(spine: spine);
      return dhtLog;
    } on Exception catch (_) {
      await spineRecord.close();
      rethrow;
    }
  }

  static Future<DHTLog> openWrite(
    TypedKey logRecordKey,
    KeyPair writer, {
    required String debugName,
    VeilidRoutingContext? routingContext,
    TypedKey? parent,
    VeilidCrypto? crypto,
  }) async {
    final spineRecord = await DHTRecordPool.instance.openRecordWrite(
        logRecordKey, writer,
        debugName: debugName,
        parent: parent,
        routingContext: routingContext,
        crypto: crypto);
    try {
      final spine = await _DHTLogSpine.load(spineRecord: spineRecord);
      final dhtLog = DHTLog._(spine: spine);
      return dhtLog;
    } on Exception catch (_) {
      await spineRecord.close();
      rethrow;
    }
  }

  static Future<DHTLog> openOwned(
    OwnedDHTRecordPointer ownedLogRecordPointer, {
    required String debugName,
    required TypedKey parent,
    VeilidRoutingContext? routingContext,
    VeilidCrypto? crypto,
  }) =>
      openWrite(
        ownedLogRecordPointer.recordKey,
        ownedLogRecordPointer.owner,
        debugName: debugName,
        routingContext: routingContext,
        parent: parent,
        crypto: crypto,
      );

  ////////////////////////////////////////////////////////////////////////////
  // DHTCloseable

  /// Check if the DHTLog is open
  @override
  bool get isOpen => _openCount > 0;

  /// The type of the openable scope
  @override
  FutureOr<DHTLog> scoped() => this;

  /// Add a reference to this log
  @override
  void ref() {
    _openCount++;
  }

  /// Free all resources for the DHTLog
  @override
  Future<bool> close() async {
    if (_openCount == 0) {
      throw StateError('already closed');
    }
    _openCount--;
    if (_openCount != 0) {
      return false;
    }
    //
    await _watchController?.close();
    _watchController = null;
    await _spine.close();
    return true;
  }

  /// Free all resources for the DHTLog and delete it from the DHT
  /// Will wait until the short array is closed to delete it
  @override
  Future<bool> delete() => _spine.delete();

  ////////////////////////////////////////////////////////////////////////////
  // Public API

  /// Get the record key for this log
  TypedKey get recordKey => _spine.recordKey;

  /// Get the writer for the log
  KeyPair? get writer => _spine._spineRecord.writer;

  /// Get the record pointer foir this log
  OwnedDHTRecordPointer get recordPointer => _spine.recordPointer;

  /// Runs a closure allowing read-only access to the log
  Future<T> operate<T>(Future<T> Function(DHTLogReadOperations) closure) async {
    if (!isOpen) {
      throw StateError('log is not open');
    }

    return _spine.operate((spine) async {
      final reader = _DHTLogRead._(spine);
      return closure(reader);
    });
  }

  /// Runs a closure allowing append/truncate access to the log
  /// Makes only one attempt to consistently write the changes to the DHT
  /// Returns result of the closure if the write could be performed
  /// Throws DHTOperateException if the write could not be performed
  /// at this time
  Future<T> operateAppend<T>(
      Future<T> Function(DHTLogWriteOperations) closure) async {
    if (!isOpen) {
      throw StateError('log is not open');
    }

    return _spine.operateAppend((spine) async {
      final writer = _DHTLogWrite._(spine);
      return closure(writer);
    });
  }

  /// Runs a closure allowing append/truncate access to the log
  /// Will execute the closure multiple times if a consistent write to the DHT
  /// is not achieved. Timeout if specified will be thrown as a
  /// TimeoutException. The closure should return a value if its changes also
  /// succeeded, and throw DHTExceptionTryAgain to trigger another
  /// eventual consistency pass.
  Future<T> operateAppendEventual<T>(
      Future<T> Function(DHTLogWriteOperations) closure,
      {Duration? timeout}) async {
    if (!isOpen) {
      throw StateError('log is not open');
    }

    return _spine.operateAppendEventual((spine) async {
      final writer = _DHTLogWrite._(spine);
      return closure(writer);
    }, timeout: timeout);
  }

  /// Listen to and any all changes to the structure of this log
  /// regardless of where the changes are coming from
  Future<StreamSubscription<void>> listen(
    void Function(DHTLogUpdate) onChanged,
  ) {
    if (!isOpen) {
      throw StateError('log is not open');
    }

    return _listenMutex.protect(() async {
      // If don't have a controller yet, set it up
      if (_watchController == null) {
        // Set up watch requirements
        _watchController =
            StreamController<DHTLogUpdate>.broadcast(onCancel: () {
          // If there are no more listeners then we can get
          // rid of the controller and drop our subscriptions
          unawaited(_listenMutex.protect(() async {
            // Cancel watches of head record
            await _spine.cancelWatch();
            _watchController = null;
          }));
        });

        // Start watching head subkey of the spine
        await _spine.watch();
      }
      // Return subscription
      return _watchController!.stream.listen((upd) => onChanged(upd));
    });
  }

  ////////////////////////////////////////////////////////////////
  // Fields

  // 55 subkeys * 512 segments * 36 bytes per typedkey =
  //   1013760 bytes per record
  // Leaves 34816 bytes for 0th subkey as head, 56 subkeys total
  // 512*36 = 18432 bytes per subkey
  // 28160 shortarrays * 256 elements = 7208960 elements
  static const spineSubkeys = 55;
  static const segmentsPerSubkey = 512;

  // Internal representation refreshed from spine record
  final _DHTLogSpine _spine;

  // Openable
  int _openCount;

  // Watch mutex to ensure we keep the representation valid
  final Mutex _listenMutex = Mutex(debugLockTimeout: kIsDebugMode ? 60 : null);
  // Stream of external changes
  StreamController<DHTLogUpdate>? _watchController;
}
