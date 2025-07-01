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
      fragment: json['fragment'] as String?,
    );

Map<String, dynamic> _$ReceiveRequestStateToJson(
        ReceiveRequestState instance) =>
    <String, dynamic>{
      'status': _$ReceiveRequestStatusEnumMap[instance.status]!,
      'profile': instance.profile?.toJson(),
      'fragment': instance.fragment,
    };

const _$ReceiveRequestStatusEnumMap = {
  ReceiveRequestStatus.handleBatchInvite: 'handleBatchInvite',
  ReceiveRequestStatus.handleDirectSharing: 'handleDirectSharing',
  ReceiveRequestStatus.handleProfileLink: 'handleProfileLink',
  ReceiveRequestStatus.handleSharingOffer: 'handleSharingOffer',
  ReceiveRequestStatus.qrcode: 'qrcode',
  ReceiveRequestStatus.processing: 'processing',
  ReceiveRequestStatus.success: 'success',
  ReceiveRequestStatus.batchInviteConfirmed: 'batchInviteConfirmed',
  ReceiveRequestStatus.batchInviteSuccess: 'batchInviteSuccess',
  ReceiveRequestStatus.malformedUrl: 'malformedUrl',
};
