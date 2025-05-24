import '../../proto/dht.pb.dart' as dhtproto;
import '../../proto/proto.dart' as veilidproto;
import '../../src/dynamic_debug.dart';
import '../dht_support.dart';

export '../../proto/dht.pb.dart';
export '../../proto/dht.pbenum.dart';
export '../../proto/dht.pbjson.dart';
export '../../proto/dht.pbserver.dart';
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
}

extension ProtoOwnedDHTRecordPointer on dhtproto.OwnedDHTRecordPointer {
  OwnedDHTRecordPointer toVeilid() => OwnedDHTRecordPointer(
      recordKey: recordKey.toVeilid(), owner: owner.toVeilid());
}

void registerVeilidDHTProtoToDebug() {
  dynamic toDebug(dynamic obj) {
    if (obj is dhtproto.OwnedDHTRecordPointer) {
      return {
        r'$runtimeType': obj.runtimeType,
        'recordKey': obj.recordKey,
        'owner': obj.owner,
      };
    }
    if (obj is dhtproto.DHTData) {
      return {
        r'$runtimeType': obj.runtimeType,
        'keys': obj.keys,
        'hash': obj.hash,
        'chunk': obj.chunk,
        'size': obj.size
      };
    }
    if (obj is dhtproto.DHTLog) {
      return {
        r'$runtimeType': obj.runtimeType,
        'head': obj.head,
        'tail': obj.tail,
        'stride': obj.stride,
      };
    }
    if (obj is dhtproto.DHTShortArray) {
      return {
        r'$runtimeType': obj.runtimeType,
        'keys': obj.keys,
        'index': obj.index,
        'seqs': obj.seqs,
      };
    }

    return obj;
  }

  DynamicDebug.registerToDebug(toDebug);
}
