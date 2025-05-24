import 'dart:typed_data';

import '../src/dynamic_debug.dart';
import '../veilid_support.dart' as veilid;
import 'veilid.pb.dart' as proto;

export 'veilid.pb.dart';
export 'veilid.pbenum.dart';
export 'veilid.pbjson.dart';
export 'veilid.pbserver.dart';

/// CryptoKey protobuf marshaling
///
extension CryptoKeyProto on veilid.CryptoKey {
  proto.CryptoKey toProto() {
    final b = decode().buffer.asByteData();
    final out = proto.CryptoKey()
      ..u0 = b.getUint32(0 * 4)
      ..u1 = b.getUint32(1 * 4)
      ..u2 = b.getUint32(2 * 4)
      ..u3 = b.getUint32(3 * 4)
      ..u4 = b.getUint32(4 * 4)
      ..u5 = b.getUint32(5 * 4)
      ..u6 = b.getUint32(6 * 4)
      ..u7 = b.getUint32(7 * 4);
    return out;
  }
}

extension ProtoCryptoKey on proto.CryptoKey {
  veilid.CryptoKey toVeilid() {
    final b = ByteData(32)
      ..setUint32(0 * 4, u0)
      ..setUint32(1 * 4, u1)
      ..setUint32(2 * 4, u2)
      ..setUint32(3 * 4, u3)
      ..setUint32(4 * 4, u4)
      ..setUint32(5 * 4, u5)
      ..setUint32(6 * 4, u6)
      ..setUint32(7 * 4, u7);
    return veilid.CryptoKey.fromBytes(Uint8List.view(b.buffer));
  }
}

/// Signature protobuf marshaling
///
extension SignatureProto on veilid.Signature {
  proto.Signature toProto() {
    final b = decode().buffer.asByteData();
    final out = proto.Signature()
      ..u0 = b.getUint32(0 * 4)
      ..u1 = b.getUint32(1 * 4)
      ..u2 = b.getUint32(2 * 4)
      ..u3 = b.getUint32(3 * 4)
      ..u4 = b.getUint32(4 * 4)
      ..u5 = b.getUint32(5 * 4)
      ..u6 = b.getUint32(6 * 4)
      ..u7 = b.getUint32(7 * 4)
      ..u8 = b.getUint32(8 * 4)
      ..u9 = b.getUint32(9 * 4)
      ..u10 = b.getUint32(10 * 4)
      ..u11 = b.getUint32(11 * 4)
      ..u12 = b.getUint32(12 * 4)
      ..u13 = b.getUint32(13 * 4)
      ..u14 = b.getUint32(14 * 4)
      ..u15 = b.getUint32(15 * 4);
    return out;
  }
}

extension ProtoSignature on proto.Signature {
  veilid.Signature toVeilid() {
    final b = ByteData(64)
      ..setUint32(0 * 4, u0)
      ..setUint32(1 * 4, u1)
      ..setUint32(2 * 4, u2)
      ..setUint32(3 * 4, u3)
      ..setUint32(4 * 4, u4)
      ..setUint32(5 * 4, u5)
      ..setUint32(6 * 4, u6)
      ..setUint32(7 * 4, u7)
      ..setUint32(8 * 4, u8)
      ..setUint32(9 * 4, u9)
      ..setUint32(10 * 4, u10)
      ..setUint32(11 * 4, u11)
      ..setUint32(12 * 4, u12)
      ..setUint32(13 * 4, u13)
      ..setUint32(14 * 4, u14)
      ..setUint32(15 * 4, u15);
    return veilid.Signature.fromBytes(Uint8List.view(b.buffer));
  }
}

/// Nonce protobuf marshaling
///
extension NonceProto on veilid.Nonce {
  proto.Nonce toProto() {
    final b = decode().buffer.asByteData();
    final out = proto.Nonce()
      ..u0 = b.getUint32(0 * 4)
      ..u1 = b.getUint32(1 * 4)
      ..u2 = b.getUint32(2 * 4)
      ..u3 = b.getUint32(3 * 4)
      ..u4 = b.getUint32(4 * 4)
      ..u5 = b.getUint32(5 * 4);
    return out;
  }
}

extension ProtoNonce on proto.Nonce {
  veilid.Nonce toVeilid() {
    final b = ByteData(24)
      ..setUint32(0 * 4, u0)
      ..setUint32(1 * 4, u1)
      ..setUint32(2 * 4, u2)
      ..setUint32(3 * 4, u3)
      ..setUint32(4 * 4, u4)
      ..setUint32(5 * 4, u5);
    return veilid.Nonce.fromBytes(Uint8List.view(b.buffer));
  }
}

/// TypedKey protobuf marshaling
///
extension TypedKeyProto on veilid.TypedKey {
  proto.TypedKey toProto() {
    final out = proto.TypedKey()
      ..kind = kind
      ..value = value.toProto();
    return out;
  }
}

extension ProtoTypedKey on proto.TypedKey {
  veilid.TypedKey toVeilid() =>
      veilid.TypedKey(kind: kind, value: value.toVeilid());
}

/// KeyPair protobuf marshaling
///
extension KeyPairProto on veilid.KeyPair {
  proto.KeyPair toProto() {
    final out = proto.KeyPair()
      ..key = key.toProto()
      ..secret = secret.toProto();
    return out;
  }
}

extension ProtoKeyPair on proto.KeyPair {
  veilid.KeyPair toVeilid() =>
      veilid.KeyPair(key: key.toVeilid(), secret: secret.toVeilid());
}

void registerVeilidProtoToDebug() {
  dynamic toDebug(dynamic protoObj) {
    if (protoObj is proto.CryptoKey) {
      return protoObj.toVeilid();
    }
    if (protoObj is proto.Signature) {
      return protoObj.toVeilid();
    }
    if (protoObj is proto.Nonce) {
      return protoObj.toVeilid();
    }
    if (protoObj is proto.TypedKey) {
      return protoObj.toVeilid();
    }
    if (protoObj is proto.KeyPair) {
      return protoObj.toVeilid();
    }
    return protoObj;
  }

  DynamicDebug.registerToDebug(toDebug);
}
