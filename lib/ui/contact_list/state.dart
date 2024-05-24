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
      {this.contacts = const [], this.circleMemberships = const {}});

  factory ContactListState.fromJson(Map<String, dynamic> json) =>
      _$ContactListStateFromJson(json);

  final Map<String, List<String>> circleMemberships;
  final Iterable<CoagContact> contacts;
  final ContactListStatus status;

  ContactListState copyWith(
          {ContactListStatus? status,
          Map<String, List<String>>? circleMemberships,
          Iterable<CoagContact>? contacts}) =>
      ContactListState(
        status ?? this.status,
        circleMemberships: circleMemberships ?? this.circleMemberships,
        contacts: contacts ?? this.contacts,
      );

  Map<String, dynamic> toJson() => _$ContactListStateToJson(this);

  @override
  List<Object?> get props => [contacts, status, circleMemberships];
}
