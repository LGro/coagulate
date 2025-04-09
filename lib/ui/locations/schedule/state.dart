// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

part of 'cubit.dart';

@JsonSerializable()
final class ScheduleState extends Equatable {
  const ScheduleState(
      {required this.checkingIn,
      required this.circles,
      required this.circleMemberships});

  factory ScheduleState.fromJson(Map<String, dynamic> json) =>
      _$ScheduleStateFromJson(json);

  final bool checkingIn;
  final Map<String, String> circles;
  final Map<String, List<String>> circleMemberships;

  Map<String, dynamic> toJson() => _$ScheduleStateToJson(this);

  ScheduleState copyWith(
          {bool? checkingIn,
          Map<String, String>? circles,
          Map<String, List<String>>? circleMemberships}) =>
      ScheduleState(
          checkingIn: checkingIn ?? this.checkingIn,
          circles: circles ?? this.circles,
          circleMemberships: circleMemberships ?? this.circleMemberships);

  @override
  List<Object?> get props => [checkingIn, circles, circleMemberships];
}
