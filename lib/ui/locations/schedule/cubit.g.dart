// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScheduleState _$ScheduleStateFromJson(Map<String, dynamic> json) =>
    ScheduleState(
      checkingIn: json['checking_in'] as bool,
      circles: Map<String, String>.from(json['circles'] as Map),
      circleMemberships:
          (json['circle_memberships'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ),
    );

Map<String, dynamic> _$ScheduleStateToJson(ScheduleState instance) =>
    <String, dynamic>{
      'checking_in': instance.checkingIn,
      'circles': instance.circles,
      'circle_memberships': instance.circleMemberships,
    };
