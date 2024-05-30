// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SettingsState _$SettingsStateFromJson(Map<String, dynamic> json) =>
    SettingsState(
      backgroundPermission: $enumDecode(
          _$BackgroundRefreshPermissionStateEnumMap,
          json['background_permission']),
      darkMode: json['dark_mode'] as bool,
      mapProvider: json['map_provider'] as String,
      autoAddressResolution: json['auto_address_resolution'] as bool,
      status: $enumDecode(_$SettingsStatusEnumMap, json['status']),
      message: json['message'] as String,
    );

Map<String, dynamic> _$SettingsStateToJson(SettingsState instance) =>
    <String, dynamic>{
      'status': _$SettingsStatusEnumMap[instance.status]!,
      'message': instance.message,
      'background_permission': _$BackgroundRefreshPermissionStateEnumMap[
          instance.backgroundPermission]!,
      'dark_mode': instance.darkMode,
      'map_provider': instance.mapProvider,
      'auto_address_resolution': instance.autoAddressResolution,
    };

const _$BackgroundRefreshPermissionStateEnumMap = {
  BackgroundRefreshPermissionState.available: 'available',
  BackgroundRefreshPermissionState.denied: 'denied',
  BackgroundRefreshPermissionState.restricted: 'restricted',
  BackgroundRefreshPermissionState.unknown: 'unknown',
};

const _$SettingsStatusEnumMap = {
  SettingsStatus.initial: 'initial',
  SettingsStatus.success: 'success',
  SettingsStatus.create: 'create',
  SettingsStatus.pick: 'pick',
};
