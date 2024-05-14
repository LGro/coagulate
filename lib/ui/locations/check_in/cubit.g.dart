// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckInState _$CheckInStateFromJson(Map<String, dynamic> json) => CheckInState(
      checkingIn: json['checking_in'] as bool,
      circles: Map<String, String>.from(json['circles'] as Map),
    );

Map<String, dynamic> _$CheckInStateToJson(CheckInState instance) =>
    <String, dynamic>{
      'checking_in': instance.checkingIn,
      'circles': instance.circles,
    };
