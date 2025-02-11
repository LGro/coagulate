// Copyright 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

part of 'cubit.dart';

@JsonSerializable()
final class CreateNewcontactState extends Equatable {
  const CreateNewcontactState({this.name = ''});

  factory CreateNewcontactState.fromJson(Map<String, dynamic> json) =>
      _$CreateNewcontactStateFromJson(json);

  final String name;

  Map<String, dynamic> toJson() => _$CreateNewcontactStateToJson(this);

  CreateNewcontactState copyWith({
    String? name,
  }) =>
      CreateNewcontactState(
        name: name ?? this.name,
      );

  @override
  List<Object?> get props => [name];
}
