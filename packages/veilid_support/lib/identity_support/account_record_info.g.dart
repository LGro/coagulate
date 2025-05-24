// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_record_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AccountRecordInfo _$AccountRecordInfoFromJson(Map<String, dynamic> json) =>
    _AccountRecordInfo(
      accountRecord: OwnedDHTRecordPointer.fromJson(json['account_record']),
    );

Map<String, dynamic> _$AccountRecordInfoToJson(_AccountRecordInfo instance) =>
    <String, dynamic>{
      'account_record': instance.accountRecord.toJson(),
    };
