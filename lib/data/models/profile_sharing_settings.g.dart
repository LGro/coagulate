// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_sharing_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileSharingSettings _$ProfileSharingSettingsFromJson(
        Map<String, dynamic> json) =>
    ProfileSharingSettings(
      names: (json['names'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
                k, (e as List<dynamic>).map((e) => e as String).toList()),
          ) ??
          const {},
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
      'names': instance.names,
      'phones': instance.phones,
      'emails': instance.emails,
      'addresses': instance.addresses,
      'organizations': instance.organizations,
      'websites': instance.websites,
      'social_medias': instance.socialMedias,
      'events': instance.events,
    };
