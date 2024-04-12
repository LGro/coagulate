// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdatesState _$UpdatesStateFromJson(Map<String, dynamic> json) => UpdatesState(
      $enumDecode(_$UpdatesStatusEnumMap, json['status']),
      updates: (json['updates'] as List<dynamic>?)
              ?.map((e) => ContactUpdate.fromJson(e as Map<String, dynamic>)) ??
          const [],
    );

Map<String, dynamic> _$UpdatesStateToJson(UpdatesState instance) =>
    <String, dynamic>{
      'updates': instance.updates.map((e) => e.toJson()).toList(),
      'status': _$UpdatesStatusEnumMap[instance.status]!,
    };

const _$UpdatesStatusEnumMap = {
  UpdatesStatus.initial: 'initial',
  UpdatesStatus.success: 'success',
  UpdatesStatus.denied: 'denied',
};
