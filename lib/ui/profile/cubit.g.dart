// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileState _$ProfileStateFromJson(Map<String, dynamic> json) => ProfileState(
      status: $enumDecodeNullable(_$ProfileStatusEnumMap, json['status']) ??
          ProfileStatus.initial,
      profileContact: json['profile_contact'] == null
          ? null
          : CoagContact.fromJson(
              json['profile_contact'] as Map<String, dynamic>),
      sharingSettings: json['sharing_settings'] == null
          ? null
          : ProfileSharingSettings.fromJson(
              json['sharing_settings'] as Map<String, dynamic>),
      circles: Map<String, String>.from(json['circles'] as Map),
      permissionsGranted: json['permissions_granted'] as bool? ?? false,
    );

Map<String, dynamic> _$ProfileStateToJson(ProfileState instance) =>
    <String, dynamic>{
      'status': _$ProfileStatusEnumMap[instance.status]!,
      'profile_contact': instance.profileContact?.toJson(),
      'circles': instance.circles,
      'sharing_settings': instance.sharingSettings?.toJson(),
      'permissions_granted': instance.permissionsGranted,
    };

const _$ProfileStatusEnumMap = {
  ProfileStatus.initial: 'initial',
  ProfileStatus.success: 'success',
  ProfileStatus.create: 'create',
  ProfileStatus.pick: 'pick',
};
