// Copyright 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

part of 'cubit.dart';

@JsonSerializable()
final class DhtSharingStatusState extends Equatable {
  const DhtSharingStatusState(this.status);
  final String status;

  factory DhtSharingStatusState.fromJson(Map<String, dynamic> json) =>
      _$DhtSharingStatusStateFromJson(json);

  Map<String, dynamic> toJson() => _$DhtSharingStatusStateToJson(this);

  @override
  List<Object?> get props => [status];
}
