// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

part of 'cubit.dart';

@JsonSerializable()
final class LocationsState extends Equatable {
  const LocationsState({this.temporaryLocations = const []});

  factory LocationsState.fromJson(Map<String, dynamic> json) =>
      _$LocationsStateFromJson(json);

  final Iterable<ContactTemporaryLocation> temporaryLocations;

  Map<String, dynamic> toJson() => _$LocationsStateToJson(this);

  @override
  List<Object?> get props => [temporaryLocations];
}
