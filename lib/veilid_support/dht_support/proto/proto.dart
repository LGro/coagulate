import '../../../proto/dht.pb.dart' as dhtproto;
import '../../proto/proto.dart' as veilidproto;
import '../dht_support.dart';

export '../../../proto/dht.pb.dart';
export '../../../proto/dht.pbenum.dart';
export '../../../proto/dht.pbjson.dart';
export '../../../proto/dht.pbserver.dart';
export '../../proto/proto.dart';

/// OwnedDHTRecordPointer protobuf marshaling
///
extension OwnedDHTRecordPointerProto on OwnedDHTRecordPointer {
  dhtproto.OwnedDHTRecordPointer toProto() {
    final out = dhtproto.OwnedDHTRecordPointer()
      ..recordKey = recordKey.toProto()
      ..owner = owner.toProto();
    return out;
  }

  static OwnedDHTRecordPointer fromProto(dhtproto.OwnedDHTRecordPointer p) =>
      OwnedDHTRecordPointer(
          recordKey: veilidproto.TypedKeyProto.fromProto(p.recordKey),
          owner: veilidproto.KeyPairProto.fromProto(p.owner));
}
