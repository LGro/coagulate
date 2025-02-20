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
      required this.psk});

  factory Batch.fromJson(Map<String, dynamic> json) => _$BatchFromJson(json);

  final String label;
  final DateTime expiration;

  final Typed<FixedEncodedString43> dhtRecordKey;
  final KeyPair writer;
  final List<KeyPair> subkeyWriters;
  final FixedEncodedString43 psk;

  Map<String, dynamic> toJson() => _$BatchToJson(this);

  @override
  List<Object?> get props =>
      [label, expiration, dhtRecordKey, writer, subkeyWriters, psk];
}

@JsonSerializable()
final class BatchInvitesState extends Equatable {
  const BatchInvitesState({this.batches = const []});

  factory BatchInvitesState.fromJson(Map<String, dynamic> json) =>
      _$BatchInvitesStateFromJson(json);

  final List<Batch> batches;

  Map<String, dynamic> toJson() => _$BatchInvitesStateToJson(this);

  BatchInvitesState copyWith({
    List<Batch>? batches,
  }) =>
      BatchInvitesState(
        batches: batches ?? this.batches,
      );

  @override
  List<Object?> get props => [batches];
}
