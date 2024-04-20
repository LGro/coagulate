// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactDetailsState _$ContactDetailsStateFromJson(Map<String, dynamic> json) =>
    ContactDetailsState(
      json['coag_contact_id'] as String,
      $enumDecode(_$ContactDetailsStatusEnumMap, json['status']),
      contact: json['contact'] == null
          ? null
          : CoagContact.fromJson(json['contact'] as Map<String, dynamic>),
      sharedProfile: json['shared_profile'] == null
          ? null
          : CoagContact.fromJson(
              json['shared_profile'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ContactDetailsStateToJson(
        ContactDetailsState instance) =>
    <String, dynamic>{
      'coag_contact_id': instance.coagContactId,
      'contact': instance.contact?.toJson(),
      'status': _$ContactDetailsStatusEnumMap[instance.status]!,
      'shared_profile': instance.sharedProfile?.toJson(),
    };

const _$ContactDetailsStatusEnumMap = {
  ContactDetailsStatus.initial: 'initial',
  ContactDetailsStatus.success: 'success',
  ContactDetailsStatus.denied: 'denied',
  ContactDetailsStatus.coagulationChangePending: 'coagulationChangePending',
};
