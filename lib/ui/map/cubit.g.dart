// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MapState _$MapStateFromJson(Map<String, dynamic> json) => MapState(
      status: $enumDecode(_$MapStatusEnumMap, json['status']),
      contacts: (json['contacts'] as List<dynamic>?)
              ?.map((e) => CoagContact.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      circleMemberships:
          (json['circle_memberships'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(
                    k, (e as List<dynamic>).map((e) => e as String).toList()),
              ) ??
              const {},
      circles: (json['circles'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      profileInfo: json['profile_info'] == null
          ? null
          : ProfileInfo.fromJson(json['profile_info'] as Map<String, dynamic>),
      mapboxApiToken: json['mapbox_api_token'] as String? ?? '',
    );

Map<String, dynamic> _$MapStateToJson(MapState instance) => <String, dynamic>{
      'contacts': instance.contacts.map((e) => e.toJson()).toList(),
      'circle_memberships': instance.circleMemberships,
      'circles': instance.circles,
      'profile_info': instance.profileInfo?.toJson(),
      'status': _$MapStatusEnumMap[instance.status]!,
      'mapbox_api_token': instance.mapboxApiToken,
    };

const _$MapStatusEnumMap = {
  MapStatus.initial: 'initial',
  MapStatus.success: 'success',
  MapStatus.denied: 'denied',
};
