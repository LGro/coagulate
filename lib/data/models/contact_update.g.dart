// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactUpdate _$ContactUpdateFromJson(Map<String, dynamic> json) =>
    ContactUpdate(
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$ContactUpdateToJson(ContactUpdate instance) =>
    <String, dynamic>{
      'message': instance.message,
      'timestamp': instance.timestamp.toIso8601String(),
    };
