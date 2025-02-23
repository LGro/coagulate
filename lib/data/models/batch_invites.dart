// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:veilid/veilid.dart';
part 'batch_invites.g.dart';

@JsonSerializable()
class BatchInviteInfoSchema extends Equatable {
  const BatchInviteInfoSchema(this.label, this.expiration);

  factory BatchInviteInfoSchema.fromJson(Map<String, dynamic> json) =>
      _$BatchInviteInfoSchemaFromJson(json);

  final String label;
  final DateTime expiration;

  Map<String, dynamic> toJson() => _$BatchInviteInfoSchemaToJson(this);

  @override
  List<Object?> get props => [label, expiration];
}

@JsonSerializable()
class BatchSubkeySchema extends Equatable {
  const BatchSubkeySchema(this.name, this.publicKey, this.records);

  factory BatchSubkeySchema.fromJson(Map<String, dynamic> json) =>
      _$BatchSubkeySchemaFromJson(json);

  final String name;

  final FixedEncodedString43 publicKey;

  /// For public keys as map keys, DHT record keys as values
  final Map<String, Typed<FixedEncodedString43>> records;

  Map<String, dynamic> toJson() => _$BatchSubkeySchemaToJson(this);

  @override
  List<Object?> get props => [name, publicKey, records];
}

// TODO: Drop myName?
@JsonSerializable()
class BatchInvite extends Equatable {
  const BatchInvite(
      {required this.label,
      required this.expiration,
      required this.recordKey,
      required this.psk,
      required this.subkeyCount,
      required this.mySubkey,
      required this.subkeyWriter,
      required this.myName,
      required this.myKeyPair,
      this.myConnectionRecords = const {}});

  factory BatchInvite.fromJson(Map<String, dynamic> json) =>
      _$BatchInviteFromJson(json);

  final String label;
  final DateTime expiration;

  final Typed<FixedEncodedString43> recordKey;
  final FixedEncodedString43 psk;

  final int subkeyCount;
  final int mySubkey;
  final KeyPair subkeyWriter;

  final String myName;
  final TypedKeyPair myKeyPair;

  /// For contact public keys as map keys, DHT record keys as values
  final Map<String, Typed<FixedEncodedString43>> myConnectionRecords;

  Map<String, dynamic> toJson() => _$BatchInviteToJson(this);

  BatchInvite copyWith(
          {Map<String, Typed<FixedEncodedString43>>? myConnectionRecords}) =>
      BatchInvite(
          label: this.label,
          expiration: this.expiration,
          recordKey: this.recordKey,
          psk: this.psk,
          subkeyCount: this.subkeyCount,
          mySubkey: this.mySubkey,
          subkeyWriter: this.subkeyWriter,
          myName: this.myName,
          myKeyPair: this.myKeyPair,
          myConnectionRecords: myConnectionRecords ?? this.myConnectionRecords);

  @override
  List<Object?> get props => [
        label,
        expiration,
        recordKey,
        psk,
        subkeyCount,
        mySubkey,
        subkeyWriter,
        myKeyPair,
        myName,
        myConnectionRecords,
      ];
}
