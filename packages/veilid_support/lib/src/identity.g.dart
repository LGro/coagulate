// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AccountRecordInfoImpl _$$AccountRecordInfoImplFromJson(
        Map<String, dynamic> json) =>
    _$AccountRecordInfoImpl(
      accountRecord: OwnedDHTRecordPointer.fromJson(json['accountRecord']),
    );

Map<String, dynamic> _$$AccountRecordInfoImplToJson(
        _$AccountRecordInfoImpl instance) =>
    <String, dynamic>{
      'accountRecord': instance.accountRecord,
    };

_$IdentityImpl _$$IdentityImplFromJson(Map<String, dynamic> json) =>
    _$IdentityImpl(
      accountRecords: IMap<String, ISet<AccountRecordInfo>>.fromJson(
          json['accountRecords'] as Map<String, dynamic>,
          (value) => value as String,
          (value) => ISet<AccountRecordInfo>.fromJson(
              value, (value) => AccountRecordInfo.fromJson(value))),
    );

Map<String, dynamic> _$$IdentityImplToJson(_$IdentityImpl instance) =>
    <String, dynamic>{
      'accountRecords': instance.accountRecords.toJson(
        (value) => value,
        (value) => value.toJson(
          (value) => value,
        ),
      ),
    };

_$IdentityMasterImpl _$$IdentityMasterImplFromJson(Map<String, dynamic> json) =>
    _$IdentityMasterImpl(
      identityRecordKey:
          Typed<FixedEncodedString43>.fromJson(json['identityRecordKey']),
      identityPublicKey:
          FixedEncodedString43.fromJson(json['identityPublicKey']),
      masterRecordKey:
          Typed<FixedEncodedString43>.fromJson(json['masterRecordKey']),
      masterPublicKey: FixedEncodedString43.fromJson(json['masterPublicKey']),
      identitySignature:
          FixedEncodedString86.fromJson(json['identitySignature']),
      masterSignature: FixedEncodedString86.fromJson(json['masterSignature']),
    );

Map<String, dynamic> _$$IdentityMasterImplToJson(
        _$IdentityMasterImpl instance) =>
    <String, dynamic>{
      'identityRecordKey': instance.identityRecordKey,
      'identityPublicKey': instance.identityPublicKey,
      'masterRecordKey': instance.masterRecordKey,
      'masterPublicKey': instance.masterPublicKey,
      'identitySignature': instance.identitySignature,
      'masterSignature': instance.masterSignature,
    };
