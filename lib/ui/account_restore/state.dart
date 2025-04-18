// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

part of 'cubit.dart';

enum RestoreStatus { initial, success, create, failure }

extension RestoreStatusX on RestoreStatus {
  bool get isInitial => this == RestoreStatus.initial;
  bool get isSuccess => this == RestoreStatus.success;
  bool get isCreate => this == RestoreStatus.create;
  bool get isFailure => this == RestoreStatus.failure;
}

@JsonSerializable()
final class RestoreState extends Equatable {
  const RestoreState({this.status = RestoreStatus.initial});

  factory RestoreState.fromJson(Map<String, dynamic> json) =>
      _$RestoreStateFromJson(json);

  final RestoreStatus status;

  Map<String, dynamic> toJson() => _$RestoreStateToJson(this);

  @override
  List<Object?> get props => [status];
}
