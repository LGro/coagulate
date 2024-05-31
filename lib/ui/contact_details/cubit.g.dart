// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactDetailsState _$ContactDetailsStateFromJson(Map<String, dynamic> json) =>
    ContactDetailsState(
      $enumDecode(_$ContactDetailsStatusEnumMap, json['status']),
      CoagContact.fromJson(json['contact'] as Map<String, dynamic>),
      circles: (json['circles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ContactDetailsStateToJson(
        ContactDetailsState instance) =>
    <String, dynamic>{
      'contact': instance.contact.toJson(),
      'status': _$ContactDetailsStatusEnumMap[instance.status]!,
      'circles': instance.circles,
    };

const _$ContactDetailsStatusEnumMap = {
  ContactDetailsStatus.initial: 'initial',
  ContactDetailsStatus.success: 'success',
  ContactDetailsStatus.denied: 'denied',
  ContactDetailsStatus.coagulationChangePending: 'coagulationChangePending',
};
