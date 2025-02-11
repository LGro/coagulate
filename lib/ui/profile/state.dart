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
    this.status = ProfileStatus.initial,
    this.profileContact,
    this.sharingSettings,
    this.circles = const {},
    this.circleMemberships = const {},
    this.permissionsGranted = false,
  });

  factory ProfileState.fromJson(Map<String, dynamic> json) =>
      _$ProfileStateFromJson(json);

  final ProfileStatus status;
  final CoagContact? profileContact;
  final Map<String, String> circles;
  final Map<String, List<String>> circleMemberships;
  final ProfileSharingSettings? sharingSettings;
  final bool permissionsGranted;

  ProfileState copyWith({
    ProfileStatus? status,
    CoagContact? profileContact,
    Map<String, String>? circles,
    Map<String, List<String>>? circleMemberships,
    ProfileSharingSettings? sharingSettings,
    bool? permissionsGranted,
  }) =>
      ProfileState(
        status: status ?? this.status,
        profileContact: profileContact ?? this.profileContact,
        sharingSettings: sharingSettings ?? this.sharingSettings,
        circles: circles ?? this.circles,
        circleMemberships: circleMemberships ?? this.circleMemberships,
        permissionsGranted: permissionsGranted ?? this.permissionsGranted,
      );

  Map<String, dynamic> toJson() => _$ProfileStateToJson(this);

  @override
  List<Object?> get props => [
        status,
        profileContact,
        circles,
        circleMemberships,
        sharingSettings,
        permissionsGranted,
      ];
}
