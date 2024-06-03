// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckInState _$CheckInStateFromJson(Map<String, dynamic> json) => CheckInState(
      status: $enumDecode(_$CheckInStatusEnumMap, json['status']),
      circles: Map<String, String>.from(json['circles'] as Map),
    );

Map<String, dynamic> _$CheckInStateToJson(CheckInState instance) =>
    <String, dynamic>{
      'status': _$CheckInStatusEnumMap[instance.status]!,
      'circles': instance.circles,
    };

const _$CheckInStatusEnumMap = {
  CheckInStatus.initial: 'initial',
  CheckInStatus.locationDisabled: 'locationDisabled',
  CheckInStatus.locationDenied: 'locationDenied',
  CheckInStatus.locationDeniedPermanent: 'locationDeniedPermanent',
  CheckInStatus.locationTimeout: 'locationTimeout',
  CheckInStatus.noProfile: 'noProfile',
  CheckInStatus.readyForCheckIn: 'readyForCheckIn',
  CheckInStatus.checkingIn: 'checkingIn',
};
