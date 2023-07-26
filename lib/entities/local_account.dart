import 'dart:typed_data';

import 'package:change_case/change_case.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:veilid/veilid.dart';
import 'identity.dart';

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

  String toJson() => name.toPascalCase();
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
    // The encrypted identity secret that goes with the identityPublicKey
    @Uint8ListJsonConverter() required Uint8List identitySecretKeyBytes,
    // The salt for the identity secret key encryption
    @Uint8ListJsonConverter() required Uint8List identitySecretSaltBytes,
    // The kind of encryption input used on the account
    required EncryptionKeyType encryptionKeyType,
    // If account is not hidden, password can be retrieved via
    required bool biometricsEnabled,
    // Keep account hidden unless account password is entered
    // (tries all hidden accounts with auth method (no biometrics))
    required bool hiddenAccount,
  }) = _LocalAccount;

  factory LocalAccount.fromJson(dynamic json) =>
      _$LocalAccountFromJson(json as Map<String, dynamic>);
}
