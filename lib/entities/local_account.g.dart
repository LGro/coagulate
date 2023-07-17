// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_LocalAccount _$$_LocalAccountFromJson(Map<String, dynamic> json) =>
    _$_LocalAccount(
      identityMaster: IdentityMaster.fromJson(
          json['identity_master'] as Map<String, dynamic>),
      identitySecretKeyBytes: const Uint8ListJsonConverter()
          .fromJson(json['identity_secret_key_bytes'] as String),
      identitySecretSaltBytes: const Uint8ListJsonConverter()
          .fromJson(json['identity_secret_salt_bytes'] as String),
      encryptionKeyType:
          EncryptionKeyType.fromJson(json['encryption_key_type'] as String),
      biometricsEnabled: json['biometrics_enabled'] as bool,
      hiddenAccount: json['hidden_account'] as bool,
    );

Map<String, dynamic> _$$_LocalAccountToJson(_$_LocalAccount instance) =>
    <String, dynamic>{
      'identity_master': instance.identityMaster.toJson(),
      'identity_secret_key_bytes': const Uint8ListJsonConverter()
          .toJson(instance.identitySecretKeyBytes),
      'identity_secret_salt_bytes': const Uint8ListJsonConverter()
          .toJson(instance.identitySecretSaltBytes),
      'encryption_key_type': instance.encryptionKeyType.toJson(),
      'biometrics_enabled': instance.biometricsEnabled,
      'hidden_account': instance.hiddenAccount,
    };
