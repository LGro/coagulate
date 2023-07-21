import 'dart:async';

import 'package:veilid/veilid.dart';
import 'dart:typed_data';
import 'tools.dart';

typedef DHTRecordEncryptionFactory = DHTRecordEncryption Function(DHTRecord);

abstract class DHTRecordEncryption {
  factory DHTRecordEncryption.private(DHTRecord record) {
    return _DHTRecordEncryptionPrivate(record);
  }
  factory DHTRecordEncryption.public(DHTRecord record) {
    return _DHTRecordEncryptionPublic(record);
  }

  FutureOr<Uint8List> encrypt(Uint8List data, int subkey);
  FutureOr<Uint8List> decrypt(Uint8List data, int subkey);
}

////////////////////////////////////
/// Private DHT Record: Encrypted with the owner's secret key
class _DHTRecordEncryptionPrivate implements DHTRecordEncryption {
  _DHTRecordEncryptionPrivate(DHTRecord record) {
    // xxx derive key from record
  }

  @override
  FutureOr<Uint8List> encrypt(Uint8List data, int subkey) {}

  @override
  FutureOr<Uint8List> decrypt(Uint8List data, int subkey) {
    //
  }
}

////////////////////////////////////
/// Public DHT Record: No encryption
class _DHTRecordEncryptionPublic implements DHTRecordEncryption {
  _DHTRecordEncryptionPublic(DHTRecord record) {
    //
  }

  @override
  FutureOr<Uint8List> encrypt(Uint8List data, int subkey) {
    return data;
  }

  @override
  FutureOr<Uint8List> decrypt(Uint8List data, int subkey) {
    return data;
  }
}
