// Copyright 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

part of 'cubit.dart';

@JsonSerializable()
final class VeilidStatusState extends Equatable {
  const VeilidStatusState(this.status);
  final String status;

  factory VeilidStatusState.fromJson(Map<String, dynamic> json) =>
      _$VeilidStatusStateFromJson(json);

  Map<String, dynamic> toJson() => _$VeilidStatusStateToJson(this);

  @override
  List<Object?> get props => [status];
}
