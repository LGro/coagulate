import 'dart:async';
import 'dart:typed_data';

import 'package:protobuf/protobuf.dart';

import '../../veilid_support.dart';

class DHTRecord {
  DHTRecord(
      {required VeilidRoutingContext routingContext,
      required DHTRecordDescriptor recordDescriptor,
      int defaultSubkey = 0,
      KeyPair? writer,
      DHTRecordCrypto crypto = const DHTRecordCryptoPublic()})
      : _crypto = crypto,
        _routingContext = routingContext,
        _recordDescriptor = recordDescriptor,
        _defaultSubkey = defaultSubkey,
        _writer = writer,
        _open = true,
        _valid = true,
        _subkeySeqCache = {};
  final VeilidRoutingContext _routingContext;
  final DHTRecordDescriptor _recordDescriptor;
  final int _defaultSubkey;
  final KeyPair? _writer;
  final Map<int, int> _subkeySeqCache;
  final DHTRecordCrypto _crypto;
  bool _open;
  bool _valid;

  int subkeyOrDefault(int subkey) => (subkey == -1) ? _defaultSubkey : subkey;

  VeilidRoutingContext get routingContext => _routingContext;
  TypedKey get key => _recordDescriptor.key;
  PublicKey get owner => _recordDescriptor.owner;
  KeyPair? get ownerKeyPair => _recordDescriptor.ownerKeyPair();
  DHTSchema get schema => _recordDescriptor.schema;
  KeyPair? get writer => _writer;
  OwnedDHTRecordPointer get ownedDHTRecordPointer =>
      OwnedDHTRecordPointer(recordKey: key, owner: ownerKeyPair!);

  Future<void> close() async {
    if (!_valid) {
      throw StateError('already deleted');
    }
    if (!_open) {
      return;
    }
    final pool = await DHTRecordPool.instance();
    await _routingContext.closeDHTRecord(_recordDescriptor.key);
    pool.recordClosed(_recordDescriptor.key);
    _open = false;
  }

  Future<void> delete() async {
    if (!_valid) {
      throw StateError('already deleted');
    }
    if (_open) {
      await close();
    }
    final pool = await DHTRecordPool.instance();
    await pool.deleteDeep(key);
    _valid = false;
  }

  Future<T> scope<T>(Future<T> Function(DHTRecord) scopeFunction) async {
    try {
      return await scopeFunction(this);
    } finally {
      if (_valid) {
        await close();
      }
    }
  }

  Future<T> deleteScope<T>(Future<T> Function(DHTRecord) scopeFunction) async {
    try {
      final out = await scopeFunction(this);
      if (_valid && _open) {
        await close();
      }
      return out;
    } on Exception catch (_) {
      if (_valid) {
        await delete();
      }
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
    final valueData = await _routingContext.getDHTValue(
        _recordDescriptor.key, subkey, forceRefresh);
    if (valueData == null) {
      return null;
    }
    final lastSeq = _subkeySeqCache[subkey];
    if (onlyUpdates && lastSeq != null && valueData.seq <= lastSeq) {
      return null;
    }
    final out = _crypto.decrypt(valueData.data, subkey);
    _subkeySeqCache[subkey] = valueData.seq;
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
    newValue = await _crypto.encrypt(newValue, subkey);

    // Set the new data if possible
    var valueData = await _routingContext.setDHTValue(
        _recordDescriptor.key, subkey, newValue);
    if (valueData == null) {
      // Get the data to check its sequence number
      valueData = await _routingContext.getDHTValue(
          _recordDescriptor.key, subkey, false);
      assert(valueData != null, "can't get value that was just set");
      _subkeySeqCache[subkey] = valueData!.seq;
      return null;
    }
    _subkeySeqCache[subkey] = valueData.seq;
    return valueData.data;
  }

  Future<void> eventualWriteBytes(Uint8List newValue, {int subkey = -1}) async {
    subkey = subkeyOrDefault(subkey);
    newValue = await _crypto.encrypt(newValue, subkey);

    ValueData? valueData;
    do {
      // Set the new data
      valueData = await _routingContext.setDHTValue(
          _recordDescriptor.key, subkey, newValue);

      // Repeat if newer data on the network was found
    } while (valueData != null);

    // Get the data to check its sequence number
    valueData =
        await _routingContext.getDHTValue(_recordDescriptor.key, subkey, false);
    assert(valueData != null, "can't get value that was just set");
    _subkeySeqCache[subkey] = valueData!.seq;
  }

  Future<void> eventualUpdateBytes(
      Future<Uint8List> Function(Uint8List oldValue) update,
      {int subkey = -1}) async {
    subkey = subkeyOrDefault(subkey);
    // Get existing identity key, do not allow force refresh here
    // because if we need a refresh the setDHTValue will fail anyway
    var valueData =
        await _routingContext.getDHTValue(_recordDescriptor.key, subkey, false);
    // Ensure it exists already
    if (valueData == null) {
      throw const FormatException('value does not exist');
    }
    do {
      // Update cache
      _subkeySeqCache[subkey] = valueData!.seq;

      // Update the data
      final oldData = await _crypto.decrypt(valueData.data, subkey);
      final updatedData = await update(oldData);
      final newData = await _crypto.encrypt(updatedData, subkey);

      // Set it back
      valueData = await _routingContext.setDHTValue(
          _recordDescriptor.key, subkey, newData);

      // Repeat if newer data on the network was found
    } while (valueData != null);

    // Get the data to check its sequence number
    valueData =
        await _routingContext.getDHTValue(_recordDescriptor.key, subkey, false);
    assert(valueData != null, "can't get value that was just set");
    _subkeySeqCache[subkey] = valueData!.seq;
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
          T Function(dynamic) fromJson, Future<T> Function(T) update,
          {int subkey = -1}) =>
      eventualUpdateBytes(jsonUpdate(fromJson, update), subkey: subkey);

  Future<void> eventualUpdateProtobuf<T extends GeneratedMessage>(
          T Function(List<int>) fromBuffer, Future<T> Function(T) update,
          {int subkey = -1}) =>
      eventualUpdateBytes(protobufUpdate(fromBuffer, update), subkey: subkey);
}
