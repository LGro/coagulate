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
      circleMemberships:
          (json['circle_memberships'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(
                    k, (e as List<dynamic>).map((e) => e as String).toList()),
              ) ??
              const {},
      filter: json['filter'] as String? ?? '',
      selectedCircle: json['selected_circle'] as String?,
      circles: (json['circles'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
    );

Map<String, dynamic> _$ContactListStateToJson(ContactListState instance) =>
    <String, dynamic>{
      'circle_memberships': instance.circleMemberships,
      'contacts': instance.contacts.map((e) => e.toJson()).toList(),
      'selected_circle': instance.selectedCircle,
      'circles': instance.circles,
      'filter': instance.filter,
      'status': _$ContactListStatusEnumMap[instance.status]!,
    };

const _$ContactListStatusEnumMap = {
  ContactListStatus.initial: 'initial',
  ContactListStatus.success: 'success',
  ContactListStatus.denied: 'denied',
};
