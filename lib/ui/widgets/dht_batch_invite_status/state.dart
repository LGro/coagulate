// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

part of 'cubit.dart';

@JsonSerializable()
final class DhtBatchInviteStatusState extends Equatable {
  const DhtBatchInviteStatusState(this.status, {this.subkeyNames = const {}});

  factory DhtBatchInviteStatusState.fromJson(Map<String, dynamic> json) =>
      _$DhtBatchInviteStatusStateFromJson(json);

  final String status;
  final Map<int, String?> subkeyNames;

  Map<String, dynamic> toJson() => _$DhtBatchInviteStatusStateToJson(this);

  @override
  List<Object?> get props => [status, subkeyNames];
}
