// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactDetailsState _$ContactDetailsStateFromJson(Map<String, dynamic> json) =>
    ContactDetailsState(
      json['coag_contact_id'] as String,
      $enumDecode(_$ContactDetailsStatusEnumMap, json['status']),
      CoagContact.fromJson(json['contact'] as Map<String, dynamic>),
      sharedProfile: json['shared_profile'] == null
          ? null
          : CoagContact.fromJson(
              json['shared_profile'] as Map<String, dynamic>),
      circles: (json['circles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ContactDetailsStateToJson(
        ContactDetailsState instance) =>
    <String, dynamic>{
      'coag_contact_id': instance.coagContactId,
      'contact': instance.contact.toJson(),
      'status': _$ContactDetailsStatusEnumMap[instance.status]!,
      'shared_profile': instance.sharedProfile?.toJson(),
      'circles': instance.circles,
    };

const _$ContactDetailsStatusEnumMap = {
  ContactDetailsStatus.initial: 'initial',
  ContactDetailsStatus.success: 'success',
  ContactDetailsStatus.denied: 'denied',
  ContactDetailsStatus.coagulationChangePending: 'coagulationChangePending',
};
