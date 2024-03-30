// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactListState _$ContactListStateFromJson(Map<String, dynamic> json) =>
    ContactListState(
      json['coag_contact_id'] as String,
      $enumDecode(_$ContactListStatusEnumMap, json['status']),
      contact: json['contact'] == null
          ? null
          : CoagContact.fromJson(json['contact'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ContactListStateToJson(ContactListState instance) =>
    <String, dynamic>{
      'coag_contact_id': instance.coagContactId,
      'contact': instance.contact?.toJson(),
      'status': _$ContactListStatusEnumMap[instance.status]!,
    };

const _$ContactListStatusEnumMap = {
  ContactListStatus.initial: 'initial',
  ContactListStatus.success: 'success',
  ContactListStatus.denied: 'denied',
};
