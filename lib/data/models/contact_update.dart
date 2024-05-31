// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'coag_contact.dart';

part 'contact_update.g.dart';

@JsonSerializable()
class ContactUpdate extends Equatable {
  const ContactUpdate(
      {required this.coagContactId,
      required this.oldContact,
      required this.newContact,
      required this.timestamp});

  factory ContactUpdate.fromJson(Map<String, dynamic> json) =>
      _$ContactUpdateFromJson(json);

  final String? coagContactId;
  final ContactDetails oldContact;
  final ContactDetails newContact;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => _$ContactUpdateToJson(this);

  @override
  List<Object?> get props => [coagContactId, oldContact, newContact, timestamp];
}
