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
      lastUpdated: json['last_updated'] == null
          ? null
          : DateTime.parse(json['last_updated'] as String),
    );

Map<String, dynamic> _$ContactDHTSettingsToJson(ContactDHTSettings instance) =>
    <String, dynamic>{
      'key': instance.key,
      'writer': instance.writer,
      'psk': instance.psk,
      'pub_key': instance.pubKey,
      'last_updated': instance.lastUpdated?.toIso8601String(),
    };

ContactDetails _$ContactDetailsFromJson(Map<String, dynamic> json) =>
    ContactDetails(
      displayName: json['display_name'] as String,
      name: Name.fromJson(json['name'] as Map<String, dynamic>),
      phones: (json['phones'] as List<dynamic>?)
              ?.map((e) => Phone.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      emails: (json['emails'] as List<dynamic>?)
              ?.map((e) => Email.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      addresses: (json['addresses'] as List<dynamic>?)
              ?.map((e) => Address.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      organizations: (json['organizations'] as List<dynamic>?)
              ?.map((e) => Organization.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      websites: (json['websites'] as List<dynamic>?)
              ?.map((e) => Website.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      socialMedias: (json['social_medias'] as List<dynamic>?)
              ?.map((e) => SocialMedia.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      events: (json['events'] as List<dynamic>?)
              ?.map((e) => Event.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ContactDetailsToJson(ContactDetails instance) =>
    <String, dynamic>{
      'display_name': instance.displayName,
      'name': instance.name.toJson(),
      'phones': instance.phones.map((e) => e.toJson()).toList(),
      'emails': instance.emails.map((e) => e.toJson()).toList(),
      'addresses': instance.addresses.map((e) => e.toJson()).toList(),
      'organizations': instance.organizations.map((e) => e.toJson()).toList(),
      'websites': instance.websites.map((e) => e.toJson()).toList(),
      'social_medias': instance.socialMedias.map((e) => e.toJson()).toList(),
      'events': instance.events.map((e) => e.toJson()).toList(),
    };

CoagContact _$CoagContactFromJson(Map<String, dynamic> json) => CoagContact(
      coagContactId: json['coag_contact_id'] as String,
      details: json['details'] == null
          ? null
          : ContactDetails.fromJson(json['details'] as Map<String, dynamic>),
      systemContact: json['system_contact'] == null
          ? null
          : Contact.fromJson(json['system_contact'] as Map<String, dynamic>),
      addressLocations:
          (json['address_locations'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(int.parse(k),
                    ContactAddressLocation.fromJson(e as Map<String, dynamic>)),
              ) ??
              const {},
      temporaryLocations: (json['temporary_locations'] as List<dynamic>?)
              ?.map((e) =>
                  ContactTemporaryLocation.fromJson(e as Map<String, dynamic>))
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
      'system_contact': instance.systemContact?.toJson(),
      'details': instance.details?.toJson(),
      'address_locations': instance.addressLocations
          .map((k, e) => MapEntry(k.toString(), e.toJson())),
      'temporary_locations':
          instance.temporaryLocations.map((e) => e.toJson()).toList(),
      'dht_settings_for_sharing': instance.dhtSettingsForSharing?.toJson(),
      'dht_settings_for_receiving': instance.dhtSettingsForReceiving?.toJson(),
      'shared_profile': instance.sharedProfile,
    };

CoagContactDHTSchemaV1 _$CoagContactDHTSchemaV1FromJson(
        Map<String, dynamic> json) =>
    CoagContactDHTSchemaV1(
      coagContactId: json['coag_contact_id'] as String,
      details: ContactDetails.fromJson(json['details'] as Map<String, dynamic>),
      shareBackDHTKey: json['share_back_d_h_t_key'] as String?,
      shareBackPsk: json['share_back_psk'] as String?,
      shareBackDHTWriter: json['share_back_d_h_t_writer'] as String?,
      addressLocations:
          (json['address_locations'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(int.parse(k),
                    ContactAddressLocation.fromJson(e as Map<String, dynamic>)),
              ) ??
              const {},
      temporaryLocations: (json['temporary_locations'] as List<dynamic>?)
              ?.map((e) =>
                  ContactTemporaryLocation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$CoagContactDHTSchemaV1ToJson(
        CoagContactDHTSchemaV1 instance) =>
    <String, dynamic>{
      'coag_contact_id': instance.coagContactId,
      'details': instance.details.toJson(),
      'address_locations': instance.addressLocations
          .map((k, e) => MapEntry(k.toString(), e.toJson())),
      'temporary_locations':
          instance.temporaryLocations.map((e) => e.toJson()).toList(),
      'share_back_d_h_t_key': instance.shareBackDHTKey,
      'share_back_d_h_t_writer': instance.shareBackDHTWriter,
      'share_back_psk': instance.shareBackPsk,
    };
