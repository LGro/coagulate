// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'peer_contact_cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PeerDHTRecord _$PeerDHTRecordFromJson(Map<String, dynamic> json) =>
    PeerDHTRecord(
      key: json['key'] as String,
      writer: json['writer'] as String?,
      psk: json['psk'] as String?,
      pubKey: json['pub_key'] as String?,
    );

Map<String, dynamic> _$PeerDHTRecordToJson(PeerDHTRecord instance) =>
    <String, dynamic>{
      'key': instance.key,
      'writer': instance.writer,
      'psk': instance.psk,
      'pub_key': instance.pubKey,
    };

MyDHTRecord _$MyDHTRecordFromJson(Map<String, dynamic> json) => MyDHTRecord(
      key: json['key'] as String,
      writer: json['writer'] as String,
      psk: json['psk'] as String?,
    );

Map<String, dynamic> _$MyDHTRecordToJson(MyDHTRecord instance) =>
    <String, dynamic>{
      'key': instance.key,
      'writer': instance.writer,
      'psk': instance.psk,
    };

PeerContact _$PeerContactFromJson(Map<String, dynamic> json) => PeerContact(
      contact: Contact.fromJson(json['contact'] as Map<String, dynamic>),
      peerRecord: json['peer_record'] == null
          ? null
          : PeerDHTRecord.fromJson(json['peer_record'] as Map<String, dynamic>),
      myRecord: json['my_record'] == null
          ? null
          : MyDHTRecord.fromJson(json['my_record'] as Map<String, dynamic>),
      lng: json['lng'] as num?,
      lat: json['lat'] as num?,
      sharingProfile: json['sharing_profile'] as String?,
    );

Map<String, dynamic> _$PeerContactToJson(PeerContact instance) =>
    <String, dynamic>{
      'contact': instance.contact.toJson(),
      'peer_record': instance.peerRecord?.toJson(),
      'my_record': instance.myRecord?.toJson(),
      'lng': instance.lng,
      'lat': instance.lat,
      'sharing_profile': instance.sharingProfile,
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
