// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CirclesListState _$CirclesListStateFromJson(Map<String, dynamic> json) =>
    CirclesListState(
      $enumDecode(_$CirclesListStatusEnumMap, json['status']),
      circleMemberships:
          (json['circle_memberships'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(
                    k, (e as List<dynamic>).map((e) => e as String).toList()),
              ) ??
              const {},
      filter: json['filter'] as String? ?? '',
      circles: (json['circles'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
    );

Map<String, dynamic> _$CirclesListStateToJson(CirclesListState instance) =>
    <String, dynamic>{
      'circle_memberships': instance.circleMemberships,
      'circles': instance.circles,
      'filter': instance.filter,
      'status': _$CirclesListStatusEnumMap[instance.status]!,
    };

const _$CirclesListStatusEnumMap = {
  CirclesListStatus.initial: 'initial',
  CirclesListStatus.success: 'success',
  CirclesListStatus.denied: 'denied',
};
