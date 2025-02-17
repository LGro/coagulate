// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

part of 'cubit.dart';

enum ProfileStatus { initial, success }

extension ProfileStatusX on ProfileStatus {
  bool get isInitial => this == ProfileStatus.initial;
  bool get isSuccess => this == ProfileStatus.success;
}

@JsonSerializable()
final class ProfileState extends Equatable {
  const ProfileState({
    required this.profileInfo,
    this.status = ProfileStatus.initial,
    this.circles = const {},
    this.circleMemberships = const {},
    this.permissionsGranted = false,
  });

  factory ProfileState.fromJson(Map<String, dynamic> json) =>
      _$ProfileStateFromJson(json);

  final ProfileStatus status;
  final ProfileInfo profileInfo;
  final Map<String, String> circles;
  final Map<String, List<String>> circleMemberships;
  final bool permissionsGranted;

  ProfileState copyWith({
    ProfileStatus? status,
    ProfileInfo? profileInfo,
    Map<String, String>? circles,
    Map<String, List<String>>? circleMemberships,
    bool? permissionsGranted,
  }) =>
      ProfileState(
        status: status ?? this.status,
        profileInfo: profileInfo ?? this.profileInfo,
        circles: circles ?? this.circles,
        circleMemberships: circleMemberships ?? this.circleMemberships,
        permissionsGranted: permissionsGranted ?? this.permissionsGranted,
      );

  Map<String, dynamic> toJson() => _$ProfileStateToJson(this);

  @override
  List<Object?> get props => [
        status,
        profileInfo,
        circles,
        circleMemberships,
        permissionsGranted,
      ];
}
