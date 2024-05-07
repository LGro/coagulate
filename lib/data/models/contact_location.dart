// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'contact_location.g.dart';

@JsonSerializable()
class ContactAddressLocation extends Equatable {
  const ContactAddressLocation({
    required this.coagContactId,
    required this.longitude,
    required this.latitude,
    required this.name,
  });

  factory ContactAddressLocation.fromJson(Map<String, dynamic> json) =>
      _$ContactAddressLocationFromJson(json);

  final String coagContactId;
  final double longitude;
  final double latitude;
  final String name;

  Map<String, dynamic> toJson() => _$ContactAddressLocationToJson(this);

  @override
  List<Object?> get props => [coagContactId, longitude, latitude, name];
}

@JsonSerializable()
class ContactTemporaryLocation extends Equatable {
  const ContactTemporaryLocation({
    required this.coagContactId,
    required this.longitude,
    required this.latitude,
    required this.name,
    required this.start,
    required this.end,
    required this.details,
    this.checkedIn = false,
  });

  factory ContactTemporaryLocation.fromJson(Map<String, dynamic> json) =>
      _$ContactTemporaryLocationFromJson(json);

  /// Contact id this location belongs to
  final String coagContactId;

  /// Longitude coordinate of the location
  final double longitude;

  /// Latitude coordinate of the location
  final double latitude;

  /// Name of the location/event or short description
  final String name;

  /// Start timestamp
  final DateTime start;

  /// End timestamp
  final DateTime end;

  /// Longer description
  final String details;

  /// Mark presence at the location
  final bool checkedIn;

  Map<String, dynamic> toJson() => _$ContactTemporaryLocationToJson(this);

  @override
  List<Object?> get props => [
        coagContactId,
        longitude,
        latitude,
        name,
        start,
        end,
        details,
        checkedIn
      ];

  ContactTemporaryLocation copyWith(
          {String? coagContactId,
          double? longitude,
          double? latitude,
          String? name,
          DateTime? start,
          DateTime? end,
          String? details,
          bool? checkedIn}) =>
      ContactTemporaryLocation(
          coagContactId: coagContactId ?? this.coagContactId,
          longitude: longitude ?? this.longitude,
          latitude: latitude ?? this.latitude,
          name: name ?? this.name,
          start: start ?? this.start,
          end: end ?? this.end,
          details: details ?? this.details,
          checkedIn: checkedIn ?? this.checkedIn);
}
