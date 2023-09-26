import 'dart:typed_data';

import 'package:change_case/change_case.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../proto/proto.dart' as proto;
import '../veilid_support/veilid_support.dart';

part 'local_account.freezed.dart';
part 'local_account.g.dart';

// Local account identitySecretKey is potentially encrypted with a key
// using the following mechanisms
// * None : no key, bytes are unencrypted
// * Pin : Code is a numeric pin (4-256 numeric digits) hashed with Argon2
// * Password: Code is a UTF-8 string that is hashed with Argon2
enum EncryptionKeyType {
  none,
  pin,
  password;

  factory EncryptionKeyType.fromJson(dynamic j) =>
      EncryptionKeyType.values.byName((j as String).toCamelCase());

  factory EncryptionKeyType.fromProto(proto.EncryptionKeyType p) {
    // ignore: exhaustive_cases
    switch (p) {
      case proto.EncryptionKeyType.ENCRYPTION_KEY_TYPE_NONE:
        return EncryptionKeyType.none;
      case proto.EncryptionKeyType.ENCRYPTION_KEY_TYPE_PIN:
        return EncryptionKeyType.pin;
      case proto.EncryptionKeyType.ENCRYPTION_KEY_TYPE_PASSWORD:
        return EncryptionKeyType.password;
    }
    throw StateError('unknown EncryptionKeyType enum value');
  }
  String toJson() => name.toPascalCase();
  proto.EncryptionKeyType toProto() => switch (this) {
        EncryptionKeyType.none =>
          proto.EncryptionKeyType.ENCRYPTION_KEY_TYPE_NONE,
        EncryptionKeyType.pin =>
          proto.EncryptionKeyType.ENCRYPTION_KEY_TYPE_PIN,
        EncryptionKeyType.password =>
          proto.EncryptionKeyType.ENCRYPTION_KEY_TYPE_PASSWORD,
      };
}

// Local Accounts are stored in a table locally and not backed by a DHT key
// and represents the accounts that have been added/imported
// on the current device.
// Stores a copy of the IdentityMaster associated with the account
// and the identitySecretKey optionally encrypted by an unlock code
// This is the root of the account information tree for VeilidChat
//
@freezed
class LocalAccount with _$LocalAccount {
  const factory LocalAccount({
    // The master key record for the account, containing the identityPublicKey
    required IdentityMaster identityMaster,
    // The encrypted identity secret that goes with
    // the identityPublicKey with appended salt
    @Uint8ListJsonConverter() required Uint8List identitySecretBytes,
    // The kind of encryption input used on the account
    required EncryptionKeyType encryptionKeyType,
    // If account is not hidden, password can be retrieved via
    required bool biometricsEnabled,
    // Keep account hidden unless account password is entered
    // (tries all hidden accounts with auth method (no biometrics))
    required bool hiddenAccount,
    // Display name for account until it is unlocked
    required String name,
  }) = _LocalAccount;

  factory LocalAccount.fromJson(dynamic json) =>
      _$LocalAccountFromJson(json as Map<String, dynamic>);
}
