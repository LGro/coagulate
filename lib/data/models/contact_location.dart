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
    this.name,
    this.start,
    this.end,
    this.details,
  });

  factory ContactTemporaryLocation.fromJson(Map<String, dynamic> json) =>
      _$ContactTemporaryLocationFromJson(json);

  final String coagContactId;
  final double longitude;
  final double latitude;
  final String? name;
  final DateTime? start;
  final DateTime? end;
  final String? details;

  Map<String, dynamic> toJson() => _$ContactTemporaryLocationToJson(this);

  @override
  List<Object?> get props =>
      [coagContactId, longitude, latitude, name, start, end, details];
}
