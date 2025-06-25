// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_introduction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactIntroduction _$ContactIntroductionFromJson(Map<String, dynamic> json) =>
    ContactIntroduction(
      otherName: json['other_name'] as String,
      otherPublicKey: FixedEncodedString43.fromJson(json['other_public_key']),
      publicKey: FixedEncodedString43.fromJson(json['public_key']),
      dhtRecordKeyReceiving: Typed<FixedEncodedString43>.fromJson(
          json['dht_record_key_receiving']),
      dhtRecordKeySharing:
          Typed<FixedEncodedString43>.fromJson(json['dht_record_key_sharing']),
      dhtWriterSharing: KeyPair.fromJson(json['dht_writer_sharing']),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$ContactIntroductionToJson(
        ContactIntroduction instance) =>
    <String, dynamic>{
      'other_name': instance.otherName,
      'other_public_key': instance.otherPublicKey.toJson(),
      'public_key': instance.publicKey.toJson(),
      'message': instance.message,
      'dht_record_key_receiving': instance.dhtRecordKeyReceiving.toJson(),
      'dht_record_key_sharing': instance.dhtRecordKeySharing.toJson(),
      'dht_writer_sharing': instance.dhtWriterSharing.toJson(),
    };
