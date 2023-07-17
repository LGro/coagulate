// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_AccountOwnerInfo _$$_AccountOwnerInfoFromJson(Map<String, dynamic> json) =>
    _$_AccountOwnerInfo(
      accountKeyPairs: (json['account_key_pairs'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, TypedKeyPair.fromJson(e)),
      ),
    );

Map<String, dynamic> _$$_AccountOwnerInfoToJson(_$_AccountOwnerInfo instance) =>
    <String, dynamic>{
      'account_key_pairs':
          instance.accountKeyPairs.map((k, e) => MapEntry(k, e.toJson())),
    };

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
      identityRecordKey:
          Typed<FixedEncodedString43>.fromJson(json['identity_record_key']),
      identityPublicKey:
          FixedEncodedString43.fromJson(json['identity_public_key']),
      masterRecordKey:
          Typed<FixedEncodedString43>.fromJson(json['master_record_key']),
      masterPublicKey: FixedEncodedString43.fromJson(json['master_public_key']),
      identitySignature:
          FixedEncodedString86.fromJson(json['identity_signature']),
      masterSignature: FixedEncodedString86.fromJson(json['master_signature']),
    );

Map<String, dynamic> _$$_IdentityMasterToJson(_$_IdentityMaster instance) =>
    <String, dynamic>{
      'identity_record_key': instance.identityRecordKey.toJson(),
      'identity_public_key': instance.identityPublicKey.toJson(),
      'master_record_key': instance.masterRecordKey.toJson(),
      'master_public_key': instance.masterPublicKey.toJson(),
      'identity_signature': instance.identitySignature.toJson(),
      'master_signature': instance.masterSignature.toJson(),
    };
