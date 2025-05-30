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
  const SettingsState(
      {required this.darkMode,
      required this.mapProvider,
      required this.autoAddressResolution,
      required this.status,
      required this.message});

  factory SettingsState.fromJson(Map<String, dynamic> json) =>
      _$SettingsStateFromJson(json);

  final SettingsStatus status;
  final String message;
  final bool darkMode;
  final MapProvider mapProvider;
  final bool autoAddressResolution;

  Map<String, dynamic> toJson() => _$SettingsStateToJson(this);

  SettingsState copyWith({
    bool? darkMode,
    MapProvider? mapProvider,
    bool? autoAddressResolution,
    SettingsStatus? status,
    String? message,
  }) =>
      SettingsState(
        darkMode: darkMode ?? this.darkMode,
        mapProvider: mapProvider ?? this.mapProvider,
        autoAddressResolution:
            autoAddressResolution ?? this.autoAddressResolution,
        status: status ?? this.status,
        message: message ?? this.message,
      );

  @override
  List<Object?> get props =>
      [status, message, darkMode, mapProvider, autoAddressResolution];
}
