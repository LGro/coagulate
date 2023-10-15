// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LocalAccountImpl _$$LocalAccountImplFromJson(Map<String, dynamic> json) =>
    _$LocalAccountImpl(
      identityMaster: IdentityMaster.fromJson(json['identity_master']),
      identitySecretBytes: const Uint8ListJsonConverter()
          .fromJson(json['identity_secret_bytes']),
      encryptionKeyType:
          EncryptionKeyType.fromJson(json['encryption_key_type']),
      biometricsEnabled: json['biometrics_enabled'] as bool,
      hiddenAccount: json['hidden_account'] as bool,
      name: json['name'] as String,
    );

Map<String, dynamic> _$$LocalAccountImplToJson(_$LocalAccountImpl instance) =>
    <String, dynamic>{
      'identity_master': instance.identityMaster.toJson(),
      'identity_secret_bytes':
          const Uint8ListJsonConverter().toJson(instance.identitySecretBytes),
      'encryption_key_type': instance.encryptionKeyType.toJson(),
      'biometrics_enabled': instance.biometricsEnabled,
      'hidden_account': instance.hiddenAccount,
      'name': instance.name,
    };
