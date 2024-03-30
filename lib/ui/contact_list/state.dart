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
  const ContactListState(this.coagContactId, this.status, {this.contact});

  factory ContactListState.fromJson(Map<String, dynamic> json) =>
      _$ContactListStateFromJson(json);

  final String coagContactId;
  final CoagContact? contact;
  final ContactListStatus status;

  Map<String, dynamic> toJson() => _$ContactListStateToJson(this);

  @override
  List<Object?> get props => [coagContactId, contact, status];
}
