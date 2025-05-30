// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SettingsState _$SettingsStateFromJson(Map<String, dynamic> json) =>
    SettingsState(
      darkMode: json['dark_mode'] as bool,
      mapProvider: $enumDecode(_$MapProviderEnumMap, json['map_provider']),
      autoAddressResolution: json['auto_address_resolution'] as bool,
      status: $enumDecode(_$SettingsStatusEnumMap, json['status']),
      message: json['message'] as String,
    );

Map<String, dynamic> _$SettingsStateToJson(SettingsState instance) =>
    <String, dynamic>{
      'status': _$SettingsStatusEnumMap[instance.status]!,
      'message': instance.message,
      'dark_mode': instance.darkMode,
      'map_provider': _$MapProviderEnumMap[instance.mapProvider]!,
      'auto_address_resolution': instance.autoAddressResolution,
    };

const _$MapProviderEnumMap = {
  MapProvider.osm: 'osm',
  MapProvider.maptiler: 'maptiler',
  MapProvider.custom: 'custom',
};

const _$SettingsStatusEnumMap = {
  SettingsStatus.initial: 'initial',
  SettingsStatus.success: 'success',
  SettingsStatus.create: 'create',
  SettingsStatus.pick: 'pick',
};
