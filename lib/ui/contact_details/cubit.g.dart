// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactDetailsState _$ContactDetailsStateFromJson(Map<String, dynamic> json) =>
    ContactDetailsState(
      $enumDecode(_$ContactDetailsStatusEnumMap, json['status']),
      contact: json['contact'] == null
          ? null
          : CoagContact.fromJson(json['contact'] as Map<String, dynamic>),
      circleNames: (json['circle_names'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      knownContacts: (json['known_contacts'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
    );

Map<String, dynamic> _$ContactDetailsStateToJson(
        ContactDetailsState instance) =>
    <String, dynamic>{
      'contact': instance.contact?.toJson(),
      'status': _$ContactDetailsStatusEnumMap[instance.status]!,
      'circle_names': instance.circleNames,
      'known_contacts': instance.knownContacts,
    };

const _$ContactDetailsStatusEnumMap = {
  ContactDetailsStatus.initial: 'initial',
  ContactDetailsStatus.success: 'success',
  ContactDetailsStatus.denied: 'denied',
  ContactDetailsStatus.coagulationChangePending: 'coagulationChangePending',
};
