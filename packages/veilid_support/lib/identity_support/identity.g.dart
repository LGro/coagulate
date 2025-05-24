// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Identity _$IdentityFromJson(Map<String, dynamic> json) => _Identity(
      accountRecords: IMap<String, ISet<AccountRecordInfo>>.fromJson(
          json['account_records'] as Map<String, dynamic>,
          (value) => value as String,
          (value) => ISet<AccountRecordInfo>.fromJson(
              value, (value) => AccountRecordInfo.fromJson(value))),
    );

Map<String, dynamic> _$IdentityToJson(_Identity instance) => <String, dynamic>{
      'account_records': instance.accountRecords.toJson(
        (value) => value,
        (value) => value.toJson(
          (value) => value.toJson(),
        ),
      ),
    };
