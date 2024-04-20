// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SettingsState _$SettingsStateFromJson(Map<String, dynamic> json) =>
    SettingsState(
      status: $enumDecode(_$SettingsStatusEnumMap, json['status']),
      message: json['message'] as String,
    );

Map<String, dynamic> _$SettingsStateToJson(SettingsState instance) =>
    <String, dynamic>{
      'status': _$SettingsStatusEnumMap[instance.status]!,
      'message': instance.message,
    };

const _$SettingsStatusEnumMap = {
  SettingsStatus.initial: 'initial',
  SettingsStatus.success: 'success',
  SettingsStatus.create: 'create',
  SettingsStatus.pick: 'pick',
};
