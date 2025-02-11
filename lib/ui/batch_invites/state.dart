// Copyright 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

part of 'cubit.dart';

@JsonSerializable()
final class BatchInvitesState extends Equatable {
  const BatchInvitesState({this.name = ''});

  factory BatchInvitesState.fromJson(Map<String, dynamic> json) =>
      _$BatchInvitesStateFromJson(json);

  final String name;

  Map<String, dynamic> toJson() => _$BatchInvitesStateToJson(this);

  BatchInvitesState copyWith({
    String? name,
  }) =>
      BatchInvitesState(
        name: name ?? this.name,
      );

  @override
  List<Object?> get props => [name];
}
