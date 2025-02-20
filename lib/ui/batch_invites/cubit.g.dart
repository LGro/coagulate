// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Batch _$BatchFromJson(Map<String, dynamic> json) => Batch(
      label: json['label'] as String,
      expiration: DateTime.parse(json['expiration'] as String),
      dhtRecordKey:
          Typed<FixedEncodedString43>.fromJson(json['dht_record_key']),
      writer: KeyPair.fromJson(json['writer']),
      subkeyWriters: (json['subkey_writers'] as List<dynamic>)
          .map(KeyPair.fromJson)
          .toList(),
      psk: FixedEncodedString43.fromJson(json['psk']),
    );

Map<String, dynamic> _$BatchToJson(Batch instance) => <String, dynamic>{
      'label': instance.label,
      'expiration': instance.expiration.toIso8601String(),
      'dht_record_key': instance.dhtRecordKey.toJson(),
      'writer': instance.writer.toJson(),
      'subkey_writers': instance.subkeyWriters.map((e) => e.toJson()).toList(),
      'psk': instance.psk.toJson(),
    };

BatchInvitesState _$BatchInvitesStateFromJson(Map<String, dynamic> json) =>
    BatchInvitesState(
      batches: (json['batches'] as List<dynamic>?)
              ?.map((e) => Batch.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$BatchInvitesStateToJson(BatchInvitesState instance) =>
    <String, dynamic>{
      'batches': instance.batches.map((e) => e.toJson()).toList(),
    };
