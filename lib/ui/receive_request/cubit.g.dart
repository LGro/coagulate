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
      requestSettings: json['request_settings'] == null
          ? null
          : ContactDHTSettings.fromJson(
              json['request_settings'] as Map<String, dynamic>),
      contactProporsalsForLinking:
          (json['contact_proporsals_for_linking'] as List<dynamic>?)
                  ?.map((e) => CoagContact.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              const [],
    );

Map<String, dynamic> _$ReceiveRequestStateToJson(
        ReceiveRequestState instance) =>
    <String, dynamic>{
      'status': _$ReceiveRequestStatusEnumMap[instance.status]!,
      'profile': instance.profile?.toJson(),
      'request_settings': instance.requestSettings?.toJson(),
      'contact_proporsals_for_linking':
          instance.contactProporsalsForLinking.map((e) => e.toJson()).toList(),
    };

const _$ReceiveRequestStatusEnumMap = {
  ReceiveRequestStatus.qrcode: 'qrcode',
  ReceiveRequestStatus.processing: 'processing',
  ReceiveRequestStatus.receivedShare: 'receivedShare',
  ReceiveRequestStatus.receivedRequest: 'receivedRequest',
};
