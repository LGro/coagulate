// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

part of 'cubit.dart';

@JsonSerializable()
class Batch extends Equatable {
  const Batch(
      {required this.label,
      required this.expiration,
      required this.dhtRecordKey,
      required this.writer,
      required this.subkeyWriters,
      required this.psk,
      this.numPopulatedSubkeys});

  factory Batch.fromJson(Map<String, dynamic> json) => _$BatchFromJson(json);

  final String label;
  final DateTime expiration;

  final Typed<FixedEncodedString43> dhtRecordKey;
  final KeyPair writer;
  final List<KeyPair> subkeyWriters;
  final FixedEncodedString43 psk;

  final int? numPopulatedSubkeys;

  Map<String, dynamic> toJson() => _$BatchToJson(this);

  Batch copyWith({int? numPopulatedSubkeys}) => Batch(
      label: this.label,
      expiration: this.expiration,
      dhtRecordKey: this.dhtRecordKey,
      writer: this.writer,
      subkeyWriters: [...this.subkeyWriters],
      psk: this.psk,
      numPopulatedSubkeys: numPopulatedSubkeys ?? this.numPopulatedSubkeys);

  @override
  List<Object?> get props => [
        label,
        expiration,
        dhtRecordKey,
        writer,
        subkeyWriters,
        psk,
        numPopulatedSubkeys
      ];
}

@JsonSerializable()
final class BatchInvitesState extends Equatable {
  const BatchInvitesState({this.batches = const {}});

  factory BatchInvitesState.fromJson(Map<String, dynamic> json) =>
      _$BatchInvitesStateFromJson(json);

  final Map<String, Batch> batches;

  Map<String, dynamic> toJson() => _$BatchInvitesStateToJson(this);

  BatchInvitesState copyWith({
    Map<String, Batch>? batches,
  }) =>
      BatchInvitesState(
        batches: batches ?? this.batches,
      );

  @override
  List<Object?> get props => [batches];
}
