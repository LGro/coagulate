// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identity_instance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IdentityInstanceImpl _$$IdentityInstanceImplFromJson(
        Map<String, dynamic> json) =>
    _$IdentityInstanceImpl(
      recordKey: Typed<FixedEncodedString43>.fromJson(json['record_key']),
      publicKey: FixedEncodedString43.fromJson(json['public_key']),
      encryptedSecretKey:
          const Uint8ListJsonConverter().fromJson(json['encrypted_secret_key']),
      superSignature: FixedEncodedString86.fromJson(json['super_signature']),
      signature: FixedEncodedString86.fromJson(json['signature']),
    );

Map<String, dynamic> _$$IdentityInstanceImplToJson(
        _$IdentityInstanceImpl instance) =>
    <String, dynamic>{
      'record_key': instance.recordKey.toJson(),
      'public_key': instance.publicKey.toJson(),
      'encrypted_secret_key':
          const Uint8ListJsonConverter().toJson(instance.encryptedSecretKey),
      'super_signature': instance.superSignature.toJson(),
      'signature': instance.signature.toJson(),
    };
