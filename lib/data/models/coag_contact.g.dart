// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coag_contact.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DhtSettings _$DhtSettingsFromJson(Map<String, dynamic> json) => DhtSettings(
      myKeyPair: TypedKeyPair.fromJson(json['my_key_pair']),
      theirPublicKey: json['their_public_key'] == null
          ? null
          : FixedEncodedString43.fromJson(json['their_public_key']),
      recordKeyMeSharing: json['record_key_me_sharing'] == null
          ? null
          : Typed<FixedEncodedString43>.fromJson(json['record_key_me_sharing']),
      writerMeSharing: json['writer_me_sharing'] == null
          ? null
          : KeyPair.fromJson(json['writer_me_sharing']),
      recordKeyThemSharing: json['record_key_them_sharing'] == null
          ? null
          : Typed<FixedEncodedString43>.fromJson(
              json['record_key_them_sharing']),
      writerThemSharing: json['writer_them_sharing'] == null
          ? null
          : KeyPair.fromJson(json['writer_them_sharing']),
      initialSecret: json['initial_secret'] == null
          ? null
          : FixedEncodedString43.fromJson(json['initial_secret']),
      theyAckHandshakeComplete:
          json['they_ack_handshake_complete'] as bool? ?? false,
    );

Map<String, dynamic> _$DhtSettingsToJson(DhtSettings instance) =>
    <String, dynamic>{
      'my_key_pair': instance.myKeyPair.toJson(),
      'their_public_key': instance.theirPublicKey?.toJson(),
      'record_key_me_sharing': instance.recordKeyMeSharing?.toJson(),
      'writer_me_sharing': instance.writerMeSharing?.toJson(),
      'record_key_them_sharing': instance.recordKeyThemSharing?.toJson(),
      'writer_them_sharing': instance.writerThemSharing?.toJson(),
      'initial_secret': instance.initialSecret?.toJson(),
      'they_ack_handshake_complete': instance.theyAckHandshakeComplete,
    };

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
      picture: (json['picture'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      publicKey: json['public_key'] as String?,
      names: (json['names'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      phones: (json['phones'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      emails: (json['emails'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      websites: (json['websites'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      socialMedias: (json['social_medias'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      events: (json['events'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, DateTime.parse(e as String)),
          ) ??
          const {},
    );

Map<String, dynamic> _$ContactDetailsToJson(ContactDetails instance) =>
    <String, dynamic>{
      'picture': instance.picture,
      'public_key': instance.publicKey,
      'names': instance.names,
      'phones': instance.phones,
      'emails': instance.emails,
      'websites': instance.websites,
      'social_medias': instance.socialMedias,
      'events': instance.events.map((k, e) => MapEntry(k, e.toIso8601String())),
    };

ProfileInfo _$ProfileInfoFromJson(Map<String, dynamic> json) => ProfileInfo(
      json['id'] as String,
      details: json['details'] == null
          ? const ContactDetails()
          : ContactDetails.fromJson(json['details'] as Map<String, dynamic>),
      pictures: (json['pictures'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k,
                (e as List<dynamic>).map((e) => (e as num).toInt()).toList()),
          ) ??
          const {},
      addressLocations: (json['address_locations'] as Map<String, dynamic>?)
              ?.map(
            (k, e) => MapEntry(
                k, ContactAddressLocation.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
      temporaryLocations: (json['temporary_locations'] as Map<String, dynamic>?)
              ?.map(
            (k, e) => MapEntry(k,
                ContactTemporaryLocation.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
      sharingSettings: json['sharing_settings'] == null
          ? const ProfileSharingSettings()
          : ProfileSharingSettings.fromJson(
              json['sharing_settings'] as Map<String, dynamic>),
      mainKeyPair: json['main_key_pair'] == null
          ? null
          : TypedKeyPair.fromJson(json['main_key_pair']),
    );

Map<String, dynamic> _$ProfileInfoToJson(ProfileInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'details': instance.details.toJson(),
      'pictures': instance.pictures,
      'address_locations':
          instance.addressLocations.map((k, e) => MapEntry(k, e.toJson())),
      'temporary_locations':
          instance.temporaryLocations.map((k, e) => MapEntry(k, e.toJson())),
      'sharing_settings': instance.sharingSettings.toJson(),
      'main_key_pair': instance.mainKeyPair?.toJson(),
    };

CoagContact _$CoagContactFromJson(Map<String, dynamic> json) => CoagContact(
      coagContactId: json['coag_contact_id'] as String,
      name: json['name'] as String,
      dhtSettings:
          DhtSettings.fromJson(json['dht_settings'] as Map<String, dynamic>),
      details: json['details'] == null
          ? null
          : ContactDetails.fromJson(json['details'] as Map<String, dynamic>),
      theirPersonalUniqueId: json['their_personal_unique_id'] as String?,
      knownPersonalContactIds:
          (json['known_personal_contact_ids'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              const [],
      systemContactId: json['system_contact_id'] as String?,
      addressLocations: (json['address_locations'] as Map<String, dynamic>?)
              ?.map(
            (k, e) => MapEntry(
                k, ContactAddressLocation.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
      temporaryLocations: (json['temporary_locations'] as Map<String, dynamic>?)
              ?.map(
            (k, e) => MapEntry(k,
                ContactTemporaryLocation.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
      comment: json['comment'] as String? ?? '',
      sharedProfile: json['shared_profile'] == null
          ? null
          : CoagContactDHTSchemaV2.fromJson(
              json['shared_profile'] as Map<String, dynamic>),
      introductionsForThem: (json['introductions_for_them'] as List<dynamic>?)
              ?.map((e) =>
                  ContactIntroduction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      introductionsByThem: (json['introductions_by_them'] as List<dynamic>?)
              ?.map((e) =>
                  ContactIntroduction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      mostRecentUpdate: json['most_recent_update'] == null
          ? null
          : DateTime.parse(json['most_recent_update'] as String),
      mostRecentChange: json['most_recent_change'] == null
          ? null
          : DateTime.parse(json['most_recent_change'] as String),
    );

Map<String, dynamic> _$CoagContactToJson(CoagContact instance) =>
    <String, dynamic>{
      'coag_contact_id': instance.coagContactId,
      'their_personal_unique_id': instance.theirPersonalUniqueId,
      'known_personal_contact_ids': instance.knownPersonalContactIds,
      'name': instance.name,
      'system_contact_id': instance.systemContactId,
      'details': instance.details?.toJson(),
      'comment': instance.comment,
      'address_locations':
          instance.addressLocations.map((k, e) => MapEntry(k, e.toJson())),
      'temporary_locations':
          instance.temporaryLocations.map((k, e) => MapEntry(k, e.toJson())),
      'dht_settings': instance.dhtSettings.toJson(),
      'shared_profile': instance.sharedProfile?.toJson(),
      'introductions_for_them':
          instance.introductionsForThem.map((e) => e.toJson()).toList(),
      'introductions_by_them':
          instance.introductionsByThem.map((e) => e.toJson()).toList(),
      'most_recent_update': instance.mostRecentUpdate?.toIso8601String(),
      'most_recent_change': instance.mostRecentChange?.toIso8601String(),
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
      temporaryLocations: (json['temporary_locations'] as Map<String, dynamic>?)
              ?.map(
            (k, e) => MapEntry(k,
                ContactTemporaryLocation.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
    );

Map<String, dynamic> _$CoagContactDHTSchemaV1ToJson(
        CoagContactDHTSchemaV1 instance) =>
    <String, dynamic>{
      'coag_contact_id': instance.coagContactId,
      'details': instance.details.toJson(),
      'address_locations': instance.addressLocations
          .map((k, e) => MapEntry(k.toString(), e.toJson())),
      'temporary_locations':
          instance.temporaryLocations.map((k, e) => MapEntry(k, e.toJson())),
      'share_back_d_h_t_key': instance.shareBackDHTKey,
      'share_back_d_h_t_writer': instance.shareBackDHTWriter,
      'share_back_psk': instance.shareBackPsk,
    };

CoagContactDHTSchemaV2 _$CoagContactDHTSchemaV2FromJson(
        Map<String, dynamic> json) =>
    CoagContactDHTSchemaV2(
      details: ContactDetails.fromJson(json['details'] as Map<String, dynamic>),
      shareBackDHTKey: json['share_back_d_h_t_key'] as String?,
      shareBackPubKey: json['share_back_pub_key'] as String?,
      shareBackDHTWriter: json['share_back_d_h_t_writer'] as String?,
      personalUniqueId: json['personal_unique_id'] as String?,
      addressLocations: (json['address_locations'] as Map<String, dynamic>?)
              ?.map(
            (k, e) => MapEntry(
                k, ContactAddressLocation.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
      temporaryLocations: (json['temporary_locations'] as Map<String, dynamic>?)
              ?.map(
            (k, e) => MapEntry(k,
                ContactTemporaryLocation.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
      ackHandshakeComplete: json['ack_handshake_complete'] as bool? ?? false,
      knownPersonalContactIds:
          (json['known_personal_contact_ids'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              const [],
      introductions: (json['introductions'] as List<dynamic>?)
              ?.map((e) =>
                  ContactIntroduction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      mostRecentUpdate: json['most_recent_update'] == null
          ? null
          : DateTime.parse(json['most_recent_update'] as String),
    );

Map<String, dynamic> _$CoagContactDHTSchemaV2ToJson(
        CoagContactDHTSchemaV2 instance) =>
    <String, dynamic>{
      'details': instance.details.toJson(),
      'address_locations':
          instance.addressLocations.map((k, e) => MapEntry(k, e.toJson())),
      'temporary_locations':
          instance.temporaryLocations.map((k, e) => MapEntry(k, e.toJson())),
      'personal_unique_id': instance.personalUniqueId,
      'share_back_d_h_t_key': instance.shareBackDHTKey,
      'share_back_d_h_t_writer': instance.shareBackDHTWriter,
      'share_back_pub_key': instance.shareBackPubKey,
      'ack_handshake_complete': instance.ackHandshakeComplete,
      'known_personal_contact_ids': instance.knownPersonalContactIds,
      'introductions': instance.introductions.map((e) => e.toJson()).toList(),
      'most_recent_update': instance.mostRecentUpdate?.toIso8601String(),
    };
