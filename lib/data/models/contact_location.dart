// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'contact_location.g.dart';

// TODO: This feels like a super type, but sub types don't seem to work well with simple reloading
@JsonSerializable()
class ContactLocation extends Equatable {
  const ContactLocation({
    required this.coagContactId,
    required this.longitude,
    required this.latitude,
    this.name,
    this.start,
    this.end,
    this.details,
  });

  factory ContactLocation.fromJson(Map<String, dynamic> json) =>
      _$ContactLocationFromJson(json);

  final String coagContactId;
  final double longitude;
  final double latitude;
  final String? name;
  final DateTime? start;
  final DateTime? end;
  final String? details;

  Map<String, dynamic> toJson() => _$ContactLocationToJson(this);

  @override
  List<Object?> get props =>
      [coagContactId, longitude, latitude, name, start, end, details];
}
