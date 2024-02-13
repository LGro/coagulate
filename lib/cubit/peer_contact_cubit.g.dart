// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'peer_contact_cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PeerContact _$PeerContactFromJson(Map<String, dynamic> json) => PeerContact(
      contact: Contact.fromJson(json['contact'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PeerContactToJson(PeerContact instance) =>
    <String, dynamic>{
      'contact': instance.contact.toJson(),
    };

PeerContactState _$PeerContactStateFromJson(Map<String, dynamic> json) =>
    PeerContactState(
      (json['contacts'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, PeerContact.fromJson(e as Map<String, dynamic>)),
      ),
      $enumDecode(_$PeerContactStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$PeerContactStateToJson(PeerContactState instance) =>
    <String, dynamic>{
      'contacts': instance.contacts.map((k, e) => MapEntry(k, e.toJson())),
      'status': _$PeerContactStatusEnumMap[instance.status]!,
    };

const _$PeerContactStatusEnumMap = {
  PeerContactStatus.initial: 'initial',
  PeerContactStatus.success: 'success',
  PeerContactStatus.denied: 'denied',
};
