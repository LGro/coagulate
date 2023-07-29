import 'dart:typed_data';

import 'package:protobuf/protobuf.dart';
import 'package:veilid/veilid.dart';

import '../entities/proto.dart' as proto;
import '../tools/tools.dart';
import 'veilid_support.dart';

class DHTRecord {
  DHTRecord(
      {required VeilidRoutingContext dhtctx,
      required DHTRecordDescriptor recordDescriptor,
      int defaultSubkey = 0,
      KeyPair? writer,
      this.crypto = const DHTRecordCryptoPublic()})
      : _dhtctx = dhtctx,
        _recordDescriptor = recordDescriptor,
        _defaultSubkey = defaultSubkey,
        _writer = writer;
  final VeilidRoutingContext _dhtctx;
  final DHTRecordDescriptor _recordDescriptor;
  final int _defaultSubkey;
  final KeyPair? _writer;
  DHTRecordCrypto crypto;

  static Future<DHTRecord> create(VeilidRoutingContext dhtctx,
      {DHTSchema schema = const DHTSchema.dflt(oCnt: 1),
      int defaultSubkey = 0,
      DHTRecordCrypto? crypto}) async {
    final recordDescriptor = await dhtctx.createDHTRecord(schema);

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
    final recordDescriptor = await dhtctx.openDHTRecord(recordKey, null);
    final rec = DHTRecord(
        dhtctx: dhtctx,
        recordDescriptor: recordDescriptor,
        defaultSubkey: defaultSubkey,
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
    final recordDescriptor = await dhtctx.openDHTRecord(recordKey, writer);
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

  int subkeyOrDefault(int subkey) => (subkey == -1) ? _defaultSubkey : subkey;

  TypedKey get key => _recordDescriptor.key;

  PublicKey get owner => _recordDescriptor.owner;

  KeyPair? get ownerKeyPair => _recordDescriptor.ownerKeyPair();

  KeyPair? get writer => _writer;

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
      await close();
    }
  }

  Future<T> deleteScope<T>(Future<T> Function(DHTRecord) scopeFunction) async {
    try {
      final out = await scopeFunction(this);
      await close();
      return out;
    } on Exception catch (_) {
      await delete();
      rethrow;
    }
  }

  Future<Uint8List?> get({int subkey = -1, bool forceRefresh = false}) async {
    subkey = subkeyOrDefault(subkey);
    final valueData =
        await _dhtctx.getDHTValue(_recordDescriptor.key, subkey, false);
    if (valueData == null) {
      return null;
    }
    return crypto.decrypt(valueData.data, subkey);
  }

  Future<T?> getJson<T>(T Function(dynamic) fromJson,
      {int subkey = -1, bool forceRefresh = false}) async {
    final data = await get(subkey: subkey, forceRefresh: forceRefresh);
    if (data == null) {
      return null;
    }
    return jsonDecodeBytes(fromJson, data);
  }

  Future<T?> getProtobuf<T extends GeneratedMessage>(
      T Function(List<int> i) fromBuffer,
      {int subkey = -1,
      bool forceRefresh = false}) async {
    final data = await get(subkey: subkey, forceRefresh: forceRefresh);
    if (data == null) {
      return null;
    }
    return fromBuffer(data.toList());
  }

  Future<void> eventualWriteBytes(Uint8List newValue, {int subkey = -1}) async {
    subkey = subkeyOrDefault(subkey);
    newValue = await crypto.encrypt(newValue, subkey);
    // Get existing identity key
    ValueData? valueData;
    do {
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
    var valueData =
        await _dhtctx.getDHTValue(_recordDescriptor.key, subkey, false);
    do {
      // Ensure it exists already
      if (valueData == null) {
        throw const FormatException('value does not exist');
      }

      // Update the data
      final oldData = await crypto.decrypt(valueData.data, subkey);
      final updatedData = await update(oldData);
      final newData = await crypto.encrypt(updatedData, subkey);

      // Set it back
      valueData =
          await _dhtctx.setDHTValue(_recordDescriptor.key, subkey, newData);

      // Repeat if newer data on the network was found
    } while (valueData != null);
  }

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
