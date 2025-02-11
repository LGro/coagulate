// Copyright 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

part of 'cubit.dart';

@JsonSerializable()
final class DhtStatusState extends Equatable {
  const DhtStatusState(this.status);
  final String status;

  factory DhtStatusState.fromJson(Map<String, dynamic> json) =>
      _$DhtStatusStateFromJson(json);

  Map<String, dynamic> toJson() => _$DhtStatusStateToJson(this);

  @override
  List<Object?> get props => [status];
}
