// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CircleDetailsState _$CircleDetailsStateFromJson(Map<String, dynamic> json) =>
    CircleDetailsState(
      $enumDecode(_$CircleDetailsStatusEnumMap, json['status']),
      circleMemberships:
          (json['circle_memberships'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(
                    k, (e as List<dynamic>).map((e) => e as String).toList()),
              ) ??
              const {},
      circleId: json['circle_id'] as String?,
      profileInfo: json['profile_info'] == null
          ? null
          : ProfileInfo.fromJson(json['profile_info'] as Map<String, dynamic>),
      contacts: (json['contacts'] as List<dynamic>?)
              ?.map((e) => CoagContact.fromJson(e as Map<String, dynamic>)) ??
          const [],
      circles: (json['circles'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
    );

Map<String, dynamic> _$CircleDetailsStateToJson(CircleDetailsState instance) =>
    <String, dynamic>{
      'circle_memberships': instance.circleMemberships,
      'circles': instance.circles,
      'circle_id': instance.circleId,
      'status': _$CircleDetailsStatusEnumMap[instance.status]!,
      'contacts': instance.contacts.map((e) => e.toJson()).toList(),
      'profile_info': instance.profileInfo?.toJson(),
    };

const _$CircleDetailsStatusEnumMap = {
  CircleDetailsStatus.initial: 'initial',
  CircleDetailsStatus.success: 'success',
  CircleDetailsStatus.denied: 'denied',
};
