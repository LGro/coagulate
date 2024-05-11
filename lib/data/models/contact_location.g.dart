// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactAddressLocation _$ContactAddressLocationFromJson(
        Map<String, dynamic> json) =>
    ContactAddressLocation(
      coagContactId: json['coag_contact_id'] as String,
      longitude: (json['longitude'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$ContactAddressLocationToJson(
        ContactAddressLocation instance) =>
    <String, dynamic>{
      'coag_contact_id': instance.coagContactId,
      'longitude': instance.longitude,
      'latitude': instance.latitude,
      'name': instance.name,
    };

ContactTemporaryLocation _$ContactTemporaryLocationFromJson(
        Map<String, dynamic> json) =>
    ContactTemporaryLocation(
      coagContactId: json['coag_contact_id'] as String,
      longitude: (json['longitude'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      name: json['name'] as String,
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
      details: json['details'] as String,
      circles: (json['circles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      checkedIn: json['checked_in'] as bool? ?? false,
    );

Map<String, dynamic> _$ContactTemporaryLocationToJson(
        ContactTemporaryLocation instance) =>
    <String, dynamic>{
      'coag_contact_id': instance.coagContactId,
      'longitude': instance.longitude,
      'latitude': instance.latitude,
      'name': instance.name,
      'start': instance.start.toIso8601String(),
      'end': instance.end.toIso8601String(),
      'details': instance.details,
      'circles': instance.circles,
      'checked_in': instance.checkedIn,
    };
