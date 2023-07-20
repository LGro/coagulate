import 'dart:async';

import 'package:veilid/veilid.dart';
import 'dart:typed_data';
import 'tools.dart';

abstract class DHTRecordEncryption {
  factory DHTRecordEncryption.private() {
    return DHTRecordEncryptionPrivate();
  }
  factory DHTRecordEncryption.public() {
    return DHTRecordEncryptionPublic();
  }

  FutureOr<Uint8List> encrypt(Uint8List data);
  FutureOr<Uint8List> decrypt(Uint8List data);
}

class DHTRecordEncryptionPrivate implements DHTRecordEncryption {
  DHTRecordEncryptionPrivate() {
    //
  }

  @override
  FutureOr<Uint8List> encrypt(Uint8List data) {
    //
  }

  @override
  FutureOr<Uint8List> decrypt(Uint8List data) {
    //
  }
}

class DHTRecordEncryptionPublic implements DHTRecordEncryption {
  DHTRecordEncryptionPublic() {
    //
  }

  @override
  FutureOr<Uint8List> encrypt(Uint8List data) {
    return data;
  }

  @override
  FutureOr<Uint8List> decrypt(Uint8List data) {
    return data;
  }
}
