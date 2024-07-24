// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_record_info.dart';

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
