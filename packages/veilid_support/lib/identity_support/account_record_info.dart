import 'package:freezed_annotation/freezed_annotation.dart';

import '../veilid_support.dart';

part 'account_record_info.freezed.dart';
part 'account_record_info.g.dart';

/// AccountRecordInfo is the key and owner info for the account dht record that
/// is stored in the identity instance record
@freezed
sealed class AccountRecordInfo with _$AccountRecordInfo {
  const factory AccountRecordInfo({
    // Top level account keys and secrets
    required OwnedDHTRecordPointer accountRecord,
  }) = _AccountRecordInfo;

  factory AccountRecordInfo.fromJson(dynamic json) =>
      _$AccountRecordInfoFromJson(json as Map<String, dynamic>);
}
