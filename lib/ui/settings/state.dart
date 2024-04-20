// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

part of 'cubit.dart';

enum SettingsStatus { initial, success, create, pick }

extension SettingsStatusX on SettingsStatus {
  bool get isInitial => this == SettingsStatus.initial;
  bool get isSuccess => this == SettingsStatus.success;
  bool get isCreate => this == SettingsStatus.create;
  bool get isPick => this == SettingsStatus.pick;
}

@JsonSerializable()
final class SettingsState extends Equatable {
  const SettingsState({required this.status, required this.message});

  factory SettingsState.fromJson(Map<String, dynamic> json) =>
      _$SettingsStateFromJson(json);

  final SettingsStatus status;
  final String message;

  Map<String, dynamic> toJson() => _$SettingsStateToJson(this);

  @override
  List<Object?> get props => [status, message];
}
