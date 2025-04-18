// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

part of 'cubit.dart';

enum BackupStatus { initial, success, create, failure }

extension BackupStatusX on BackupStatus {
  bool get isInitial => this == BackupStatus.initial;
  bool get isSuccess => this == BackupStatus.success;
  bool get isCreate => this == BackupStatus.create;
  bool get isFailure => this == BackupStatus.failure;
}

@JsonSerializable()
final class BackupState extends Equatable {
  const BackupState(
      {this.status = BackupStatus.initial, this.dhtRecordKey, this.secret});

  factory BackupState.fromJson(Map<String, dynamic> json) =>
      _$BackupStateFromJson(json);

  final BackupStatus status;
  final Typed<FixedEncodedString43>? dhtRecordKey;
  final FixedEncodedString43? secret;

  Map<String, dynamic> toJson() => _$BackupStateToJson(this);

  @override
  List<Object?> get props => [status, dhtRecordKey, secret];
}
