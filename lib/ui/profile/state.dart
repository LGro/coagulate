// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

part of 'cubit.dart';

enum ProfileStatus { initial, success, create, pick }

extension ProfileStatusX on ProfileStatus {
  bool get isInitial => this == ProfileStatus.initial;
  bool get isSuccess => this == ProfileStatus.success;
  bool get isCreate => this == ProfileStatus.create;
  bool get isPick => this == ProfileStatus.pick;
}

@JsonSerializable()
final class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profileContact,
  });

  factory ProfileState.fromJson(Map<String, dynamic> json) =>
      _$ProfileStateFromJson(json);

  final ProfileStatus status;
  final CoagContact? profileContact;

  ProfileState copyWith({
    ProfileStatus? status,
    CoagContact? profileContact,
  }) =>
      ProfileState(
        status: status ?? this.status,
        profileContact: profileContact ?? this.profileContact,
      );

  Map<String, dynamic> toJson() => _$ProfileStateToJson(this);

  @override
  List<Object?> get props => [status, profileContact];
}
