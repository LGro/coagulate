part of 'dht_record_pool.dart';

@immutable
class DHTRecordWatchChange extends Equatable {
  const DHTRecordWatchChange(
      {required this.local, required this.data, required this.subkeys});

  final bool local;
  final Uint8List? data;
  final List<ValueSubkeyRange> subkeys;

  @override
  List<Object?> get props => [local, data, subkeys];
}

/// Refresh mode for DHT record 'get'
enum DHTRecordRefreshMode {
  /// Return existing subkey values if they exist locally already
  /// If not, check the network for a value
  /// This is the default refresh mode
  cached,

  /// Return existing subkey values only if they exist locally already
  local,

  /// Always check the network for a newer subkey value
  network,

  /// Always check the network for a newer subkey value but only
  /// return that value if its sequence number is newer than the local value
  update;

  bool get _forceRefresh => this == network || this == update;
  bool get _inspectLocal => this == local || this == update;
}

/////////////////////////////////////////////////

class DHTRecord implements DHTDeleteable<DHTRecord> {
  DHTRecord._(
      {required VeilidRoutingContext routingContext,
      required _SharedDHTRecordData sharedDHTRecordData,
      required int defaultSubkey,
      required KeyPair? writer,
      required VeilidCrypto crypto,
      required this.debugName})
      : _crypto = crypto,
        _routingContext = routingContext,
        _defaultSubkey = defaultSubkey,
        _writer = writer,
        _openCount = 1,
        _sharedDHTRecordData = sharedDHTRecordData;

  ////////////////////////////////////////////////////////////////////////////
  // DHTCloseable

  /// Check if the DHTRecord is open
  @override
  bool get isOpen => _openCount > 0;

  /// The type of the openable scope
  @override
  FutureOr<DHTRecord> scoped() => this;

  /// Add a reference to this DHTRecord
  @override
  Future<void> ref() async => _mutex.protect(() async {
        _openCount++;
      });

  /// Free all resources for the DHTRecord
  @override
  Future<bool> close() async => _mutex.protect(() async {
        if (_openCount == 0) {
          throw StateError('already closed');
        }
        _openCount--;
        if (_openCount != 0) {
          return false;
        }

        await serialFuturePause((this, _sfListen));
        await _watchController?.close();
        _watchController = null;
        await DHTRecordPool.instance._recordClosed(this);
        return true;
      });

  /// Free all resources for the DHTRecord and delete it from the DHT
  /// Will wait until the record is closed to delete it
  @override
  Future<void> delete() async => _mutex.protect(() async {
        await DHTRecordPool.instance.deleteRecord(key);
      });

  ////////////////////////////////////////////////////////////////////////////
  // Public API

  VeilidRoutingContext get routingContext => _routingContext;
  TypedKey get key => _sharedDHTRecordData.recordDescriptor.key;
  PublicKey get owner => _sharedDHTRecordData.recordDescriptor.owner;
  KeyPair? get ownerKeyPair =>
      _sharedDHTRecordData.recordDescriptor.ownerKeyPair();
  DHTSchema get schema => _sharedDHTRecordData.recordDescriptor.schema;
  int get subkeyCount =>
      _sharedDHTRecordData.recordDescriptor.schema.subkeyCount();
  KeyPair? get writer => _writer;
  VeilidCrypto get crypto => _crypto;
  OwnedDHTRecordPointer get ownedDHTRecordPointer =>
      OwnedDHTRecordPointer(recordKey: key, owner: ownerKeyPair!);
  int subkeyOrDefault(int subkey) => (subkey == -1) ? _defaultSubkey : subkey;

  /// Get a subkey value from this record.
  /// Returns the most recent value data for this subkey or null if this subkey
  /// has not yet been written to.
  /// * 'refreshMode' determines whether or not to return a locally existing
  ///   value or always check the network
  /// * 'outSeqNum' optionally returns the sequence number of the value being
  ///   returned if one was returned.
  Future<Uint8List?> get(
      {int subkey = -1,
      VeilidCrypto? crypto,
      DHTRecordRefreshMode refreshMode = DHTRecordRefreshMode.cached,
      Output<int>? outSeqNum}) async {
    subkey = subkeyOrDefault(subkey);

    // Get the last sequence number if we need it
    final lastSeq =
        refreshMode._inspectLocal ? await _localSubkeySeq(subkey) : null;

    // See if we only ever want the locally stored value
    if (refreshMode == DHTRecordRefreshMode.local && lastSeq == null) {
      // If it's not available locally already just return null now
      return null;
    }

    final valueData = await _routingContext.getDHTValue(key, subkey,
        forceRefresh: refreshMode._forceRefresh);
    if (valueData == null) {
      return null;
    }
    // See if this get resulted in a newer sequence number
    if (refreshMode == DHTRecordRefreshMode.update &&
        lastSeq != null &&
        valueData.seq <= lastSeq) {
      // If we're only returning updates then punt now
      return null;
    }
    // If we're returning a value, decrypt it
    final out = (crypto ?? _crypto).decrypt(valueData.data);
    if (outSeqNum != null) {
      outSeqNum.save(valueData.seq);
    }
    return out;
  }

  /// Get a subkey value from this record.
  /// Process the record returned with a JSON unmarshal function 'fromJson'.
  /// Returns the most recent value data for this subkey or null if this subkey
  /// has not yet been written to.
  /// * 'refreshMode' determines whether or not to return a locally existing
  ///   value or always check the network
  /// * 'outSeqNum' optionally returns the sequence number of the value being
  ///   returned if one was returned.
  Future<T?> getJson<T>(T Function(dynamic) fromJson,
      {int subkey = -1,
      VeilidCrypto? crypto,
      DHTRecordRefreshMode refreshMode = DHTRecordRefreshMode.cached,
      Output<int>? outSeqNum}) async {
    final data = await get(
        subkey: subkey,
        crypto: crypto,
        refreshMode: refreshMode,
        outSeqNum: outSeqNum);
    if (data == null) {
      return null;
    }
    return jsonDecodeBytes(fromJson, data);
  }

  /// Get a subkey value from this record.
  /// Process the record returned with a protobuf unmarshal
  /// function 'fromBuffer'.
  /// Returns the most recent value data for this subkey or null if this subkey
  /// has not yet been written to.
  /// * 'refreshMode' determines whether or not to return a locally existing
  ///   value or always check the network
  /// * 'outSeqNum' optionally returns the sequence number of the value being
  ///   returned if one was returned.
  Future<T?> getProtobuf<T extends GeneratedMessage>(
      T Function(List<int> i) fromBuffer,
      {int subkey = -1,
      VeilidCrypto? crypto,
      DHTRecordRefreshMode refreshMode = DHTRecordRefreshMode.cached,
      Output<int>? outSeqNum}) async {
    final data = await get(
        subkey: subkey,
        crypto: crypto,
        refreshMode: refreshMode,
        outSeqNum: outSeqNum);
    if (data == null) {
      return null;
    }
    return fromBuffer(data.toList());
  }

  /// Attempt to write a byte buffer to a DHTRecord subkey
  /// If a newer value was found on the network, it is returned
  /// If the value was succesfully written, null is returned
  Future<Uint8List?> tryWriteBytes(Uint8List newValue,
      {int subkey = -1,
      VeilidCrypto? crypto,
      KeyPair? writer,
      Output<int>? outSeqNum}) async {
    subkey = subkeyOrDefault(subkey);
    final lastSeq = await _localSubkeySeq(subkey);
    final encryptedNewValue = await (crypto ?? _crypto).encrypt(newValue);

    // Set the new data if possible
    var newValueData = await _routingContext
        .setDHTValue(key, subkey, encryptedNewValue, writer: writer ?? _writer);
    if (newValueData == null) {
      // A newer value wasn't found on the set, but
      // we may get a newer value when getting the value for the sequence number
      newValueData = await _routingContext.getDHTValue(key, subkey);
      if (newValueData == null) {
        assert(newValueData != null, "can't get value that was just set");
        return null;
      }
    }

    // Record new sequence number
    final isUpdated = newValueData.seq != lastSeq;
    if (isUpdated && outSeqNum != null) {
      outSeqNum.save(newValueData.seq);
    }

    // See if the encrypted data returned is exactly the same
    // if so, shortcut and don't bother decrypting it
    if (newValueData.data.equals(encryptedNewValue)) {
      if (isUpdated) {
        DHTRecordPool.instance._processLocalValueChange(key, newValue, subkey);
      }
      return null;
    }

    // Decrypt value to return it
    final decryptedNewValue =
        await (crypto ?? _crypto).decrypt(newValueData.data);
    if (isUpdated) {
      DHTRecordPool.instance
          ._processLocalValueChange(key, decryptedNewValue, subkey);
    }
    return decryptedNewValue;
  }

  /// Attempt to write a byte buffer to a DHTRecord subkey
  /// If a newer value was found on the network, another attempt
  /// will be made to write the subkey until this succeeds
  Future<void> eventualWriteBytes(Uint8List newValue,
      {int subkey = -1,
      VeilidCrypto? crypto,
      KeyPair? writer,
      Output<int>? outSeqNum}) async {
    subkey = subkeyOrDefault(subkey);
    final lastSeq = await _localSubkeySeq(subkey);
    final encryptedNewValue = await (crypto ?? _crypto).encrypt(newValue);

    ValueData? newValueData;
    do {
      do {
        // Set the new data
        newValueData = await _routingContext.setDHTValue(
            key, subkey, encryptedNewValue,
            writer: writer ?? _writer);

        // Repeat if newer data on the network was found
      } while (newValueData != null);

      // Get the data to check its sequence number
      newValueData = await _routingContext.getDHTValue(key, subkey);
      if (newValueData == null) {
        assert(newValueData != null, "can't get value that was just set");
        return;
      }

      // Record new sequence number
      if (outSeqNum != null) {
        outSeqNum.save(newValueData.seq);
      }

      // The encrypted data returned should be exactly the same
      // as what we are trying to set,
      // otherwise we still need to keep trying to set the value
    } while (!newValueData.data.equals(encryptedNewValue));

    final isUpdated = newValueData.seq != lastSeq;
    if (isUpdated) {
      DHTRecordPool.instance._processLocalValueChange(key, newValue, subkey);
    }
  }

  /// Attempt to write a byte buffer to a DHTRecord subkey
  /// If a newer value was found on the network, another attempt
  /// will be made to write the subkey until this succeeds
  /// Each attempt to write the value calls an update function with the
  /// old value to determine what new value should be attempted for that write.
  Future<void> eventualUpdateBytes(
      Future<Uint8List?> Function(Uint8List? oldValue) update,
      {int subkey = -1,
      VeilidCrypto? crypto,
      KeyPair? writer,
      Output<int>? outSeqNum}) async {
    subkey = subkeyOrDefault(subkey);

    // Get the existing data, do not allow force refresh here
    // because if we need a refresh the setDHTValue will fail anyway
    var oldValue =
        await get(subkey: subkey, crypto: crypto, outSeqNum: outSeqNum);

    do {
      // Update the data
      final updatedValue = await update(oldValue);
      if (updatedValue == null) {
        // If null is returned from the update, stop trying to do the update
        break;
      }
      // Try to write it back to the network
      oldValue = await tryWriteBytes(updatedValue,
          subkey: subkey, crypto: crypto, writer: writer, outSeqNum: outSeqNum);

      // Repeat update if newer data on the network was found
    } while (oldValue != null);
  }

  /// Like 'tryWriteBytes' but with JSON marshal/unmarshal of the value
  Future<T?> tryWriteJson<T>(T Function(dynamic) fromJson, T newValue,
          {int subkey = -1,
          VeilidCrypto? crypto,
          KeyPair? writer,
          Output<int>? outSeqNum}) =>
      tryWriteBytes(jsonEncodeBytes(newValue),
              subkey: subkey,
              crypto: crypto,
              writer: writer,
              outSeqNum: outSeqNum)
          .then((out) {
        if (out == null) {
          return null;
        }
        return jsonDecodeBytes(fromJson, out);
      });

  /// Like 'tryWriteBytes' but with protobuf marshal/unmarshal of the value
  Future<T?> tryWriteProtobuf<T extends GeneratedMessage>(
          T Function(List<int>) fromBuffer, T newValue,
          {int subkey = -1,
          VeilidCrypto? crypto,
          KeyPair? writer,
          Output<int>? outSeqNum}) =>
      tryWriteBytes(newValue.writeToBuffer(),
              subkey: subkey,
              crypto: crypto,
              writer: writer,
              outSeqNum: outSeqNum)
          .then((out) {
        if (out == null) {
          return null;
        }
        return fromBuffer(out);
      });

  /// Like 'eventualWriteBytes' but with JSON marshal/unmarshal of the value
  Future<void> eventualWriteJson<T>(T newValue,
          {int subkey = -1,
          VeilidCrypto? crypto,
          KeyPair? writer,
          Output<int>? outSeqNum}) =>
      eventualWriteBytes(jsonEncodeBytes(newValue),
          subkey: subkey, crypto: crypto, writer: writer, outSeqNum: outSeqNum);

  /// Like 'eventualWriteBytes' but with protobuf marshal/unmarshal of the value
  Future<void> eventualWriteProtobuf<T extends GeneratedMessage>(T newValue,
          {int subkey = -1,
          VeilidCrypto? crypto,
          KeyPair? writer,
          Output<int>? outSeqNum}) =>
      eventualWriteBytes(newValue.writeToBuffer(),
          subkey: subkey, crypto: crypto, writer: writer, outSeqNum: outSeqNum);

  /// Like 'eventualUpdateBytes' but with JSON marshal/unmarshal of the value
  Future<void> eventualUpdateJson<T>(
          T Function(dynamic) fromJson, Future<T?> Function(T?) update,
          {int subkey = -1,
          VeilidCrypto? crypto,
          KeyPair? writer,
          Output<int>? outSeqNum}) =>
      eventualUpdateBytes(jsonUpdate(fromJson, update),
          subkey: subkey, crypto: crypto, writer: writer, outSeqNum: outSeqNum);

  /// Like 'eventualUpdateBytes' but with protobuf marshal/unmarshal of the value
  Future<void> eventualUpdateProtobuf<T extends GeneratedMessage>(
          T Function(List<int>) fromBuffer, Future<T?> Function(T?) update,
          {int subkey = -1,
          VeilidCrypto? crypto,
          KeyPair? writer,
          Output<int>? outSeqNum}) =>
      eventualUpdateBytes(protobufUpdate(fromBuffer, update),
          subkey: subkey, crypto: crypto, writer: writer, outSeqNum: outSeqNum);

  /// Watch a subkey range of this DHT record for changes
  /// Takes effect on the next DHTRecordPool tick
  Future<void> watch(
      {List<ValueSubkeyRange>? subkeys,
      Timestamp? expiration,
      int? count}) async {
    // Set up watch requirements which will get picked up by the next tick
    final oldWatchState = watchState;
    watchState =
        _WatchState(subkeys: subkeys, expiration: expiration, count: count);
    if (oldWatchState != watchState) {
      _sharedDHTRecordData.needsWatchStateUpdate = true;
    }
  }

  /// Register a callback for changes made on this this DHT record.
  /// You must 'watch' the record as well as listen to it in order for this
  /// call back to be called.
  /// * 'localChanges' also enables calling the callback if changed are made
  ///   locally, otherwise only changes seen from the network itself are
  ///   reported
  ///
  Future<StreamSubscription<DHTRecordWatchChange>> listen(
    Future<void> Function(
            DHTRecord record, Uint8List? data, List<ValueSubkeyRange> subkeys)
        onUpdate, {
    bool localChanges = true,
    VeilidCrypto? crypto,
  }) async {
    // Set up watch requirements
    _watchController ??=
        StreamController<DHTRecordWatchChange>.broadcast(onCancel: () {
      // If there are no more listeners then we can get rid of the controller
      _watchController = null;
    });

    return _watchController!.stream.listen(
        (change) {
          if (change.local && !localChanges) {
            return;
          }

          serialFuture((this, _sfListen), () async {
            final Uint8List? data;
            if (change.local) {
              // local changes are not encrypted
              data = change.data;
            } else {
              // incoming/remote changes are encrypted
              final changeData = change.data;
              data = changeData == null
                  ? null
                  : await (crypto ?? _crypto).decrypt(changeData);
            }
            await onUpdate(this, data, change.subkeys);
          });
        },
        cancelOnError: true,
        onError: (e) async {
          await _watchController!.close();
          _watchController = null;
        });
  }

  /// Stop watching this record for changes
  /// Takes effect on the next DHTRecordPool tick
  Future<void> cancelWatch() async {
    // Tear down watch requirements
    if (watchState != null) {
      watchState = null;
      _sharedDHTRecordData.needsWatchStateUpdate = true;
    }
  }

  /// Return the inspection state of a set of subkeys of the DHTRecord
  /// See Veilid's 'inspectDHTRecord' call for details on how this works
  Future<DHTRecordReport> inspect(
          {List<ValueSubkeyRange>? subkeys,
          DHTReportScope scope = DHTReportScope.local}) =>
      _routingContext.inspectDHTRecord(key, subkeys: subkeys, scope: scope);

  //////////////////////////////////////////////////////////////////////////

  Future<int?> _localSubkeySeq(int subkey) async {
    final rr = await _routingContext.inspectDHTRecord(
      key,
      subkeys: [ValueSubkeyRange.single(subkey)],
    );
    return rr.localSeqs.firstOrNull ?? 0xFFFFFFFF;
  }

  void _addValueChange(
      {required bool local,
      required Uint8List? data,
      required List<ValueSubkeyRange> subkeys}) {
    final ws = watchState;
    if (ws != null) {
      final watchedSubkeys = ws.subkeys;
      if (watchedSubkeys == null) {
        // Report all subkeys
        _watchController?.add(
            DHTRecordWatchChange(local: local, data: data, subkeys: subkeys));
      } else {
        // Only some subkeys are being watched, see if the reported update
        // overlaps the subkeys being watched
        final overlappedSubkeys = watchedSubkeys.intersectSubkeys(subkeys);
        // If the reported data isn't within the
        // range we care about, don't pass it through
        final overlappedFirstSubkey = overlappedSubkeys.firstSubkey;
        final updateFirstSubkey = subkeys.firstSubkey;
        if (overlappedFirstSubkey != null && updateFirstSubkey != null) {
          final updatedData =
              overlappedFirstSubkey == updateFirstSubkey ? data : null;

          // Report only watched subkeys
          _watchController?.add(DHTRecordWatchChange(
              local: local, data: updatedData, subkeys: overlappedSubkeys));
        }
      }
    }
  }

  void _addLocalValueChange(Uint8List data, int subkey) {
    _addValueChange(
        local: true, data: data, subkeys: [ValueSubkeyRange.single(subkey)]);
  }

  void _addRemoteValueChange(VeilidUpdateValueChange update) {
    _addValueChange(
        local: false, data: update.value?.data, subkeys: update.subkeys);
  }

  //////////////////////////////////////////////////////////////

  final _SharedDHTRecordData _sharedDHTRecordData;
  final VeilidRoutingContext _routingContext;
  final int _defaultSubkey;
  final KeyPair? _writer;
  final VeilidCrypto _crypto;
  final String debugName;
  final _mutex = Mutex();
  int _openCount;
  StreamController<DHTRecordWatchChange>? _watchController;
  @internal
  _WatchState? watchState;
}
