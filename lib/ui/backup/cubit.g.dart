// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BackupState _$BackupStateFromJson(Map<String, dynamic> json) => BackupState(
      status: $enumDecodeNullable(_$BackupStatusEnumMap, json['status']) ??
          BackupStatus.initial,
      dhtRecordKey: json['dht_record_key'] == null
          ? null
          : Typed<FixedEncodedString43>.fromJson(json['dht_record_key']),
      secret: json['secret'] == null
          ? null
          : FixedEncodedString43.fromJson(json['secret']),
    );

Map<String, dynamic> _$BackupStateToJson(BackupState instance) =>
    <String, dynamic>{
      'status': _$BackupStatusEnumMap[instance.status]!,
      'dht_record_key': instance.dhtRecordKey?.toJson(),
      'secret': instance.secret?.toJson(),
    };

const _$BackupStatusEnumMap = {
  BackupStatus.initial: 'initial',
  BackupStatus.success: 'success',
  BackupStatus.create: 'create',
  BackupStatus.failure: 'failure',
};
