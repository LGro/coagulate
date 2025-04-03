// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

part of 'cubit.dart';

enum ReceiveRequestStatus {
  handleBatchInvite,
  handleDirectSharing,
  handleProfileLink,
  handleSharingOffer,
  qrcode,
  processing,
  success,
  batchInviteSuccess,
  malformedUrl,
}

extension ReceiveRequestStatusX on ReceiveRequestStatus {
  bool get isQrcode => this == ReceiveRequestStatus.qrcode;
  bool get isProcessing => this == ReceiveRequestStatus.processing;
  bool get isSuccess => this == ReceiveRequestStatus.success;
  bool get isBatchInviteSuccess =>
      this == ReceiveRequestStatus.batchInviteSuccess;
  bool get isHandleDirectSharing =>
      this == ReceiveRequestStatus.handleDirectSharing;
  bool get isHandleProfileLink =>
      this == ReceiveRequestStatus.handleProfileLink;
  bool get isHandleSharingOffer =>
      this == ReceiveRequestStatus.handleSharingOffer;
  bool get isHandleBatchInvite =>
      this == ReceiveRequestStatus.handleBatchInvite;
  bool get isMalformedUrl => this == ReceiveRequestStatus.malformedUrl;
}

@JsonSerializable()
final class ReceiveRequestState extends Equatable {
  const ReceiveRequestState(
    this.status, {
    this.profile,
    this.fragment,
  });

  factory ReceiveRequestState.fromJson(Map<String, dynamic> json) =>
      _$ReceiveRequestStateFromJson(json);

  final ReceiveRequestStatus status;
  final CoagContact? profile;
  final String? fragment;

  Map<String, dynamic> toJson() => _$ReceiveRequestStateToJson(this);

  ReceiveRequestState copyWith({
    ReceiveRequestStatus? status,
    CoagContact? profile,
    String? fragment,
  }) =>
      ReceiveRequestState(
        status ?? this.status,
        profile: profile ?? this.profile,
        fragment: fragment ?? this.fragment,
      );

  @override
  List<Object?> get props => [status, profile, fragment];
}
