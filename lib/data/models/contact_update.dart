// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'contact_update.g.dart';

@JsonSerializable()
class ContactUpdate extends Equatable {
  ContactUpdate({required this.message, required this.timestamp});

  factory ContactUpdate.fromJson(Map<String, dynamic> json) =>
      _$ContactUpdateFromJson(json);
  final String message;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => _$ContactUpdateToJson(this);

  @override
  List<Object?> get props => [message, timestamp];
}
