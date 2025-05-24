import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:async_tools/async_tools.dart';
import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:protobuf/protobuf.dart';

import '../../../../veilid_support.dart';
import 'extensions.dart';

export 'package:fast_immutable_collections/fast_immutable_collections.dart'
    show Output;

part 'dht_record_pool.freezed.dart';
part 'dht_record_pool.g.dart';
part 'dht_record.dart';
part 'dht_record_pool_private.dart';

/// Maximum number of concurrent DHT operations to perform on the network
const int kMaxDHTConcurrency = 8;

/// Total number of times to try in a 'VeilidAPIExceptionKeyNotFound' loop
const int kDHTKeyNotFoundTries = 3;

/// Total number of times to try in a 'VeilidAPIExceptionTryAgain' loop
const int kDHTTryAgainTries = 3;

typedef DHTRecordPoolLogger = void Function(String message);

/// Record pool that managed DHTRecords and allows for tagged deletion
/// String versions of keys due to IMap<> json unsupported in key
@freezed
sealed class DHTRecordPoolAllocations with _$DHTRecordPoolAllocations {
  const factory DHTRecordPoolAllocations({
    @Default(IMapConst<String, ISet<TypedKey>>({}))
    IMap<String, ISet<TypedKey>> childrenByParent,
    @Default(IMapConst<String, TypedKey>({}))
    IMap<String, TypedKey> parentByChild,
    @Default(ISetConst<TypedKey>({})) ISet<TypedKey> rootRecords,
    @Default(IMapConst<String, String>({})) IMap<String, String> debugNames,
  }) = _DHTRecordPoolAllocations;

  factory DHTRecordPoolAllocations.fromJson(dynamic json) =>
      _$DHTRecordPoolAllocationsFromJson(json as Map<String, dynamic>);
}

/// Pointer to an owned record, with key, owner key and owner secret
/// Ensure that these are only serialized encrypted
@freezed
sealed class OwnedDHTRecordPointer with _$OwnedDHTRecordPointer {
  const factory OwnedDHTRecordPointer({
    required TypedKey recordKey,
    required KeyPair owner,
  }) = _OwnedDHTRecordPointer;

  factory OwnedDHTRecordPointer.fromJson(dynamic json) =>
      _$OwnedDHTRecordPointerFromJson(json as Map<String, dynamic>);
}

//////////////////////////////////////////////////////////////////////////////

/// Allocator and management system for DHTRecord
class DHTRecordPool with TableDBBackedJson<DHTRecordPoolAllocations> {
  DHTRecordPool._(Veilid veilid, VeilidRoutingContext routingContext)
      : _state = const DHTRecordPoolAllocations(),
        _mutex = Mutex(debugLockTimeout: kIsDebugMode ? 60 : null),
        _recordTagLock = AsyncTagLock(),
        _opened = <TypedKey, _OpenedRecordInfo>{},
        _markedForDelete = <TypedKey>{},
        _routingContext = routingContext,
        _veilid = veilid;

  //////////////////////////////////////////////////////////////

  static DHTRecordPool get instance => _singleton!;

  static Future<void> init({DHTRecordPoolLogger? logger}) async {
    final routingContext = await Veilid.instance.routingContext();
    final globalPool = DHTRecordPool._(Veilid.instance, routingContext);
    globalPool
      .._logger = logger
      .._state = await globalPool.load() ?? const DHTRecordPoolAllocations();
    _singleton = globalPool;
  }

  static Future<void> close() async {
    if (_singleton != null) {
      _singleton!._routingContext.close();
      _singleton = null;
    }
  }

  ////////////////////////////////////////////////////////////////////////////
  // Public Interface

  /// Create a root DHTRecord that has no dependent records
  Future<DHTRecord> createRecord({
    required String debugName,
    VeilidRoutingContext? routingContext,
    TypedKey? parent,
    DHTSchema schema = const DHTSchema.dflt(oCnt: 1),
    int defaultSubkey = 0,
    VeilidCrypto? crypto,
    KeyPair? writer,
  }) async =>
      _mutex.protect(() async {
        final dhtctx = routingContext ?? _routingContext;

        final openedRecordInfo = await _recordCreateInner(
            debugName: debugName,
            dhtctx: dhtctx,
            schema: schema,
            writer: writer,
            parent: parent);

        final rec = DHTRecord._(
            debugName: debugName,
            routingContext: dhtctx,
            defaultSubkey: defaultSubkey,
            sharedDHTRecordData: openedRecordInfo.shared,
            writer: writer ??
                openedRecordInfo.shared.recordDescriptor.ownerKeyPair(),
            crypto: crypto ??
                await privateCryptoFromTypedSecret(openedRecordInfo
                    .shared.recordDescriptor
                    .ownerTypedSecret()!));

        openedRecordInfo.records.add(rec);

        return rec;
      });

  /// Open a DHTRecord readonly
  Future<DHTRecord> openRecordRead(TypedKey recordKey,
          {required String debugName,
          VeilidRoutingContext? routingContext,
          TypedKey? parent,
          int defaultSubkey = 0,
          VeilidCrypto? crypto}) async =>
      _recordTagLock.protect(recordKey, closure: () async {
        final dhtctx = routingContext ?? _routingContext;

        final rec = await _recordOpenCommon(
            debugName: debugName,
            dhtctx: dhtctx,
            recordKey: recordKey,
            crypto: crypto ?? const VeilidCryptoPublic(),
            writer: null,
            parent: parent,
            defaultSubkey: defaultSubkey);

        return rec;
      });

  /// Open a DHTRecord writable
  Future<DHTRecord> openRecordWrite(
    TypedKey recordKey,
    KeyPair writer, {
    required String debugName,
    VeilidRoutingContext? routingContext,
    TypedKey? parent,
    int defaultSubkey = 0,
    VeilidCrypto? crypto,
  }) async =>
      _recordTagLock.protect(recordKey, closure: () async {
        final dhtctx = routingContext ?? _routingContext;

        final rec = await _recordOpenCommon(
          debugName: debugName,
          dhtctx: dhtctx,
          recordKey: recordKey,
          crypto: crypto ??
              await privateCryptoFromTypedSecret(
                  TypedKey(kind: recordKey.kind, value: writer.secret)),
          writer: writer,
          parent: parent,
          defaultSubkey: defaultSubkey,
        );

        return rec;
      });

  /// Open a DHTRecord owned
  /// This is the same as writable but uses an OwnedDHTRecordPointer
  /// for convenience and uses symmetric encryption on the key
  /// This is primarily used for backing up private content on to the DHT
  /// to synchronizing it between devices. Because it is 'owned', the correct
  /// parent must be specified.
  Future<DHTRecord> openRecordOwned(
    OwnedDHTRecordPointer ownedDHTRecordPointer, {
    required String debugName,
    required TypedKey parent,
    VeilidRoutingContext? routingContext,
    int defaultSubkey = 0,
    VeilidCrypto? crypto,
  }) =>
      openRecordWrite(
        ownedDHTRecordPointer.recordKey,
        ownedDHTRecordPointer.owner,
        debugName: debugName,
        routingContext: routingContext,
        parent: parent,
        defaultSubkey: defaultSubkey,
        crypto: crypto,
      );

  /// Get the parent of a DHTRecord key if it exists
  Future<TypedKey?> getParentRecordKey(TypedKey child) =>
      _mutex.protect(() async => _getParentRecordKeyInner(child));

  /// Check if record is allocated
  Future<bool> isValidRecordKey(TypedKey key) =>
      _mutex.protect(() async => _isValidRecordKeyInner(key));

  /// Check if record is marked for deletion or already gone
  Future<bool> isDeletedRecordKey(TypedKey key) =>
      _mutex.protect(() async => _isDeletedRecordKeyInner(key));

  /// Delete a record and its children if they are all closed
  /// otherwise mark that record for deletion eventually
  /// Returns true if the deletion was processed immediately
  /// Returns false if the deletion was marked for later
  Future<bool> deleteRecord(TypedKey recordKey) async =>
      _mutex.protect(() async => _deleteRecordInner(recordKey));

  // If everything underneath is closed including itself, return the
  // list of children (and itself) to finally actually delete
  List<TypedKey> _readyForDeleteInner(TypedKey recordKey) {
    final allDeps = _collectChildrenInner(recordKey);
    for (final dep in allDeps) {
      if (_opened.containsKey(dep)) {
        return [];
      }
    }
    return allDeps;
  }

  /// Collect all dependencies (including the record itself)
  /// in reverse (bottom-up/delete order)
  Future<List<TypedKey>> collectChildren(TypedKey recordKey) =>
      _mutex.protect(() async => _collectChildrenInner(recordKey));

  /// Print children
  String debugChildren(TypedKey recordKey, {List<TypedKey>? allDeps}) {
    allDeps ??= _collectChildrenInner(recordKey);
    // Debugging
    // ignore: avoid_print
    var out =
        'Parent: $recordKey (${_state.debugNames[recordKey.toString()]})\n';
    for (final dep in allDeps) {
      if (dep != recordKey) {
        // Debugging
        // ignore: avoid_print
        out += '  Child: $dep (${_state.debugNames[dep.toString()]})\n';
      }
    }
    return out;
  }

  /// Handle the DHT record updates coming from Veilid
  void processRemoteValueChange(VeilidUpdateValueChange updateValueChange) {
    if (updateValueChange.subkeys.isNotEmpty && updateValueChange.count != 0) {
      // Change
      for (final kv in _opened.entries) {
        if (kv.key == updateValueChange.key) {
          for (final rec in kv.value.records) {
            rec._addRemoteValueChange(updateValueChange);
          }
          break;
        }
      }
    }
  }

  /// Log the current record allocations
  void debugPrintAllocations() {
    final sortedAllocations = _state.debugNames.entries.asList()
      ..sort((a, b) => a.key.compareTo(b.key));

    log('DHTRecordPool Allocations: (count=${sortedAllocations.length})');

    for (final entry in sortedAllocations) {
      log('  ${entry.key}: ${entry.value}');
    }
  }

  /// Log the current opened record details
  void debugPrintOpened() {
    final sortedOpened = _opened.entries.asList()
      ..sort((a, b) => a.key.toString().compareTo(b.key.toString()));

    log('DHTRecordPool Opened Records: (count=${sortedOpened.length})');

    for (final entry in sortedOpened) {
      log('  ${entry.key}: \n'
          '     debugNames=${entry.value.debugNames}\n'
          '     details=${entry.value.details}\n'
          '     sharedDetails=${entry.value.sharedDetails}\n');
    }
  }

  /// Log the performance stats
  void debugPrintStats() {
    log('DHTRecordPool Stats:\n${_stats.debugString()}');
  }

  /// Public interface to DHTRecordPool logger
  void log(String message) {
    _logger?.call(message);
  }

  /// Generate default VeilidCrypto for a writer
  static Future<VeilidCrypto> privateCryptoFromTypedSecret(
          TypedKey typedSecret) async =>
      VeilidCryptoPrivate.fromTypedKey(typedSecret, _cryptoDomainDHT);

  ////////////////////////////////////////////////////////////////////////////
  // Private Implementation

  Future<_OpenedRecordInfo> _recordCreateInner(
      {required String debugName,
      required VeilidRoutingContext dhtctx,
      required DHTSchema schema,
      KeyPair? writer,
      TypedKey? parent}) async {
    if (!_mutex.isLocked) {
      throw StateError('should be locked here');
    }
    // Create the record
    final recordDescriptor = await dhtctx.createDHTRecord(schema);

    log('createDHTRecord: debugName=$debugName key=${recordDescriptor.key}');

    // Reopen if a writer is specified to ensure
    // we switch the default writer
    if (writer != null) {
      await dhtctx.openDHTRecord(recordDescriptor.key, writer: writer);
    }
    final openedRecordInfo = _OpenedRecordInfo(
        recordDescriptor: recordDescriptor,
        defaultWriter: writer ?? recordDescriptor.ownerKeyPair(),
        defaultRoutingContext: dhtctx);
    _opened[recordDescriptor.key] = openedRecordInfo;

    // Register the dependency
    await _addDependencyInner(
      parent,
      recordDescriptor.key,
      debugName: debugName,
    );

    return openedRecordInfo;
  }

  Future<DHTRecord> _recordOpenCommon(
          {required String debugName,
          required VeilidRoutingContext dhtctx,
          required TypedKey recordKey,
          required VeilidCrypto crypto,
          required KeyPair? writer,
          required TypedKey? parent,
          required int defaultSubkey}) async =>
      _stats.measure(recordKey, debugName, '_recordOpenCommon', () async {
        log('openDHTRecord: debugName=$debugName key=$recordKey');

        // See if this has been opened yet
        final openedRecordInfo = await _mutex.protect(() async {
          // If we are opening a key that already exists
          // make sure we are using the same parent if one was specified
          _validateParentInner(parent, recordKey);

          return _opened[recordKey];
        });

        if (openedRecordInfo == null) {
          // Fresh open, just open the record
          var retry = kDHTKeyNotFoundTries;
          late final DHTRecordDescriptor recordDescriptor;
          while (true) {
            try {
              recordDescriptor =
                  await dhtctx.openDHTRecord(recordKey, writer: writer);
              break;
            } on VeilidAPIExceptionTryAgain {
              throw const DHTExceptionNotAvailable();
            } on VeilidAPIExceptionKeyNotFound {
              await asyncSleep();
              retry--;
              if (retry == 0) {
                throw const DHTExceptionNotAvailable();
              }
            }
          }

          final newOpenedRecordInfo = _OpenedRecordInfo(
              recordDescriptor: recordDescriptor,
              defaultWriter: writer,
              defaultRoutingContext: dhtctx);

          final rec = DHTRecord._(
              debugName: debugName,
              routingContext: dhtctx,
              defaultSubkey: defaultSubkey,
              sharedDHTRecordData: newOpenedRecordInfo.shared,
              writer: writer,
              crypto: crypto);

          await _mutex.protect(() async {
            // Register the opened record
            _opened[recordDescriptor.key] = newOpenedRecordInfo;

            // Register the dependency
            await _addDependencyInner(
              parent,
              recordKey,
              debugName: debugName,
            );

            // Register the newly opened record
            newOpenedRecordInfo.records.add(rec);
          });

          return rec;
        }

        // Already opened

        // See if we need to reopen the record with a default writer and possibly
        // a different routing context
        if (writer != null && openedRecordInfo.shared.defaultWriter == null) {
          await dhtctx.openDHTRecord(recordKey, writer: writer);
          // New writer if we didn't specify one before
          openedRecordInfo.shared.defaultWriter = writer;
          // New default routing context if we opened it again
          openedRecordInfo.shared.defaultRoutingContext = dhtctx;
        }

        final rec = DHTRecord._(
            debugName: debugName,
            routingContext: dhtctx,
            defaultSubkey: defaultSubkey,
            sharedDHTRecordData: openedRecordInfo.shared,
            writer: writer,
            crypto: crypto);

        await _mutex.protect(() async {
          // Register the dependency
          await _addDependencyInner(
            parent,
            recordKey,
            debugName: debugName,
          );

          openedRecordInfo.records.add(rec);
        });

        return rec;
      });

  // Called when a DHTRecord is closed
  // Cleans up the opened record housekeeping and processes any late deletions
  Future<void> _recordClosed(DHTRecord record) async {
    final key = record.key;
    await _recordTagLock.protect(key, closure: () async {
      await _mutex.protect(() async {
        log('closeDHTRecord: debugName=${record.debugName} key=$key');

        final openedRecordInfo = _opened[key];
        if (openedRecordInfo == null ||
            !openedRecordInfo.records.remove(record)) {
          throw StateError('record already closed');
        }
        if (openedRecordInfo.records.isNotEmpty) {
          return;
        }
        _opened.remove(key);
        await _routingContext.closeDHTRecord(key);
        await _checkForLateDeletesInner(key);
      });

      // This happens after the mutex is released
      // because the record has already been removed from _opened
      // which means that updates to the state processor won't happen
      await _watchStateProcessors.remove(key);
    });
  }

  // Check to see if this key can finally be deleted
  // If any parents are marked for deletion, try them first
  Future<void> _checkForLateDeletesInner(TypedKey key) async {
    if (!_mutex.isLocked) {
      throw StateError('should be locked here');
    }

    // Get parent list in bottom up order including our own key
    final parents = <TypedKey>[];
    TypedKey? nextParent = key;
    while (nextParent != null) {
      parents.add(nextParent);
      nextParent = _getParentRecordKeyInner(nextParent);
    }

    // If any parent is ready to delete all its children do it
    for (final parent in parents) {
      if (_markedForDelete.contains(parent)) {
        final deleted = await _deleteRecordInner(parent);
        if (!deleted) {
          // If we couldn't delete a child then no 'marked for delete' parents
          // above us will be ready to delete either
          break;
        }
      }
    }
  }

  // Collect all dependencies (including the record itself)
  // in reverse (bottom-up/delete order)
  List<TypedKey> _collectChildrenInner(TypedKey recordKey) {
    if (!_mutex.isLocked) {
      throw StateError('should be locked here');
    }
    final allDeps = <TypedKey>[];
    final currentDeps = [recordKey];
    while (currentDeps.isNotEmpty) {
      final nextDep = currentDeps.removeLast();

      allDeps.add(nextDep);
      final childDeps =
          _state.childrenByParent[nextDep.toJson()]?.toList() ?? [];
      currentDeps.addAll(childDeps);
    }
    return allDeps.reversedView;
  }

  // Actual delete function
  Future<void> _finalizeDeleteRecordInner(TypedKey recordKey) async {
    if (!_mutex.isLocked) {
      throw StateError('should be locked here');
    }

    log('_finalizeDeleteRecordInner: key=$recordKey');

    // Remove this child from parents
    await _removeDependenciesInner([recordKey]);
    await _routingContext.deleteDHTRecord(recordKey);
    _markedForDelete.remove(recordKey);
  }

  // Deep delete mechanism inside mutex
  Future<bool> _deleteRecordInner(TypedKey recordKey) async {
    if (!_mutex.isLocked) {
      throw StateError('should be locked here');
    }

    final toDelete = _readyForDeleteInner(recordKey);
    if (toDelete.isNotEmpty) {
      // delete now
      for (final deleteKey in toDelete) {
        await _finalizeDeleteRecordInner(deleteKey);
      }
      return true;
    }
    // mark for deletion
    _markedForDelete.add(recordKey);
    return false;
  }

  void _validateParentInner(TypedKey? parent, TypedKey child) {
    if (!_mutex.isLocked) {
      throw StateError('should be locked here');
    }

    final childJson = child.toJson();
    final existingParent = _state.parentByChild[childJson];
    if (parent == null) {
      if (existingParent != null) {
        throw StateError('Child is already parented: $child');
      }
    } else {
      if (_state.rootRecords.contains(child)) {
        throw StateError('Child already added as root: $child');
      }
      if (existingParent != null && existingParent != parent) {
        throw StateError('Child has two parents: $child <- $parent');
      }
    }
  }

  Future<void> _addDependencyInner(TypedKey? parent, TypedKey child,
      {required String debugName}) async {
    if (!_mutex.isLocked) {
      throw StateError('should be locked here');
    }
    if (parent == null) {
      if (_state.rootRecords.contains(child)) {
        // Dependency already added
        return;
      }
      _state = await store(_state.copyWith(
          rootRecords: _state.rootRecords.add(child),
          debugNames: _state.debugNames.add(child.toJson(), debugName)));
    } else {
      final childrenOfParent =
          _state.childrenByParent[parent.toJson()] ?? ISet<TypedKey>();
      if (childrenOfParent.contains(child)) {
        // Dependency already added (consecutive opens, etc)
        return;
      }
      _state = await store(_state.copyWith(
          childrenByParent: _state.childrenByParent
              .add(parent.toJson(), childrenOfParent.add(child)),
          parentByChild: _state.parentByChild.add(child.toJson(), parent),
          debugNames: _state.debugNames.add(child.toJson(), debugName)));
    }
  }

  Future<void> _removeDependenciesInner(List<TypedKey> childList) async {
    if (!_mutex.isLocked) {
      throw StateError('should be locked here');
    }
    var state = _state;

    for (final child in childList) {
      if (_state.rootRecords.contains(child)) {
        state = state.copyWith(
            rootRecords: state.rootRecords.remove(child),
            debugNames: state.debugNames.remove(child.toJson()));
      } else {
        final parent = state.parentByChild[child.toJson()];
        if (parent == null) {
          continue;
        }
        final children = state.childrenByParent[parent.toJson()]!.remove(child);
        if (children.isEmpty) {
          state = state.copyWith(
              childrenByParent: state.childrenByParent.remove(parent.toJson()),
              parentByChild: state.parentByChild.remove(child.toJson()),
              debugNames: state.debugNames.remove(child.toJson()));
        } else {
          state = state.copyWith(
              childrenByParent:
                  state.childrenByParent.add(parent.toJson(), children),
              parentByChild: state.parentByChild.remove(child.toJson()),
              debugNames: state.debugNames.remove(child.toJson()));
        }
      }
    }

    if (state != _state) {
      _state = await store(state);
    }
  }

  TypedKey? _getParentRecordKeyInner(TypedKey child) {
    if (!_mutex.isLocked) {
      throw StateError('should be locked here');
    }

    final childJson = child.toJson();
    return _state.parentByChild[childJson];
  }

  bool _isValidRecordKeyInner(TypedKey key) {
    if (!_mutex.isLocked) {
      throw StateError('should be locked here');
    }

    if (_state.rootRecords.contains(key)) {
      return true;
    }
    if (_state.childrenByParent.containsKey(key.toJson())) {
      return true;
    }
    return false;
  }

  bool _isDeletedRecordKeyInner(TypedKey key) {
    if (!_mutex.isLocked) {
      throw StateError('should be locked here');
    }

    // Is this key gone?
    if (!_isValidRecordKeyInner(key)) {
      return true;
    }

    // Is this key on its way out because it or one of its parents
    // is scheduled to delete everything underneath it?
    TypedKey? nextParent = key;
    while (nextParent != null) {
      if (_markedForDelete.contains(nextParent)) {
        return true;
      }
      nextParent = _getParentRecordKeyInner(nextParent);
    }

    return false;
  }

  /// Handle the DHT record updates coming from internal to this app
  void _processLocalValueChange(TypedKey key, Uint8List data, int subkey) {
    // Change
    for (final kv in _opened.entries) {
      if (kv.key == key) {
        for (final rec in kv.value.records) {
          rec._addLocalValueChange(data, subkey);
        }
        break;
      }
    }
  }

  static _WatchState? _collectUnionWatchState(Iterable<DHTRecord> records) {
    // Collect union of opened record watch states
    int? totalCount;
    Timestamp? maxExpiration;
    List<ValueSubkeyRange>? allSubkeys;

    var noExpiration = false;
    var everySubkey = false;
    var cancelWatch = true;

    for (final rec in records) {
      final ws = rec._watchState;
      if (ws != null) {
        cancelWatch = false;
        final wsCount = ws.count;
        if (wsCount != null) {
          totalCount = totalCount ?? 0 + min(wsCount, 0x7FFFFFFF);
          totalCount = min(totalCount, 0x7FFFFFFF);
        }
        final wsExp = ws.expiration;
        if (wsExp != null && !noExpiration) {
          maxExpiration = maxExpiration == null
              ? wsExp
              : wsExp.value > maxExpiration.value
                  ? wsExp
                  : maxExpiration;
        } else {
          noExpiration = true;
        }
        final wsSubkeys = ws.subkeys;
        if (wsSubkeys != null && !everySubkey) {
          allSubkeys = allSubkeys == null
              ? wsSubkeys
              : allSubkeys.unionSubkeys(wsSubkeys);
        } else {
          everySubkey = true;
        }
      }
    }
    if (noExpiration) {
      maxExpiration = null;
    }
    if (everySubkey) {
      allSubkeys = null;
    }
    if (cancelWatch) {
      return null;
    }

    return _WatchState(
      subkeys: allSubkeys,
      expiration: maxExpiration,
      count: totalCount,
    );
  }

  Future<void> _watchStateChange(
      TypedKey openedRecordKey, _WatchState? unionWatchState) async {
    // Get the current state for this watch
    final openedRecordInfo = _opened[openedRecordKey];
    if (openedRecordInfo == null) {
      // Record is gone, nothing to do
      return;
    }
    final currentWatchState = openedRecordInfo.shared.unionWatchState;
    final dhtctx = openedRecordInfo.shared.defaultRoutingContext;

    // If it's the same as our desired state there is nothing to do here
    if (currentWatchState == unionWatchState) {
      return;
    }

    // Apply watch changes for record
    if (unionWatchState == null) {
      // Record needs watch cancel
      // Only try this once, if it doesn't succeed then it can just expire
      // on its own.
      try {
        final stillActive = await dhtctx.cancelDHTWatch(openedRecordKey);

        log('cancelDHTWatch: key=$openedRecordKey, stillActive=$stillActive, '
            'debugNames=${openedRecordInfo.debugNames}');

        openedRecordInfo.shared.unionWatchState = null;
        openedRecordInfo.shared.needsWatchStateUpdate = false;
      } on VeilidAPIExceptionTimeout {
        log('Timeout in watch cancel for key=$openedRecordKey');
      } on VeilidAPIException catch (e) {
        // Failed to cancel DHT watch, try again next tick
        log('VeilidAPIException in watch cancel for key=$openedRecordKey: $e');
      } catch (e) {
        log('Unhandled exception in watch cancel for key=$openedRecordKey: $e');
        rethrow;
      }

      return;
    }

    // Record needs new watch
    try {
      final subkeys = unionWatchState.subkeys?.toList();
      final count = unionWatchState.count;
      final expiration = unionWatchState.expiration;

      final active = await dhtctx.watchDHTValues(openedRecordKey,
          subkeys: unionWatchState.subkeys?.toList(),
          count: unionWatchState.count,
          expiration: unionWatchState.expiration);

      log('watchDHTValues(active=$active): '
          'key=$openedRecordKey, subkeys=$subkeys, '
          'count=$count, expiration=$expiration, '
          'debugNames=${openedRecordInfo.debugNames}');

      // Update watch states with real expiration
      if (active) {
        openedRecordInfo.shared.unionWatchState = unionWatchState;
        openedRecordInfo.shared.needsWatchStateUpdate = false;
      }
    } on VeilidAPIExceptionTimeout {
      log('Timeout in watch update for key=$openedRecordKey');
    } on VeilidAPIException catch (e) {
      // Failed to update DHT watch, try again next tick
      log('VeilidAPIException in watch update for key=$openedRecordKey: $e');
    } catch (e) {
      log('Unhandled exception in watch update for key=$openedRecordKey: $e');
      rethrow;
    }

    // If we still need a state update after this then do a poll instead
    if (openedRecordInfo.shared.needsWatchStateUpdate) {
      _pollWatch(openedRecordKey, openedRecordInfo, unionWatchState);
    }
  }

  // In lieu of a completed watch, set off a polling operation
  // on the first value of the watched range, which, due to current
  // veilid limitations can only be one subkey at a time right now
  void _pollWatch(TypedKey openedRecordKey, _OpenedRecordInfo openedRecordInfo,
      _WatchState unionWatchState) {
    singleFuture((this, _sfPollWatch, openedRecordKey), () async {
      await _stats.measure(
          openedRecordKey, openedRecordInfo.debugNames, '_pollWatch', () async {
        final dhtctx = openedRecordInfo.shared.defaultRoutingContext;

        final currentReport = await dhtctx.inspectDHTRecord(openedRecordKey,
            subkeys: unionWatchState.subkeys, scope: DHTReportScope.syncGet);

        final fsc = currentReport.firstSeqChange;
        if (fsc == null) {
          return null;
        }
        final newerSubkeys = currentReport.newerOnlineSubkeys;

        final valueData = await dhtctx.getDHTValue(openedRecordKey, fsc.subkey,
            forceRefresh: true);
        if (valueData == null) {
          return;
        }

        if (valueData.seq < fsc.newSeq) {
          log('inspect returned a newer seq than get: ${valueData.seq} < $fsc');
        }

        if (fsc.oldSeq == null || valueData.seq > fsc.oldSeq!) {
          processRemoteValueChange(VeilidUpdateValueChange(
              key: openedRecordKey,
              subkeys: newerSubkeys,
              count: 0xFFFFFFFF,
              value: valueData));
        }
      });
    });
  }

  /// Ticker to check watch state change requests
  Future<void> tick() async => _mutex.protect(() async {
        // See if any opened records need watch state changes
        for (final kv in _opened.entries) {
          final openedRecordKey = kv.key;
          final openedRecordInfo = kv.value;

          final wantsWatchStateUpdate =
              openedRecordInfo.shared.needsWatchStateUpdate;

          if (wantsWatchStateUpdate) {
            // Update union watch state
            final unionWatchState =
                _collectUnionWatchState(openedRecordInfo.records);

            _watchStateProcessors.updateState(
                openedRecordKey,
                unionWatchState,
                (newState) => _stats.measure(
                    openedRecordKey,
                    openedRecordInfo.debugNames,
                    '_watchStateChange',
                    () => _watchStateChange(openedRecordKey, unionWatchState)));
          }
        }
      });

  //////////////////////////////////////////////////////////////
  // AsyncTableDBBacked
  @override
  String tableName() => 'dht_record_pool';
  @override
  String tableKeyName() => 'pool_allocations';
  @override
  DHTRecordPoolAllocations valueFromJson(Object? obj) => obj != null
      ? DHTRecordPoolAllocations.fromJson(obj)
      : const DHTRecordPoolAllocations();
  @override
  Object? valueToJson(DHTRecordPoolAllocations? val) => val?.toJson();

  ////////////////////////////////////////////////////////////////////////////
  // Fields

  // Logger
  DHTRecordPoolLogger? _logger;

  // Persistent DHT record list
  DHTRecordPoolAllocations _state;
  // Create/open Mutex
  final Mutex _mutex;
  // Record key tag lock
  final AsyncTagLock<TypedKey> _recordTagLock;
  // Which DHT records are currently open
  final Map<TypedKey, _OpenedRecordInfo> _opened;
  // Which DHT records are marked for deletion
  final Set<TypedKey> _markedForDelete;
  // Default routing context to use for new keys
  final VeilidRoutingContext _routingContext;
  // Convenience accessor
  final Veilid _veilid;
  Veilid get veilid => _veilid;
  // Watch state processors
  final _watchStateProcessors =
      SingleStateProcessorMap<TypedKey, _WatchState?>();
  // Statistics
  final _stats = DHTStats();

  static DHTRecordPool? _singleton;
}
