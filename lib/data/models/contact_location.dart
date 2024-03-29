// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'contact_location.g.dart';

@JsonSerializable()
class ContactLocation extends Equatable {
  ContactLocation(
      {required this.coagContactId,
      required this.longitude,
      required this.latitude});

  factory ContactLocation.fromJson(Map<String, dynamic> json) =>
      _$ContactLocationFromJson(json);

  final String coagContactId;
  final double longitude;
  final double latitude;

  Map<String, dynamic> toJson() => _$ContactLocationToJson(this);

  @override
  List<Object?> get props => [coagContactId, longitude, latitude];
}

@JsonSerializable()
class AddressLocation extends ContactLocation {
  factory AddressLocation.fromJson(Map<String, dynamic> json) =>
      _$AddressLocationFromJson(json);

  AddressLocation(
      {required super.coagContactId,
      required super.longitude,
      required super.latitude,
      required this.name});

  final String name;

  Map<String, dynamic> toJson() => _$AddressLocationToJson(this);

  @override
  List<Object?> get props => [coagContactId, longitude, latitude, name];
}

@JsonSerializable()
class TemporalLocation extends ContactLocation {
  factory TemporalLocation.fromJson(Map<String, dynamic> json) =>
      _$TemporalLocationFromJson(json);

  TemporalLocation(
      {required super.coagContactId,
      required super.longitude,
      required super.latitude,
      required this.start,
      required this.end,
      required this.details});

  final DateTime start;
  final DateTime end;
  final String details;

  Map<String, dynamic> toJson() => _$TemporalLocationToJson(this);

  @override
  List<Object?> get props =>
      [coagContactId, longitude, latitude, start, end, details];
}
