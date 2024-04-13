// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

part of 'cubit.dart';

enum ContactDetailsStatus { initial, success, denied, coagulationChangePending }

extension ContactDetailsStatusX on ContactDetailsStatus {
  bool get isInitial => this == ContactDetailsStatus.initial;
  bool get isSuccess => this == ContactDetailsStatus.success;
  bool get isCoagulationChangePending =>
      this == ContactDetailsStatus.coagulationChangePending;
  bool get isDenied => this == ContactDetailsStatus.denied;
}

@JsonSerializable()
final class ContactDetailsState extends Equatable {
  const ContactDetailsState(this.coagContactId, this.status,
      {this.contact, this.sharedProfile});

  factory ContactDetailsState.fromJson(Map<String, dynamic> json) =>
      _$ContactDetailsStateFromJson(json);

  final String coagContactId;
  final CoagContact? contact;
  final ContactDetailsStatus status;
  final CoagContact? sharedProfile;

  Map<String, dynamic> toJson() => _$ContactDetailsStateToJson(this);

  @override
  List<Object?> get props => [coagContactId, contact, sharedProfile, status];
}
