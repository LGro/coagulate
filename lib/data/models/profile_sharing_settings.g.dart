// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_sharing_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NameSharingSettings _$NameSharingSettingsFromJson(Map<String, dynamic> json) =>
    NameSharingSettings(
      first:
          (json['first'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      last:
          (json['last'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      middle: (json['middle'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      prefix: (json['prefix'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      suffix: (json['suffix'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      nickname: (json['nickname'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      firstPhonetic: (json['first_phonetic'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      lastPhonetic: (json['last_phonetic'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      middlePhonetic: (json['middle_phonetic'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$NameSharingSettingsToJson(
        NameSharingSettings instance) =>
    <String, dynamic>{
      'first': instance.first,
      'last': instance.last,
      'middle': instance.middle,
      'prefix': instance.prefix,
      'suffix': instance.suffix,
      'nickname': instance.nickname,
      'first_phonetic': instance.firstPhonetic,
      'last_phonetic': instance.lastPhonetic,
      'middle_phonetic': instance.middlePhonetic,
    };

ProfileSharingSettings _$ProfileSharingSettingsFromJson(
        Map<String, dynamic> json) =>
    ProfileSharingSettings(
      displayName: (json['display_name'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      name: json['name'] == null
          ? const NameSharingSettings()
          : NameSharingSettings.fromJson(json['name'] as Map<String, dynamic>),
      phones: (json['phones'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
                k, (e as List<dynamic>).map((e) => e as String).toList()),
          ) ??
          const {},
      emails: (json['emails'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
                k, (e as List<dynamic>).map((e) => e as String).toList()),
          ) ??
          const {},
      addresses: (json['addresses'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
                k, (e as List<dynamic>).map((e) => e as String).toList()),
          ) ??
          const {},
      organizations: (json['organizations'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
                k, (e as List<dynamic>).map((e) => e as String).toList()),
          ) ??
          const {},
      websites: (json['websites'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
                k, (e as List<dynamic>).map((e) => e as String).toList()),
          ) ??
          const {},
      socialMedias: (json['social_medias'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
                k, (e as List<dynamic>).map((e) => e as String).toList()),
          ) ??
          const {},
      events: (json['events'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
                k, (e as List<dynamic>).map((e) => e as String).toList()),
          ) ??
          const {},
    );

Map<String, dynamic> _$ProfileSharingSettingsToJson(
        ProfileSharingSettings instance) =>
    <String, dynamic>{
      'display_name': instance.displayName,
      'name': instance.name.toJson(),
      'phones': instance.phones,
      'emails': instance.emails,
      'addresses': instance.addresses,
      'organizations': instance.organizations,
      'websites': instance.websites,
      'social_medias': instance.socialMedias,
      'events': instance.events,
    };
