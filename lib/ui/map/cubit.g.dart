// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Location _$LocationFromJson(Map<String, dynamic> json) => Location(
      coagContactId: json['coag_contact_id'] as String,
      longitude: (json['longitude'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      label: json['label'] as String,
      subLabel: json['sub_label'] as String,
    );

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
      'coag_contact_id': instance.coagContactId,
      'longitude': instance.longitude,
      'latitude': instance.latitude,
      'label': instance.label,
      'sub_label': instance.subLabel,
    };

MapState _$MapStateFromJson(Map<String, dynamic> json) => MapState(
      (json['locations'] as List<dynamic>)
          .map((e) => Location.fromJson(e as Map<String, dynamic>)),
      $enumDecode(_$MapStatusEnumMap, json['status']),
      mapboxApiToken: json['mapbox_api_token'] as String? ?? '',
    );

Map<String, dynamic> _$MapStateToJson(MapState instance) => <String, dynamic>{
      'locations': instance.locations.map((e) => e.toJson()).toList(),
      'status': _$MapStatusEnumMap[instance.status]!,
      'mapbox_api_token': instance.mapboxApiToken,
    };

const _$MapStatusEnumMap = {
  MapStatus.initial: 'initial',
  MapStatus.success: 'success',
  MapStatus.denied: 'denied',
};
