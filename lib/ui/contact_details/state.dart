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
  const ContactDetailsState(this.status,
      {this.contact, this.circleNames = const []});

  factory ContactDetailsState.fromJson(Map<String, dynamic> json) =>
      _$ContactDetailsStateFromJson(json);

  final CoagContact? contact;
  final ContactDetailsStatus status;
  final List<String> circleNames;

  Map<String, dynamic> toJson() => _$ContactDetailsStateToJson(this);

  ContactDetailsState copyWith({
    ContactDetailsStatus? status,
    CoagContact? contact,
    List<String>? circleNames,
  }) =>
      ContactDetailsState(
        status ?? this.status,
        contact: contact ?? this.contact,
        circleNames: circleNames ?? this.circleNames,
      );

  @override
  List<Object?> get props => [contact, status, circleNames];
}
