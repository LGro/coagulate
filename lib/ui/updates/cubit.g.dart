// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Update _$UpdateFromJson(Map<String, dynamic> json) => Update(
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$UpdateToJson(Update instance) => <String, dynamic>{
      'message': instance.message,
      'timestamp': instance.timestamp.toIso8601String(),
    };

UpdatesState _$UpdatesStateFromJson(Map<String, dynamic> json) => UpdatesState(
      $enumDecode(_$UpdatesStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$UpdatesStateToJson(UpdatesState instance) =>
    <String, dynamic>{
      'status': _$UpdatesStatusEnumMap[instance.status]!,
    };

const _$UpdatesStatusEnumMap = {
  UpdatesStatus.initial: 'initial',
  UpdatesStatus.success: 'success',
  UpdatesStatus.denied: 'denied',
};
