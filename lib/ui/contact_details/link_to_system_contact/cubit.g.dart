// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LinkToSystemContactState _$LinkToSystemContactStateFromJson(
        Map<String, dynamic> json) =>
    LinkToSystemContactState(
      status: $enumDecodeNullable(
              _$LinkToSystemContactStatusEnumMap, json['status']) ??
          LinkToSystemContactStatus.initial,
      contact: json['contact'] == null
          ? null
          : CoagContact.fromJson(json['contact'] as Map<String, dynamic>),
      contacts: (json['contacts'] as List<dynamic>?)
              ?.map((e) => Contact.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      permissionGranted: json['permission_granted'] as bool? ?? false,
    );

Map<String, dynamic> _$LinkToSystemContactStateToJson(
        LinkToSystemContactState instance) =>
    <String, dynamic>{
      'status': _$LinkToSystemContactStatusEnumMap[instance.status]!,
      'permission_granted': instance.permissionGranted,
      'contact': instance.contact?.toJson(),
      'contacts': instance.contacts.map((e) => e.toJson()).toList(),
    };

const _$LinkToSystemContactStatusEnumMap = {
  LinkToSystemContactStatus.initial: 'initial',
  LinkToSystemContactStatus.success: 'success',
  LinkToSystemContactStatus.denied: 'denied',
};
