// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:veilid/veilid.dart';
part 'contact_introduction.g.dart';

@JsonSerializable()
class ContactIntroduction extends Equatable {
  const ContactIntroduction({
    required this.otherName,
    required this.otherPublicKey,
    required this.publicKey,
    required this.dhtRecordKeyReceiving,
    required this.dhtRecordKeySharing,
    required this.dhtWriterSharing,
    this.message,
  });

  factory ContactIntroduction.fromJson(Map<String, dynamic> json) =>
      _$ContactIntroductionFromJson(json);

  /// Name of the contact this is not the introduction for
  final String otherName;

  /// Public key of the contact this is not the introduction for
  final PublicKey otherPublicKey;

  /// Public key of the recipient of this invite, the app user
  final PublicKey publicKey;

  /// Optional message for the introduction
  final String? message;

  /// Record key where the contact this is not the introduction for is sharing
  final Typed<FixedEncodedString43> dhtRecordKeyReceiving;

  /// Record key where the contact this is the introduction for can share
  final Typed<FixedEncodedString43> dhtRecordKeySharing;

  /// Writer for the key where the contact this is the introduction for can share
  final KeyPair dhtWriterSharing;

  Map<String, dynamic> toJson() => _$ContactIntroductionToJson(this);

  @override
  List<Object?> get props => [
        otherName,
        otherPublicKey,
        publicKey,
        message,
        dhtRecordKeyReceiving,
        dhtRecordKeySharing,
        dhtWriterSharing,
      ];
}
