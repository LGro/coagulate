// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Identity _$$_IdentityFromJson(Map<String, dynamic> json) => _$_Identity(
      accountKeyPairs: (json['account_key_pairs'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, TypedKeyPair.fromJson(e)),
      ),
    );

Map<String, dynamic> _$$_IdentityToJson(_$_Identity instance) =>
    <String, dynamic>{
      'account_key_pairs':
          instance.accountKeyPairs.map((k, e) => MapEntry(k, e.toJson())),
    };

_$_IdentityMaster _$$_IdentityMasterFromJson(Map<String, dynamic> json) =>
    _$_IdentityMaster(
      identityPublicKey:
          Typed<FixedEncodedString43>.fromJson(json['identity_public_key']),
      masterPublicKey:
          Typed<FixedEncodedString43>.fromJson(json['master_public_key']),
      identitySignature:
          FixedEncodedString86.fromJson(json['identity_signature']),
      masterSignature: FixedEncodedString86.fromJson(json['master_signature']),
    );

Map<String, dynamic> _$$_IdentityMasterToJson(_$_IdentityMaster instance) =>
    <String, dynamic>{
      'identity_public_key': instance.identityPublicKey.toJson(),
      'master_public_key': instance.masterPublicKey.toJson(),
      'identity_signature': instance.identitySignature.toJson(),
      'master_signature': instance.masterSignature.toJson(),
    };
