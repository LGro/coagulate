// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

part of 'cubit.dart';

enum UpdatesStatus { initial, success, denied }

extension UpdatesStatusX on UpdatesStatus {
  bool get isInitial => this == UpdatesStatus.initial;
  bool get isSuccess => this == UpdatesStatus.success;
  bool get isDenied => this == UpdatesStatus.denied;
}

@JsonSerializable()
class Update {
  Update({required this.message, required this.timestamp});

  factory Update.fromJson(Map<String, dynamic> json) => _$UpdateFromJson(json);
  final String message;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => _$UpdateToJson(this);

  @override
  List<Object?> get props => [message, timestamp];
}

@JsonSerializable()
final class UpdatesState extends Equatable {
  const UpdatesState(this.status, {this.updates = const []});

  factory UpdatesState.fromJson(Map<String, dynamic> json) =>
      _$UpdatesStateFromJson(json);

  final Iterable<Update> updates;
  final UpdatesStatus status;

  Map<String, dynamic> toJson() => _$UpdatesStateToJson(this);

  @override
  List<Object?> get props => [updates, status];
}
