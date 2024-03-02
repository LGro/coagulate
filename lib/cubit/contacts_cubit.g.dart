// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contacts_cubit.dart';

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

CoagContact _$CoagContactFromJson(Map<String, dynamic> json) => CoagContact(
      contact: Contact.fromJson(json['contact'] as Map<String, dynamic>),
      dhtUpdateStatus: $enumDecodeNullable(
          _$DhtUpdateStatusEnumMap, json['dht_update_status']),
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

Map<String, dynamic> _$CoagContactToJson(CoagContact instance) =>
    <String, dynamic>{
      'contact': instance.contact.toJson(),
      'dht_update_status': _$DhtUpdateStatusEnumMap[instance.dhtUpdateStatus],
      'peer_record': instance.peerRecord?.toJson(),
      'my_record': instance.myRecord?.toJson(),
      'lng': instance.lng,
      'lat': instance.lat,
      'sharing_profile': instance.sharingProfile,
    };

const _$DhtUpdateStatusEnumMap = {
  DhtUpdateStatus.progress: 'progress',
  DhtUpdateStatus.success: 'success',
  DhtUpdateStatus.failure: 'failure',
};

CoagContactState _$CoagContactStateFromJson(Map<String, dynamic> json) =>
    CoagContactState(
      (json['contacts'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, CoagContact.fromJson(e as Map<String, dynamic>)),
      ),
      $enumDecode(_$CoagContactStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$CoagContactStateToJson(CoagContactState instance) =>
    <String, dynamic>{
      'contacts': instance.contacts.map((k, e) => MapEntry(k, e.toJson())),
      'status': _$CoagContactStatusEnumMap[instance.status]!,
    };

const _$CoagContactStatusEnumMap = {
  CoagContactStatus.initial: 'initial',
  CoagContactStatus.success: 'success',
  CoagContactStatus.denied: 'denied',
};
