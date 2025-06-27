// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DhtBatchInviteStatusState _$DhtBatchInviteStatusStateFromJson(
        Map<String, dynamic> json) =>
    DhtBatchInviteStatusState(
      json['status'] as String,
      subkeyNames: (json['subkey_names'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(int.parse(k), e as String?),
          ) ??
          const {},
    );

Map<String, dynamic> _$DhtBatchInviteStatusStateToJson(
        DhtBatchInviteStatusState instance) =>
    <String, dynamic>{
      'status': instance.status,
      'subkey_names':
          instance.subkeyNames.map((k, e) => MapEntry(k.toString(), e)),
    };
