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
      accounts: (json['accounts'] as List<dynamic>?)
              ?.map((e) => Account.fromJson(e as Map<String, dynamic>))
              .toSet() ??
          const {},
      permissionGranted: json['permission_granted'] as bool? ?? false,
      selectedAccount: json['selected_account'] == null
          ? null
          : Account.fromJson(json['selected_account'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LinkToSystemContactStateToJson(
        LinkToSystemContactState instance) =>
    <String, dynamic>{
      'status': _$LinkToSystemContactStatusEnumMap[instance.status]!,
      'permission_granted': instance.permissionGranted,
      'contact': instance.contact?.toJson(),
      'contacts': instance.contacts.map((e) => e.toJson()).toList(),
      'accounts': instance.accounts.map((e) => e.toJson()).toList(),
      'selected_account': instance.selectedAccount?.toJson(),
    };

const _$LinkToSystemContactStatusEnumMap = {
  LinkToSystemContactStatus.initial: 'initial',
  LinkToSystemContactStatus.success: 'success',
  LinkToSystemContactStatus.denied: 'denied',
};
