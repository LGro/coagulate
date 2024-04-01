// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecieveRequestState _$RecieveRequestStateFromJson(Map<String, dynamic> json) =>
    RecieveRequestState(
      $enumDecode(_$RecieveRequestStatusEnumMap, json['status']),
      profile: json['profile'] == null
          ? null
          : CoagContact.fromJson(json['profile'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RecieveRequestStateToJson(
        RecieveRequestState instance) =>
    <String, dynamic>{
      'status': _$RecieveRequestStatusEnumMap[instance.status]!,
      'profile': instance.profile?.toJson(),
    };

const _$RecieveRequestStatusEnumMap = {
  RecieveRequestStatus.qrcode: 'qrcode',
  RecieveRequestStatus.processing: 'processing',
  RecieveRequestStatus.received: 'received',
};
