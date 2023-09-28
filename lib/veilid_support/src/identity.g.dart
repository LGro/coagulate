// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AccountRecordInfoImpl _$$AccountRecordInfoImplFromJson(
        Map<String, dynamic> json) =>
    _$AccountRecordInfoImpl(
      accountRecord: OwnedDHTRecordPointer.fromJson(json['account_record']),
    );

Map<String, dynamic> _$$AccountRecordInfoImplToJson(
        _$AccountRecordInfoImpl instance) =>
    <String, dynamic>{
      'account_record': instance.accountRecord.toJson(),
    };

_$IdentityImpl _$$IdentityImplFromJson(Map<String, dynamic> json) =>
    _$IdentityImpl(
      accountRecords: IMap<String, ISet<AccountRecordInfo>>.fromJson(
          json['account_records'] as Map<String, dynamic>,
          (value) => value as String,
          (value) => ISet<AccountRecordInfo>.fromJson(
              value, (value) => AccountRecordInfo.fromJson(value))),
    );

Map<String, dynamic> _$$IdentityImplToJson(_$IdentityImpl instance) =>
    <String, dynamic>{
      'account_records': instance.accountRecords.toJson(
        (value) => value,
        (value) => value.toJson(
          (value) => value.toJson(),
        ),
      ),
    };

_$IdentityMasterImpl _$$IdentityMasterImplFromJson(Map<String, dynamic> json) =>
    _$IdentityMasterImpl(
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

Map<String, dynamic> _$$IdentityMasterImplToJson(
        _$IdentityMasterImpl instance) =>
    <String, dynamic>{
      'identity_record_key': instance.identityRecordKey.toJson(),
      'identity_public_key': instance.identityPublicKey.toJson(),
      'master_record_key': instance.masterRecordKey.toJson(),
      'master_public_key': instance.masterPublicKey.toJson(),
      'identity_signature': instance.identitySignature.toJson(),
      'master_signature': instance.masterSignature.toJson(),
    };
