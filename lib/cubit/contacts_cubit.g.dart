// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contacts_cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoagContactSchema _$CoagContactSchemaFromJson(Map<String, dynamic> json) =>
    CoagContactSchema(
      contact: Contact.fromJson(json['contact'] as Map<String, dynamic>),
      addressCoordinates:
          (json['address_coordinates'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k,
            _$recordConvert(
              e,
              ($jsonValue) => (
                $jsonValue[r'$1'] as num,
                $jsonValue[r'$2'] as num,
              ),
            )),
      ),
      publicKey: json['public_key'] as String?,
      dhtKey: json['dht_key'] as String?,
      dhtWriter: json['dht_writer'] as String?,
    );

Map<String, dynamic> _$CoagContactSchemaToJson(CoagContactSchema instance) =>
    <String, dynamic>{
      'contact': instance.contact.toJson(),
      'address_coordinates':
          instance.addressCoordinates.map((k, e) => MapEntry(k, {
                r'$1': e.$1,
                r'$2': e.$2,
              })),
      'public_key': instance.publicKey,
      'dht_key': instance.dhtKey,
      'dht_writer': instance.dhtWriter,
    };

$Rec _$recordConvert<$Rec>(
  Object? value,
  $Rec Function(Map) convert,
) =>
    convert(value as Map<String, dynamic>);

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
