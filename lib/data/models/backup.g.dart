// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountBackup _$AccountBackupFromJson(Map<String, dynamic> json) =>
    AccountBackup(
      ProfileInfo.fromJson(json['profile_info'] as Map<String, dynamic>),
      (json['contacts'] as List<dynamic>)
          .map((e) => CoagContact.fromJson(e as Map<String, dynamic>))
          .toList(),
      Map<String, String>.from(json['circles'] as Map),
      (json['circle_memberships'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ),
    );

Map<String, dynamic> _$AccountBackupToJson(AccountBackup instance) =>
    <String, dynamic>{
      'profile_info': instance.profileInfo.toJson(),
      'contacts': instance.contacts.map((e) => e.toJson()).toList(),
      'circles': instance.circles,
      'circle_memberships': instance.circleMemberships,
    };
