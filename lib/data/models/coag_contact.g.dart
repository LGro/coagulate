// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coag_contact.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactDHTSettings _$ContactDHTSettingsFromJson(Map<String, dynamic> json) =>
    ContactDHTSettings(
      key: json['key'] as String,
      writer: json['writer'] as String?,
      psk: json['psk'] as String?,
      pubKey: json['pub_key'] as String?,
    );

Map<String, dynamic> _$ContactDHTSettingsToJson(ContactDHTSettings instance) =>
    <String, dynamic>{
      'key': instance.key,
      'writer': instance.writer,
      'psk': instance.psk,
      'pub_key': instance.pubKey,
    };

CoagContact _$CoagContactFromJson(Map<String, dynamic> json) => CoagContact(
      coagContactId: json['coag_contact_id'] as String,
      details: json['details'] == null
          ? null
          : Contact.fromJson(json['details'] as Map<String, dynamic>),
      locations: (json['locations'] as List<dynamic>?)
              ?.map((e) => ContactLocation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      dhtSettingsForSharing: json['dht_settings_for_sharing'] == null
          ? null
          : ContactDHTSettings.fromJson(
              json['dht_settings_for_sharing'] as Map<String, dynamic>),
      dhtSettingsForReceiving: json['dht_settings_for_receiving'] == null
          ? null
          : ContactDHTSettings.fromJson(
              json['dht_settings_for_receiving'] as Map<String, dynamic>),
      sharedProfile: json['shared_profile'] as String?,
    );

Map<String, dynamic> _$CoagContactToJson(CoagContact instance) =>
    <String, dynamic>{
      'coag_contact_id': instance.coagContactId,
      'details': instance.details?.toJson(),
      'locations': instance.locations.map((e) => e.toJson()).toList(),
      'dht_settings_for_sharing': instance.dhtSettingsForSharing?.toJson(),
      'dht_settings_for_receiving': instance.dhtSettingsForReceiving?.toJson(),
      'shared_profile': instance.sharedProfile,
    };
