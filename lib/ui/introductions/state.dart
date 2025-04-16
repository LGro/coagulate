// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

part of 'cubit.dart';

@JsonSerializable()
final class IntroductionsState extends Equatable {
  const IntroductionsState({this.contacts = const {}});

  factory IntroductionsState.fromJson(Map<String, dynamic> json) =>
      _$IntroductionsStateFromJson(json);

  final Map<String, CoagContact> contacts;

  Map<String, dynamic> toJson() => _$IntroductionsStateToJson(this);

  @override
  List<Object?> get props => [contacts];
}
