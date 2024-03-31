// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactListState _$ContactListStateFromJson(Map<String, dynamic> json) =>
    ContactListState(
      $enumDecode(_$ContactListStatusEnumMap, json['status']),
      contacts: (json['contacts'] as List<dynamic>?)
              ?.map((e) => CoagContact.fromJson(e as Map<String, dynamic>)) ??
          const [],
    );

Map<String, dynamic> _$ContactListStateToJson(ContactListState instance) =>
    <String, dynamic>{
      'contacts': instance.contacts.map((e) => e.toJson()).toList(),
      'status': _$ContactListStatusEnumMap[instance.status]!,
    };

const _$ContactListStatusEnumMap = {
  ContactListStatus.initial: 'initial',
  ContactListStatus.success: 'success',
  ContactListStatus.denied: 'denied',
};
