import 'package:protobuf/protobuf.dart';
import 'package:veilid/veilid.dart';
import 'dart:typed_data';
import 'tools.dart';

class DHTRecord {
  final VeilidRoutingContext _dhtctx;
  final DHTRecordDescriptor _recordDescriptor;
  final int _defaultSubkey;

  static Future<DHTRecord> create(VeilidRoutingContext dhtctx,
      {DHTSchema schema = const DHTSchema.dflt(oCnt: 1),
      int defaultSubkey = 0,
      DHTRecordEncryption encrypt = DHTRecordEncryption.private}) async {
    DHTRecordDescriptor recordDescriptor = await dhtctx.createDHTRecord(schema);
    return DHTRecord(
        dhtctx: dhtctx,
        recordDescriptor: recordDescriptor,
        defaultSubkey: defaultSubkey);
  }

  static Future<DHTRecord> open(
      VeilidRoutingContext dhtctx, TypedKey recordKey, KeyPair? writer,
      {int defaultSubkey = 0,
      DHTRecordEncryption encrypt = DHTRecordEncryption.private}) async {
    DHTRecordDescriptor recordDescriptor =
        await dhtctx.openDHTRecord(recordKey, writer);
    return DHTRecord(
        dhtctx: dhtctx,
        recordDescriptor: recordDescriptor,
        defaultSubkey: defaultSubkey);
  }

  DHTRecord(
      {required VeilidRoutingContext dhtctx,
      required DHTRecordDescriptor recordDescriptor,
      int defaultSubkey = 0})
      : _dhtctx = dhtctx,
        _recordDescriptor = recordDescriptor,
        _defaultSubkey = defaultSubkey;

  int _subkey(int subkey) => (subkey == -1) ? _defaultSubkey : subkey;

  TypedKey key() {
    return _recordDescriptor.key;
  }

  PublicKey owner() {
    return _recordDescriptor.owner;
  }

  KeyPair? ownerKeyPair() {
    final ownerSecret = _recordDescriptor.ownerSecret;
    if (ownerSecret == null) {
      return null;
    }
    return KeyPair(key: _recordDescriptor.owner, secret: ownerSecret);
  }

  Future<void> close() async {
    await _dhtctx.closeDHTRecord(_recordDescriptor.key);
  }

  Future<void> delete() async {
    await _dhtctx.deleteDHTRecord(_recordDescriptor.key);
  }

  Future<T> scope<T>(Future<T> Function(DHTRecord) scopeFunction) async {
    try {
      return await scopeFunction(this);
    } finally {
      close();
    }
  }

  Future<T> deleteScope<T>(Future<T> Function(DHTRecord) scopeFunction) async {
    try {
      return await scopeFunction(this);
    } catch (_) {
      delete();
      rethrow;
    } finally {
      close();
    }
  }

  Future<Uint8List?> get({int subkey = -1, bool forceRefresh = false}) async {
    ValueData? valueData = await _dhtctx.getDHTValue(
        _recordDescriptor.key, _subkey(subkey), false);
    if (valueData == null) {
      return null;
    }
    return valueData.data;
  }

  Future<T?> getJson<T>(T Function(Map<String, dynamic>) fromJson,
      {int subkey = -1, bool forceRefresh = false}) async {
    ValueData? valueData = await _dhtctx.getDHTValue(
        _recordDescriptor.key, _subkey(subkey), false);
    if (valueData == null) {
      return null;
    }
    return valueData.readJsonData(fromJson);
  }

  Future<void> eventualWriteBytes(Uint8List newValue, {int subkey = -1}) async {
    // Get existing identity key
    ValueData? valueData;
    do {
      // Ensure it exists already
      if (valueData == null) {
        throw const FormatException("value does not exist");
      }

      // Set the new data
      valueData = await _dhtctx.setDHTValue(
          _recordDescriptor.key, _subkey(subkey), newValue);

      // Repeat if newer data on the network was found
    } while (valueData != null);
  }

  Future<void> eventualUpdateBytes(
      Future<Uint8List> Function(Uint8List oldValue) update,
      {int subkey = -1}) async {
    // Get existing identity key
    ValueData? valueData = await _dhtctx.getDHTValue(
        _recordDescriptor.key, _subkey(subkey), false);
    do {
      // Ensure it exists already
      if (valueData == null) {
        throw const FormatException("value does not exist");
      }

      // Update the data
      final newData = await update(valueData.data);

      // Set it back
      valueData = await _dhtctx.setDHTValue(
          _recordDescriptor.key, _subkey(subkey), newData);

      // Repeat if newer data on the network was found
    } while (valueData != null);
  }

  Future<void> eventualWriteJson<T>(T newValue, {int subkey = -1}) {
    return eventualWriteBytes(jsonEncodeBytes(newValue), subkey: subkey);
  }

  Future<void> eventualWriteProtobuf<T extends GeneratedMessage>(T newValue,
      {int subkey = -1}) {
    return eventualWriteBytes(newValue.writeToBuffer(), subkey: subkey);
  }

  Future<void> eventualUpdateJson<T>(
      T Function(Map<String, dynamic>) fromJson, Future<T> Function(T) update,
      {int subkey = -1}) {
    return eventualUpdateBytes(jsonUpdate(fromJson, update), subkey: subkey);
  }

  Future<void> eventualUpdateProtobuf<T extends GeneratedMessage>(
      T Function(List<int>) fromBuffer, Future<T> Function(T) update,
      {int subkey = -1}) {
    return eventualUpdateBytes(protobufUpdate(fromBuffer, update),
        subkey: subkey);
  }
}
