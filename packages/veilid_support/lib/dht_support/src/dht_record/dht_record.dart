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

/////////////////////////////////////////////////

class DHTRecord {
  DHTRecord(
      {required VeilidRoutingContext routingContext,
      required SharedDHTRecordData sharedDHTRecordData,
      required int defaultSubkey,
      required KeyPair? writer,
      required DHTRecordCrypto crypto})
      : _crypto = crypto,
        _routingContext = routingContext,
        _defaultSubkey = defaultSubkey,
        _writer = writer,
        _open = true,
        _sharedDHTRecordData = sharedDHTRecordData;

  final SharedDHTRecordData _sharedDHTRecordData;
  final VeilidRoutingContext _routingContext;
  final int _defaultSubkey;
  final KeyPair? _writer;
  final DHTRecordCrypto _crypto;

  bool _open;
  @internal
  StreamController<DHTRecordWatchChange>? watchController;
  @internal
  WatchState? watchState;

  int subkeyOrDefault(int subkey) => (subkey == -1) ? _defaultSubkey : subkey;

  VeilidRoutingContext get routingContext => _routingContext;
  TypedKey get key => _sharedDHTRecordData.recordDescriptor.key;
  PublicKey get owner => _sharedDHTRecordData.recordDescriptor.owner;
  KeyPair? get ownerKeyPair =>
      _sharedDHTRecordData.recordDescriptor.ownerKeyPair();
  DHTSchema get schema => _sharedDHTRecordData.recordDescriptor.schema;
  int get subkeyCount =>
      _sharedDHTRecordData.recordDescriptor.schema.subkeyCount();
  KeyPair? get writer => _writer;
  DHTRecordCrypto get crypto => _crypto;
  OwnedDHTRecordPointer get ownedDHTRecordPointer =>
      OwnedDHTRecordPointer(recordKey: key, owner: ownerKeyPair!);

  Future<void> close() async {
    if (!_open) {
      return;
    }
    await watchController?.close();
    await DHTRecordPool.instance._recordClosed(this);
    _open = false;
  }

  Future<T> scope<T>(Future<T> Function(DHTRecord) scopeFunction) async {
    try {
      return await scopeFunction(this);
    } finally {
      await close();
    }
  }

  Future<T> deleteScope<T>(Future<T> Function(DHTRecord) scopeFunction) async {
    try {
      final out = await scopeFunction(this);
      if (_open) {
        await close();
      }
      return out;
    } on Exception catch (_) {
      if (_open) {
        await close();
      }
      await DHTRecordPool.instance.delete(key);
      rethrow;
    }
  }

  Future<T> maybeDeleteScope<T>(
      bool delete, Future<T> Function(DHTRecord) scopeFunction) async {
    if (delete) {
      return deleteScope(scopeFunction);
    } else {
      return scope(scopeFunction);
    }
  }

  Future<Uint8List?> get(
      {int subkey = -1,
      bool forceRefresh = false,
      bool onlyUpdates = false}) async {
    subkey = subkeyOrDefault(subkey);
    final valueData = await _routingContext.getDHTValue(key, subkey,
        forceRefresh: forceRefresh);
    if (valueData == null) {
      return null;
    }
    final lastSeq = _sharedDHTRecordData.subkeySeqCache[subkey];
    if (onlyUpdates && lastSeq != null && valueData.seq <= lastSeq) {
      return null;
    }
    final out = _crypto.decrypt(valueData.data, subkey);
    _sharedDHTRecordData.subkeySeqCache[subkey] = valueData.seq;
    return out;
  }

  Future<T?> getJson<T>(T Function(dynamic) fromJson,
      {int subkey = -1,
      bool forceRefresh = false,
      bool onlyUpdates = false}) async {
    final data = await get(
        subkey: subkey, forceRefresh: forceRefresh, onlyUpdates: onlyUpdates);
    if (data == null) {
      return null;
    }
    return jsonDecodeBytes(fromJson, data);
  }

  Future<T?> getProtobuf<T extends GeneratedMessage>(
      T Function(List<int> i) fromBuffer,
      {int subkey = -1,
      bool forceRefresh = false,
      bool onlyUpdates = false}) async {
    final data = await get(
        subkey: subkey, forceRefresh: forceRefresh, onlyUpdates: onlyUpdates);
    if (data == null) {
      return null;
    }
    return fromBuffer(data.toList());
  }

  Future<Uint8List?> tryWriteBytes(Uint8List newValue,
      {int subkey = -1}) async {
    subkey = subkeyOrDefault(subkey);
    final lastSeq = _sharedDHTRecordData.subkeySeqCache[subkey];
    final encryptedNewValue = await _crypto.encrypt(newValue, subkey);

    // Set the new data if possible
    var newValueData = await _routingContext
        .setDHTValue(key, subkey, encryptedNewValue, writer: _writer);
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
    _sharedDHTRecordData.subkeySeqCache[subkey] = newValueData.seq;

    // See if the encrypted data returned is exactly the same
    // if so, shortcut and don't bother decrypting it
    if (newValueData.data.equals(encryptedNewValue)) {
      if (isUpdated) {
        DHTRecordPool.instance.processLocalValueChange(key, newValue, subkey);
      }
      return null;
    }

    // Decrypt value to return it
    final decryptedNewValue = await _crypto.decrypt(newValueData.data, subkey);
    if (isUpdated) {
      DHTRecordPool.instance
          .processLocalValueChange(key, decryptedNewValue, subkey);
    }
    return decryptedNewValue;
  }

  Future<void> eventualWriteBytes(Uint8List newValue, {int subkey = -1}) async {
    subkey = subkeyOrDefault(subkey);
    final lastSeq = _sharedDHTRecordData.subkeySeqCache[subkey];
    final encryptedNewValue = await _crypto.encrypt(newValue, subkey);

    ValueData? newValueData;
    do {
      do {
        // Set the new data
        newValueData = await _routingContext
            .setDHTValue(key, subkey, encryptedNewValue, writer: _writer);

        // Repeat if newer data on the network was found
      } while (newValueData != null);

      // Get the data to check its sequence number
      newValueData = await _routingContext.getDHTValue(key, subkey);
      if (newValueData == null) {
        assert(newValueData != null, "can't get value that was just set");
        return;
      }

      // Record new sequence number
      _sharedDHTRecordData.subkeySeqCache[subkey] = newValueData.seq;

      // The encrypted data returned should be exactly the same
      // as what we are trying to set,
      // otherwise we still need to keep trying to set the value
    } while (!newValueData.data.equals(encryptedNewValue));

    final isUpdated = newValueData.seq != lastSeq;
    if (isUpdated) {
      DHTRecordPool.instance.processLocalValueChange(key, newValue, subkey);
    }
  }

  Future<void> eventualUpdateBytes(
      Future<Uint8List> Function(Uint8List? oldValue) update,
      {int subkey = -1}) async {
    subkey = subkeyOrDefault(subkey);

    // Get the existing data, do not allow force refresh here
    // because if we need a refresh the setDHTValue will fail anyway
    var oldValue = await get(subkey: subkey);

    do {
      // Update the data
      final updatedValue = await update(oldValue);

      // Try to write it back to the network
      oldValue = await tryWriteBytes(updatedValue, subkey: subkey);

      // Repeat update if newer data on the network was found
    } while (oldValue != null);
  }

  Future<T?> tryWriteJson<T>(T Function(dynamic) fromJson, T newValue,
          {int subkey = -1}) =>
      tryWriteBytes(jsonEncodeBytes(newValue), subkey: subkey).then((out) {
        if (out == null) {
          return null;
        }
        return jsonDecodeBytes(fromJson, out);
      });

  Future<T?> tryWriteProtobuf<T extends GeneratedMessage>(
          T Function(List<int>) fromBuffer, T newValue,
          {int subkey = -1}) =>
      tryWriteBytes(newValue.writeToBuffer(), subkey: subkey).then((out) {
        if (out == null) {
          return null;
        }
        return fromBuffer(out);
      });

  Future<void> eventualWriteJson<T>(T newValue, {int subkey = -1}) =>
      eventualWriteBytes(jsonEncodeBytes(newValue), subkey: subkey);

  Future<void> eventualWriteProtobuf<T extends GeneratedMessage>(T newValue,
          {int subkey = -1}) =>
      eventualWriteBytes(newValue.writeToBuffer(), subkey: subkey);

  Future<void> eventualUpdateJson<T>(
          T Function(dynamic) fromJson, Future<T> Function(T?) update,
          {int subkey = -1}) =>
      eventualUpdateBytes(jsonUpdate(fromJson, update), subkey: subkey);

  Future<void> eventualUpdateProtobuf<T extends GeneratedMessage>(
          T Function(List<int>) fromBuffer, Future<T> Function(T?) update,
          {int subkey = -1}) =>
      eventualUpdateBytes(protobufUpdate(fromBuffer, update), subkey: subkey);

  Future<void> watch(
      {List<ValueSubkeyRange>? subkeys,
      Timestamp? expiration,
      int? count}) async {
    // Set up watch requirements which will get picked up by the next tick
    final oldWatchState = watchState;
    watchState =
        WatchState(subkeys: subkeys, expiration: expiration, count: count);
    if (oldWatchState != watchState) {
      _sharedDHTRecordData.needsWatchStateUpdate = true;
    }
  }

  Future<StreamSubscription<DHTRecordWatchChange>> listen(
      Future<void> Function(
              DHTRecord record, Uint8List? data, List<ValueSubkeyRange> subkeys)
          onUpdate,
      {bool localChanges = true}) async {
    // Set up watch requirements
    watchController ??=
        StreamController<DHTRecordWatchChange>.broadcast(onCancel: () {
      // If there are no more listeners then we can get rid of the controller
      watchController = null;
    });

    return watchController!.stream.listen(
        (change) {
          if (change.local && !localChanges) {
            return;
          }
          Future.delayed(Duration.zero, () async {
            final Uint8List? data;
            if (change.local) {
              // local changes are not encrypted
              data = change.data;
            } else {
              // incoming/remote changes are encrypted
              final changeData = change.data;
              data = changeData == null
                  ? null
                  : await _crypto.decrypt(changeData, change.subkeys.first.low);
            }
            await onUpdate(this, data, change.subkeys);
          });
        },
        cancelOnError: true,
        onError: (e) async {
          await watchController!.close();
          watchController = null;
        });
  }

  Future<void> cancelWatch() async {
    // Tear down watch requirements
    if (watchState != null) {
      watchState = null;
      _sharedDHTRecordData.needsWatchStateUpdate = true;
    }
  }

  Future<DHTRecordReport> inspect(
          {List<ValueSubkeyRange>? subkeys,
          DHTReportScope scope = DHTReportScope.local}) =>
      _routingContext.inspectDHTRecord(key, subkeys: subkeys, scope: scope);

  void _addValueChange(
      {required bool local,
      required Uint8List? data,
      required List<ValueSubkeyRange> subkeys}) {
    final ws = watchState;
    if (ws != null) {
      final watchedSubkeys = ws.subkeys;
      if (watchedSubkeys == null) {
        // Report all subkeys
        watchController?.add(
            DHTRecordWatchChange(local: local, data: data, subkeys: subkeys));
      } else {
        // Only some subkeys are being watched, see if the reported update
        // overlaps the subkeys being watched
        final overlappedSubkeys = watchedSubkeys.intersectSubkeys(subkeys);
        // If the reported data isn't within the
        // range we care about, don't pass it through
        final overlappedFirstSubkey = overlappedSubkeys.firstSubkey;
        final updateFirstSubkey = subkeys.firstSubkey;
        final updatedData = (overlappedFirstSubkey != null &&
                updateFirstSubkey != null &&
                overlappedFirstSubkey == updateFirstSubkey)
            ? data
            : null;
        // Report only wathced subkeys
        watchController?.add(DHTRecordWatchChange(
            local: local, data: updatedData, subkeys: overlappedSubkeys));
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
}
