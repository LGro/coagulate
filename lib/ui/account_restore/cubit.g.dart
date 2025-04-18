// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RestoreState _$RestoreStateFromJson(Map<String, dynamic> json) => RestoreState(
      status: $enumDecodeNullable(_$RestoreStatusEnumMap, json['status']) ??
          RestoreStatus.initial,
    );

Map<String, dynamic> _$RestoreStateToJson(RestoreState instance) =>
    <String, dynamic>{
      'status': _$RestoreStatusEnumMap[instance.status]!,
    };

const _$RestoreStatusEnumMap = {
  RestoreStatus.initial: 'initial',
  RestoreStatus.success: 'success',
  RestoreStatus.create: 'create',
  RestoreStatus.failure: 'failure',
};
