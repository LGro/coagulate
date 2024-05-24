// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScheduleState _$ScheduleStateFromJson(Map<String, dynamic> json) =>
    ScheduleState(
      checkingIn: json['checking_in'] as bool,
      circles: Map<String, String>.from(json['circles'] as Map),
    );

Map<String, dynamic> _$ScheduleStateToJson(ScheduleState instance) =>
    <String, dynamic>{
      'checking_in': instance.checkingIn,
      'circles': instance.circles,
    };
