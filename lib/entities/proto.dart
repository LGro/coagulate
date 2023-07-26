import 'dart:typed_data';

import 'package:veilid/veilid.dart';

import 'proto/veilidchat.pb.dart' as proto;

export 'proto/veilidchat.pb.dart';

/// CryptoKey protobuf marshaling
///
extension CryptoKeyProto on CryptoKey {
  proto.CryptoKey toProto() {
    final b = decode();
    final out = proto.CryptoKey();
    out.u0 = b[0];
    out.u1 = b[1];
    out.u2 = b[2];
    out.u3 = b[3];
    out.u4 = b[4];
    out.u5 = b[5];
    out.u6 = b[6];
    out.u7 = b[7];
    return out;
  }

  static CryptoKey fromProto(proto.CryptoKey p) {
    final b = Uint8List(8);
    b[0] = p.u0;
    b[1] = p.u1;
    b[2] = p.u2;
    b[3] = p.u3;
    b[4] = p.u4;
    b[5] = p.u5;
    b[6] = p.u6;
    b[7] = p.u7;
    return CryptoKey.fromBytes(b);
  }
}

/// Signature protobuf marshaling
///
extension SignatureProto on Signature {
  proto.Signature toProto() {
    final b = decode();
    final out = proto.Signature();
    out.u0 = b[0];
    out.u1 = b[1];
    out.u2 = b[2];
    out.u3 = b[3];
    out.u4 = b[4];
    out.u5 = b[5];
    out.u6 = b[6];
    out.u7 = b[7];
    out.u8 = b[8];
    out.u9 = b[9];
    out.u10 = b[10];
    out.u11 = b[11];
    out.u12 = b[12];
    out.u13 = b[13];
    out.u14 = b[14];
    out.u15 = b[15];
    return out;
  }

  static Signature fromProto(proto.Signature p) {
    final b = Uint8List(16);
    b[0] = p.u0;
    b[1] = p.u1;
    b[2] = p.u2;
    b[3] = p.u3;
    b[4] = p.u4;
    b[5] = p.u5;
    b[6] = p.u6;
    b[7] = p.u7;
    b[8] = p.u8;
    b[9] = p.u9;
    b[10] = p.u10;
    b[11] = p.u11;
    b[12] = p.u12;
    b[13] = p.u13;
    b[14] = p.u14;
    b[15] = p.u15;
    return Signature.fromBytes(b);
  }
}

/// Nonce protobuf marshaling
///
extension NonceProto on Nonce {
  proto.Signature toProto() {
    final b = decode();
    final out = proto.Signature();
    out.u0 = b[0];
    out.u1 = b[1];
    out.u2 = b[2];
    out.u3 = b[3];
    out.u4 = b[4];
    out.u5 = b[5];
    return out;
  }

  static Nonce fromProto(proto.Nonce p) {
    final b = Uint8List(6);
    b[0] = p.u0;
    b[1] = p.u1;
    b[2] = p.u2;
    b[3] = p.u3;
    b[4] = p.u4;
    b[5] = p.u5;
    return Nonce.fromBytes(b);
  }
}

/// TypedKey protobuf marshaling
///
extension TypedKeyProto on TypedKey {
  proto.TypedKey toProto() {
    final out = proto.TypedKey();
    out.kind = kind;
    out.value = value.toProto();
    return out;
  }

  static TypedKey fromProto(proto.TypedKey p) => TypedKey(kind: p.kind, value: CryptoKeyProto.fromProto(p.value));
}
