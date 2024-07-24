import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'account_record_info.dart';

part 'identity.freezed.dart';
part 'identity.g.dart';

/// Identity points to accounts associated with this IdentityInstance
/// accountRecords field has a map of bundle id or uuid to account key pairs
/// DHT Schema: DFLT(1)
/// DHT Key (Private): IdentityInstance.recordKey
/// DHT Owner Key: IdentityInstance.publicKey
/// DHT Secret: IdentityInstance Secret Key (stored encrypted with unlock code
///                                          in local table store)
@freezed
class Identity with _$Identity {
  const factory Identity({
    // Top level account keys and secrets
    required IMap<String, ISet<AccountRecordInfo>> accountRecords,
  }) = _Identity;

  factory Identity.fromJson(dynamic json) =>
      _$IdentityFromJson(json as Map<String, dynamic>);
}
