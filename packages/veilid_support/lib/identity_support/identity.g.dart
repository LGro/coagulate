// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
