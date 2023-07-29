import 'dart:typed_data';

import 'package:protobuf/protobuf.dart';
import 'package:veilid/veilid.dart';

import '../tools/tools.dart';
import 'veilid_support.dart';

class DHTList {
  DHTList({required DHTRecord dhtRecord}) : _dhtRecord = dhtRecord;

  final DHTRecord _dhtRecord;

  static Future<DHTList> create(VeilidRoutingContext dhtctx,
      {DHTRecordCrypto? crypto}) async {
    final dhtRecord = await DHTRecord.create(dhtctx, crypto: crypto);
    final dhtList = DHTList(dhtRecord: dhtRecord);
    return dhtList;
  }

  static Future<DHTList> openRead(
      VeilidRoutingContext dhtctx, TypedKey dhtRecordKey,
      {DHTRecordCrypto? crypto}) async {
    final dhtRecord =
        await DHTRecord.openRead(dhtctx, dhtRecordKey, crypto: crypto);
    final dhtList = DHTList(dhtRecord: dhtRecord);
    return dhtList;
  }

  static Future<DHTList> openWrite(
    VeilidRoutingContext dhtctx,
    TypedKey dhtRecordKey,
    KeyPair writer, {
    DHTRecordCrypto? crypto,
  }) async {
    final dhtRecord =
        await DHTRecord.openWrite(dhtctx, dhtRecordKey, writer, crypto: crypto);
    final dhtList = DHTList(dhtRecord: dhtRecord);
    return dhtList;
  }

  ////////////////////////////////////////////////////////////////
}
