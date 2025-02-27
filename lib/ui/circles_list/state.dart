// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

part of 'cubit.dart';

enum CirclesListStatus { initial, success, denied }

extension CirclesListStatusX on CirclesListStatus {
  bool get isInitial => this == CirclesListStatus.initial;
  bool get isSuccess => this == CirclesListStatus.success;
  bool get isDenied => this == CirclesListStatus.denied;
}

@JsonSerializable()
final class CirclesListState extends Equatable {
  const CirclesListState(this.status,
      {this.circleMemberships = const {},
      this.filter = '',
      this.circles = const {}});

  factory CirclesListState.fromJson(Map<String, dynamic> json) =>
      _$CirclesListStateFromJson(json);

  final Map<String, List<String>> circleMemberships;
  final Map<String, String> circles;
  final String filter;
  final CirclesListStatus status;

  CirclesListState copyWith(
          {CirclesListStatus? status,
          Map<String, List<String>>? circleMemberships,
          String? selectedCircle,
          Map<String, String>? circles,
          String? filter,
          Iterable<CoagContact>? contacts}) =>
      CirclesListState(
        status ?? this.status,
        circleMemberships: circleMemberships ?? this.circleMemberships,
        filter: filter ?? this.filter,
        circles: circles ?? this.circles,
      );

  Map<String, dynamic> toJson() => _$CirclesListStateToJson(this);

  @override
  List<Object?> get props => [
        status,
        circleMemberships,
        circles,
        filter,
      ];
}
