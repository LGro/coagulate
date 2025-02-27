// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

part of 'cubit.dart';

enum CircleDetailsStatus { initial, success, denied }

extension CircleDetailsStatusX on CircleDetailsStatus {
  bool get isInitial => this == CircleDetailsStatus.initial;
  bool get isSuccess => this == CircleDetailsStatus.success;
  bool get isDenied => this == CircleDetailsStatus.denied;
}

@JsonSerializable()
final class CircleDetailsState extends Equatable {
  const CircleDetailsState(this.status,
      {this.circleMemberships = const {},
      this.circleId,
      this.profileInfo,
      this.contacts = const [],
      this.circles = const {}});

  factory CircleDetailsState.fromJson(Map<String, dynamic> json) =>
      _$CircleDetailsStateFromJson(json);

  final Map<String, List<String>> circleMemberships;
  final Map<String, String> circles;
  final String? circleId;
  final CircleDetailsStatus status;
  final Iterable<CoagContact> contacts;
  final ProfileInfo? profileInfo;

  CircleDetailsState copyWith(
          {CircleDetailsStatus? status,
          Map<String, List<String>>? circleMemberships,
          String? selectedCircle,
          Map<String, String>? circles,
          String? circleId,
          ProfileInfo? profileInfo,
          Iterable<CoagContact>? contacts}) =>
      CircleDetailsState(
        status ?? this.status,
        circleMemberships: circleMemberships ?? this.circleMemberships,
        circleId: circleId ?? this.circleId,
        circles: circles ?? this.circles,
        contacts: contacts ?? this.contacts,
        profileInfo: profileInfo ?? this.profileInfo,
      );

  Map<String, dynamic> toJson() => _$CircleDetailsStateToJson(this);

  @override
  List<Object?> get props => [
        status,
        circleMemberships,
        circles,
        circleId,
        contacts,
        profileInfo,
      ];
}
