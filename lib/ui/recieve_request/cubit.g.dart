// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecieveRequestState _$RecieveRequestStateFromJson(Map<String, dynamic> json) =>
    RecieveRequestState(
      $enumDecode(_$RecieveRequestStatusEnumMap, json['status']),
      profile: json['profile'] as String?,
    );

Map<String, dynamic> _$RecieveRequestStateToJson(
        RecieveRequestState instance) =>
    <String, dynamic>{
      'status': _$RecieveRequestStatusEnumMap[instance.status]!,
      'profile': instance.profile,
    };

const _$RecieveRequestStatusEnumMap = {
  RecieveRequestStatus.pickMode: 'pickMode',
  RecieveRequestStatus.processing: 'processing',
  RecieveRequestStatus.nfc: 'nfc',
  RecieveRequestStatus.qrcode: 'qrcode',
  RecieveRequestStatus.paste: 'paste',
  RecieveRequestStatus.recieved: 'recieved',
};
