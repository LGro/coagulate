// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

part of 'cubit.dart';

enum MapStatus { initial, success, denied }

extension MapStatusX on MapStatus {
  bool get isInitial => this == MapStatus.initial;
  bool get isSuccess => this == MapStatus.success;
  bool get isDenied => this == MapStatus.denied;
}

enum MarkerType { address, temporary, checkedIn }

@JsonSerializable()
final class MapState extends Equatable {
  const MapState({
    required this.status,
    this.contacts = const [],
    this.circleMemberships = const {},
    this.circles = const {},
    this.profileInfo,
    this.cachePath,
  });

  factory MapState.fromJson(Map<String, dynamic> json) =>
      _$MapStateFromJson(json);

  final List<CoagContact> contacts;
  final Map<String, List<String>> circleMemberships;
  final Map<String, String> circles;
  final ProfileInfo? profileInfo;
  final MapStatus status;
  final String? cachePath;

  Map<String, dynamic> toJson() => _$MapStateToJson(this);

  @override
  List<Object?> get props => [
        contacts,
        circleMemberships,
        circles,
        profileInfo,
        contacts,
        status,
        cachePath,
      ];
}
