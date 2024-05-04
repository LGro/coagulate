// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

part of 'cubit.dart';

@JsonSerializable()
final class CheckInState extends Equatable {
  const CheckInState({this.checkingIn = false});

  factory CheckInState.fromJson(Map<String, dynamic> json) =>
      _$CheckInStateFromJson(json);

  final bool checkingIn;

  Map<String, dynamic> toJson() => _$CheckInStateToJson(this);

  @override
  List<Object?> get props => [checkingIn];
}
