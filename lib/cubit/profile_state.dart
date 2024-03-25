// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0
part of 'profile_cubit.dart';

enum ProfileStatus { initial, success, create, pick }

extension ProfileStatusX on ProfileStatus {
  bool get isInitial => this == ProfileStatus.initial;
  bool get isSuccess => this == ProfileStatus.success;
  bool get isCreate => this == ProfileStatus.create;
  bool get isPick => this == ProfileStatus.pick;
}

@JsonSerializable()
final class ProfileState extends Equatable {
  ProfileState({
    this.status = ProfileStatus.initial,
    this.profileContact,
    this.locationCoordinates,
  });

  factory ProfileState.fromJson(Map<String, dynamic> json) =>
      _$ProfileStateFromJson(json);

  final ProfileStatus status;
  final Contact? profileContact;
  final Map<String, (num, num)>? locationCoordinates;

  ProfileState copyWith(
          {ProfileStatus? status,
          Contact? profileContact,
          Map<String, (num, num)>? locationCoordinates}) =>
      ProfileState(
        status: status ?? this.status,
        profileContact: profileContact ?? this.profileContact,
        locationCoordinates: locationCoordinates ?? this.locationCoordinates,
      );

  Map<String, dynamic> toJson() => _$ProfileStateToJson(this);

  @override
  List<Object?> get props => [status, profileContact, locationCoordinates];
}
