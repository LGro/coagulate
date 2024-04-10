// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

part of 'cubit.dart';

enum MapStatus { initial, success, denied }

extension MapStatusX on MapStatus {
  bool get isInitial => this == MapStatus.initial;
  bool get isSuccess => this == MapStatus.success;
  bool get isDenied => this == MapStatus.denied;
}

@JsonSerializable()
class Location {
  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);
  Location(
      {required this.coagContactId,
      required this.longitude,
      required this.latitude,
      required this.label,
      required this.subLabel});

  final String coagContactId;
  final double longitude;
  final double latitude;
  final String label;
  final String subLabel;
  Map<String, dynamic> toJson() => _$LocationToJson(this);
}

@JsonSerializable()
final class MapState extends Equatable {
  const MapState(this.locations, this.status, {this.mapboxApiToken = ''});

  factory MapState.fromJson(Map<String, dynamic> json) =>
      _$MapStateFromJson(json);

  final Iterable<Location> locations;
  final MapStatus status;
  // TODO: Use this or remove it again.
  final String mapboxApiToken;

  Map<String, dynamic> toJson() => _$MapStateToJson(this);

  @override
  List<Object?> get props => [locations, status, mapboxApiToken];
}