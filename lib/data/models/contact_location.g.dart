// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactLocation _$ContactLocationFromJson(Map<String, dynamic> json) =>
    ContactLocation(
      coagContactId: json['coag_contact_id'] as String,
      longitude: (json['longitude'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
    );

Map<String, dynamic> _$ContactLocationToJson(ContactLocation instance) =>
    <String, dynamic>{
      'coag_contact_id': instance.coagContactId,
      'longitude': instance.longitude,
      'latitude': instance.latitude,
    };

AddressLocation _$AddressLocationFromJson(Map<String, dynamic> json) =>
    AddressLocation(
      coagContactId: json['coag_contact_id'] as String,
      longitude: (json['longitude'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$AddressLocationToJson(AddressLocation instance) =>
    <String, dynamic>{
      'coag_contact_id': instance.coagContactId,
      'longitude': instance.longitude,
      'latitude': instance.latitude,
      'name': instance.name,
    };

TemporalLocation _$TemporalLocationFromJson(Map<String, dynamic> json) =>
    TemporalLocation(
      coagContactId: json['coag_contact_id'] as String,
      longitude: (json['longitude'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
      details: json['details'] as String,
    );

Map<String, dynamic> _$TemporalLocationToJson(TemporalLocation instance) =>
    <String, dynamic>{
      'coag_contact_id': instance.coagContactId,
      'longitude': instance.longitude,
      'latitude': instance.latitude,
      'start': instance.start.toIso8601String(),
      'end': instance.end.toIso8601String(),
      'details': instance.details,
    };
