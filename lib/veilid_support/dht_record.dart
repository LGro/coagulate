import 'dart:typed_data';

import 'package:protobuf/protobuf.dart';
import 'package:veilid/veilid.dart';

import 'veilid_support.dart';
import '../tools/tools.dart';

class DHTRecord {
  final VeilidRoutingContext _dhtctx;
  final DHTRecordDescriptor _recordDescriptor;
  final int _defaultSubkey;
  final KeyPair? _writer;
  DHTRecordCrypto _crypto;

  static Future<DHTRecord> create(VeilidRoutingContext dhtctx,
      {DHTSchema schema = const DHTSchema.dflt(oCnt: 1),
      int defaultSubkey = 0,
      DHTRecordCrypto? crypto}) async {
    DHTRecordDescriptor recordDescriptor = await dhtctx.createDHTRecord(schema);

    final rec = DHTRecord(
        dhtctx: dhtctx,
        recordDescriptor: recordDescriptor,
        defaultSubkey: defaultSubkey,
        writer: recordDescriptor.ownerKeyPair(),
        crypto: crypto ??
            await DHTRecordCryptoPrivate.fromTypedKeyPair(
                recordDescriptor.ownerTypedKeyPair()!));

    return rec;
  }

  static Future<DHTRecord> openRead(
      VeilidRoutingContext dhtctx, TypedKey recordKey,
      {int defaultSubkey = 0, DHTRecordCrypto? crypto}) async {
    DHTRecordDescriptor recordDescriptor =
        await dhtctx.openDHTRecord(recordKey, null);
    final rec = DHTRecord(
        dhtctx: dhtctx,
        recordDescriptor: recordDescriptor,
        defaultSubkey: defaultSubkey,
        writer: null,
        crypto: crypto ?? const DHTRecordCryptoPublic());

    return rec;
  }

  static Future<DHTRecord> openWrite(
    VeilidRoutingContext dhtctx,
    TypedKey recordKey,
    KeyPair writer, {
    int defaultSubkey = 0,
    DHTRecordCrypto? crypto,
  }) async {
    DHTRecordDescriptor recordDescriptor =
        await dhtctx.openDHTRecord(recordKey, writer);
    final rec = DHTRecord(
        dhtctx: dhtctx,
        recordDescriptor: recordDescriptor,
        defaultSubkey: defaultSubkey,
        writer: writer,
        crypto: crypto ??
            await DHTRecordCryptoPrivate.fromTypedKeyPair(
                TypedKeyPair.fromKeyPair(recordKey.kind, writer)));
    return rec;
  }

  DHTRecord(
      {required VeilidRoutingContext dhtctx,
      required DHTRecordDescriptor recordDescriptor,
      int defaultSubkey = 0,
      KeyPair? writer,
      DHTRecordCrypto crypto = const DHTRecordCryptoPublic()})
      : _dhtctx = dhtctx,
        _recordDescriptor = recordDescriptor,
        _defaultSubkey = defaultSubkey,
        _writer = writer,
        _crypto = crypto;

  int subkeyOrDefault(int subkey) => (subkey == -1) ? _defaultSubkey : subkey;

  TypedKey key() {
    return _recordDescriptor.key;
  }

  PublicKey owner() {
    return _recordDescriptor.owner;
  }

  KeyPair? ownerKeyPair() {
    return _recordDescriptor.ownerKeyPair();
  }

  KeyPair? writer() {
    return _writer;
  }

  void setCrypto(DHTRecordCrypto crypto) {
    _crypto = crypto;
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
    subkey = subkeyOrDefault(subkey);
    ValueData? valueData =
        await _dhtctx.getDHTValue(_recordDescriptor.key, subkey, false);
    if (valueData == null) {
      return null;
    }
    return _crypto.decrypt(valueData.data, subkey);
  }

  Future<T?> getJson<T>(T Function(Map<String, dynamic>) fromJson,
      {int subkey = -1, bool forceRefresh = false}) async {
    final data = await get(subkey: subkey, forceRefresh: forceRefresh);
    if (data == null) {
      return null;
    }
    return jsonDecodeBytes(fromJson, data);
  }

  Future<void> eventualWriteBytes(Uint8List newValue, {int subkey = -1}) async {
    subkey = subkeyOrDefault(subkey);
    newValue = await _crypto.encrypt(newValue, subkey);
    // Get existing identity key
    ValueData? valueData;
    do {
      // Ensure it exists already
      if (valueData == null) {
        throw const FormatException("value does not exist");
      }

      // Set the new data
      valueData =
          await _dhtctx.setDHTValue(_recordDescriptor.key, subkey, newValue);

      // Repeat if newer data on the network was found
    } while (valueData != null);
  }

  Future<void> eventualUpdateBytes(
      Future<Uint8List> Function(Uint8List oldValue) update,
      {int subkey = -1}) async {
    subkey = subkeyOrDefault(subkey);
    // Get existing identity key
    ValueData? valueData =
        await _dhtctx.getDHTValue(_recordDescriptor.key, subkey, false);
    do {
      // Ensure it exists already
      if (valueData == null) {
        throw const FormatException("value does not exist");
      }

      // Update the data
      final oldData = await _crypto.decrypt(valueData.data, subkey);
      final updatedData = await update(oldData);
      final newData = await _crypto.encrypt(updatedData, subkey);

      // Set it back
      valueData =
          await _dhtctx.setDHTValue(_recordDescriptor.key, subkey, newData);

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
