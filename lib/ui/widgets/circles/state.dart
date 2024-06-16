// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

part of 'cubit.dart';

@JsonSerializable()
final class CirclesState extends Equatable {
  const CirclesState(this.circles);
  final List<(String, String, bool, int)> circles;

  factory CirclesState.fromJson(Map<String, dynamic> json) =>
      _$CirclesStateFromJson(json);

  Map<String, dynamic> toJson() => _$CirclesStateToJson(this);

  @override
  List<Object?> get props => [circles];
}
