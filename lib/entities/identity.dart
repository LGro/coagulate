import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:veilid/veilid.dart';

part 'identity.freezed.dart';
part 'identity.g.dart';

// Identity Key points to accounts associated with this identity
// accounts field has a map of service name or uuid to account key pairs
// DHT Schema: DFLT(1)
// DHT Key (Private): identityPublicKey
// DHT Secret: identitySecretKey (stored encrypted with unlock code in local table store)
@freezed
class Identity with _$Identity {
  const factory Identity({
    // Top level account keys and secrets
    required Map<String, TypedKeyPair> accountKeyPairs,
  }) = _Identity;

  factory Identity.fromJson(Map<String, dynamic> json) =>
      _$IdentityFromJson(json);
}

// Identity Master key structure for created account
// Master key allows for regeneration of identity DHT record
// Bidirectional Master<->Identity signature allows for
// chain of identity ownership for account recovery process
//
// Backed by a DHT key at masterPublicKey, the secret is kept
// completely offline and only written to upon account recovery
//
// DHT Schema: DFLT(1)
// DHT Key (Public): masterPublicKey
// DHT Secret: masterSecretKey (kept offline)
// Encryption: None
@freezed
class IdentityMaster with _$IdentityMaster {
  const factory IdentityMaster(
      {required TypedKey identityPublicKey,
      required TypedKey masterPublicKey,
      required Signature identitySignature,
      required Signature masterSignature}) = _IdentityMaster;

  factory IdentityMaster.fromJson(Map<String, dynamic> json) =>
      _$IdentityMasterFromJson(json);
}
