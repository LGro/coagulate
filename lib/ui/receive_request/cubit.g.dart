// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReceiveRequestState _$ReceiveRequestStateFromJson(Map<String, dynamic> json) =>
    ReceiveRequestState(
      $enumDecode(_$ReceiveRequestStatusEnumMap, json['status']),
      profile: json['profile'] == null
          ? null
          : CoagContact.fromJson(json['profile'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ReceiveRequestStateToJson(
        ReceiveRequestState instance) =>
    <String, dynamic>{
      'status': _$ReceiveRequestStatusEnumMap[instance.status]!,
      'profile': instance.profile?.toJson(),
    };

const _$ReceiveRequestStatusEnumMap = {
  ReceiveRequestStatus.qrcode: 'qrcode',
  ReceiveRequestStatus.processing: 'processing',
  ReceiveRequestStatus.received: 'received',
};
