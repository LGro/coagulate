// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

part of 'cubit.dart';

enum IntroduceContactsStatus { initial, success, create, pick }

extension IntroduceContactsStatusX on IntroduceContactsStatus {
  bool get isInitial => this == IntroduceContactsStatus.initial;
  bool get isSuccess => this == IntroduceContactsStatus.success;
  bool get isCreate => this == IntroduceContactsStatus.create;
  bool get isPick => this == IntroduceContactsStatus.pick;
}

@JsonSerializable()
final class IntroduceContactsState extends Equatable {
  const IntroduceContactsState(this.status, {this.contacts = const []});

  factory IntroduceContactsState.fromJson(Map<String, dynamic> json) =>
      _$IntroduceContactsStateFromJson(json);

  final IntroduceContactsStatus status;
  final List<CoagContact> contacts;

  Map<String, dynamic> toJson() => _$IntroduceContactsStateToJson(this);

  @override
  List<Object?> get props => [status, contacts];
}
