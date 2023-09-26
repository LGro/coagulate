import 'dart:typed_data';

import '../../proto/veilid.pb.dart' as proto;
import '../veilid_support.dart';

export '../../proto/veilid.pb.dart';
export '../../proto/veilid.pbenum.dart';
export '../../proto/veilid.pbjson.dart';
export '../../proto/veilid.pbserver.dart';

/// CryptoKey protobuf marshaling
///
extension CryptoKeyProto on CryptoKey {
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

  static CryptoKey fromProto(proto.CryptoKey p) {
    final b = ByteData(32)
      ..setUint32(0 * 4, p.u0)
      ..setUint32(1 * 4, p.u1)
      ..setUint32(2 * 4, p.u2)
      ..setUint32(3 * 4, p.u3)
      ..setUint32(4 * 4, p.u4)
      ..setUint32(5 * 4, p.u5)
      ..setUint32(6 * 4, p.u6)
      ..setUint32(7 * 4, p.u7);
    return CryptoKey.fromBytes(Uint8List.view(b.buffer));
  }
}

/// Signature protobuf marshaling
///
extension SignatureProto on Signature {
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

  static Signature fromProto(proto.Signature p) {
    final b = ByteData(64)
      ..setUint32(0 * 4, p.u0)
      ..setUint32(1 * 4, p.u1)
      ..setUint32(2 * 4, p.u2)
      ..setUint32(3 * 4, p.u3)
      ..setUint32(4 * 4, p.u4)
      ..setUint32(5 * 4, p.u5)
      ..setUint32(6 * 4, p.u6)
      ..setUint32(7 * 4, p.u7)
      ..setUint32(8 * 4, p.u8)
      ..setUint32(9 * 4, p.u9)
      ..setUint32(10 * 4, p.u10)
      ..setUint32(11 * 4, p.u11)
      ..setUint32(12 * 4, p.u12)
      ..setUint32(13 * 4, p.u13)
      ..setUint32(14 * 4, p.u14)
      ..setUint32(15 * 4, p.u15);
    return Signature.fromBytes(Uint8List.view(b.buffer));
  }
}

/// Nonce protobuf marshaling
///
extension NonceProto on Nonce {
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

  static Nonce fromProto(proto.Nonce p) {
    final b = ByteData(24)
      ..setUint32(0 * 4, p.u0)
      ..setUint32(1 * 4, p.u1)
      ..setUint32(2 * 4, p.u2)
      ..setUint32(3 * 4, p.u3)
      ..setUint32(4 * 4, p.u4)
      ..setUint32(5 * 4, p.u5);
    return Nonce.fromBytes(Uint8List.view(b.buffer));
  }
}

/// TypedKey protobuf marshaling
///
extension TypedKeyProto on TypedKey {
  proto.TypedKey toProto() {
    final out = proto.TypedKey()
      ..kind = kind
      ..value = value.toProto();
    return out;
  }

  static TypedKey fromProto(proto.TypedKey p) =>
      TypedKey(kind: p.kind, value: CryptoKeyProto.fromProto(p.value));
}

/// KeyPair protobuf marshaling
///
extension KeyPairProto on KeyPair {
  proto.KeyPair toProto() {
    final out = proto.KeyPair()
      ..key = key.toProto()
      ..secret = secret.toProto();
    return out;
  }

  static KeyPair fromProto(proto.KeyPair p) => KeyPair(
      key: CryptoKeyProto.fromProto(p.key),
      secret: CryptoKeyProto.fromProto(p.secret));
}
