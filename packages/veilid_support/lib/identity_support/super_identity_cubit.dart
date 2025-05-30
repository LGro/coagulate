import 'package:async_tools/async_tools.dart';

import '../veilid_support.dart';

typedef SuperIdentityState = AsyncValue<SuperIdentity>;

class SuperIdentityCubit extends DefaultDHTRecordCubit<SuperIdentity> {
  SuperIdentityCubit({required TypedKey superRecordKey})
      : super(
            open: () => _open(superRecordKey: superRecordKey),
            decodeState: (buf) => jsonDecodeBytes(SuperIdentity.fromJson, buf));

  static Future<DHTRecord> _open({required TypedKey superRecordKey}) async {
    final pool = DHTRecordPool.instance;

    return pool.openRecordRead(
      superRecordKey,
      debugName: 'SuperIdentityCubit::_open::SuperIdentityRecord',
    );
  }
}
