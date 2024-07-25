// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

part of 'cubit.dart';

enum ContactListStatus { initial, success, denied }

extension ContactListStatusX on ContactListStatus {
  bool get isInitial => this == ContactListStatus.initial;
  bool get isSuccess => this == ContactListStatus.success;
  bool get isDenied => this == ContactListStatus.denied;
}

@JsonSerializable()
final class ContactListState extends Equatable {
  const ContactListState(this.status,
      {this.contacts = const [],
      this.circleMemberships = const {},
      this.filter = '',
      this.selectedCircle,
      this.circles = const {}});

  factory ContactListState.fromJson(Map<String, dynamic> json) =>
      _$ContactListStateFromJson(json);

  final Map<String, List<String>> circleMemberships;
  final Iterable<CoagContact> contacts;
  final String? selectedCircle;
  final Map<String, String> circles;
  final String filter;
  final ContactListStatus status;

  ContactListState copyWith(
          {ContactListStatus? status,
          Map<String, List<String>>? circleMemberships,
          String? selectedCircle,
          Map<String, String>? circles,
          String? filter,
          Iterable<CoagContact>? contacts}) =>
      ContactListState(
        status ?? this.status,
        circleMemberships: circleMemberships ?? this.circleMemberships,
        filter: filter ?? this.filter,
        circles: circles ?? this.circles,
        contacts: contacts ?? this.contacts,
        selectedCircle: selectedCircle ?? this.selectedCircle,
      );

  Map<String, dynamic> toJson() => _$ContactListStateToJson(this);

  @override
  List<Object?> get props =>
      [contacts, status, circleMemberships, circles, filter, selectedCircle];
}
