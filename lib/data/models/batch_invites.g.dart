// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'batch_invites.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BatchInviteInfoSchema _$BatchInviteInfoSchemaFromJson(
        Map<String, dynamic> json) =>
    BatchInviteInfoSchema(
      json['label'] as String,
      DateTime.parse(json['expiration'] as String),
    );

Map<String, dynamic> _$BatchInviteInfoSchemaToJson(
        BatchInviteInfoSchema instance) =>
    <String, dynamic>{
      'label': instance.label,
      'expiration': instance.expiration.toIso8601String(),
    };

BatchSubkeySchema _$BatchSubkeySchemaFromJson(Map<String, dynamic> json) =>
    BatchSubkeySchema(
      json['name'] as String,
      FixedEncodedString43.fromJson(json['public_key']),
      (json['records'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, Typed<FixedEncodedString43>.fromJson(e)),
      ),
    );

Map<String, dynamic> _$BatchSubkeySchemaToJson(BatchSubkeySchema instance) =>
    <String, dynamic>{
      'name': instance.name,
      'public_key': instance.publicKey.toJson(),
      'records': instance.records.map((k, e) => MapEntry(k, e.toJson())),
    };

BatchInvite _$BatchInviteFromJson(Map<String, dynamic> json) => BatchInvite(
      label: json['label'] as String,
      expiration: DateTime.parse(json['expiration'] as String),
      recordKey: Typed<FixedEncodedString43>.fromJson(json['record_key']),
      psk: FixedEncodedString43.fromJson(json['psk']),
      subkeyCount: (json['subkey_count'] as num).toInt(),
      mySubkey: (json['my_subkey'] as num).toInt(),
      subkeyWriter: KeyPair.fromJson(json['subkey_writer']),
      myName: json['my_name'] as String,
      myKeyPair: TypedKeyPair.fromJson(json['my_key_pair']),
      myConnectionRecords:
          (json['my_connection_records'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, Typed<FixedEncodedString43>.fromJson(e)),
              ) ??
              const {},
    );

Map<String, dynamic> _$BatchInviteToJson(BatchInvite instance) =>
    <String, dynamic>{
      'label': instance.label,
      'expiration': instance.expiration.toIso8601String(),
      'record_key': instance.recordKey.toJson(),
      'psk': instance.psk.toJson(),
      'subkey_count': instance.subkeyCount,
      'my_subkey': instance.mySubkey,
      'subkey_writer': instance.subkeyWriter.toJson(),
      'my_name': instance.myName,
      'my_key_pair': instance.myKeyPair.toJson(),
      'my_connection_records':
          instance.myConnectionRecords.map((k, e) => MapEntry(k, e.toJson())),
    };
