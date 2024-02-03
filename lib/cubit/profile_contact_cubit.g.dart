// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_contact_cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileContactState _$ProfileContactStateFromJson(Map<String, dynamic> json) =>
    ProfileContactState(
      status:
          $enumDecodeNullable(_$ProfileContactStatusEnumMap, json['status']) ??
              ProfileContactStatus.initial,
      profileContact: json['profile_contact'] == null
          ? null
          : Contact.fromJson(json['profile_contact'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProfileContactStateToJson(
        ProfileContactState instance) =>
    <String, dynamic>{
      'status': _$ProfileContactStatusEnumMap[instance.status]!,
      'profile_contact': instance.profileContact?.toJson(),
    };

const _$ProfileContactStatusEnumMap = {
  ProfileContactStatus.initial: 'initial',
  ProfileContactStatus.loading: 'loading',
  ProfileContactStatus.success: 'success',
  ProfileContactStatus.unavailable: 'unavailable',
};
