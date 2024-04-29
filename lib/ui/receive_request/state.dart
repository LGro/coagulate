// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

part of 'cubit.dart';

enum ReceiveRequestStatus { qrcode, processing, receivedShare, receivedRequest }

extension ReceiveRequestStatusX on ReceiveRequestStatus {
  bool get isQrcode => this == ReceiveRequestStatus.qrcode;
  bool get isProcessing => this == ReceiveRequestStatus.processing;
  bool get isReceivedShare => this == ReceiveRequestStatus.receivedShare;
  bool get isReceivedRequest => this == ReceiveRequestStatus.receivedRequest;
}

@JsonSerializable()
final class ReceiveRequestState extends Equatable {
  const ReceiveRequestState(this.status,
      {this.profile,
      this.requestSettings,
      this.contactProporsalsForLinking = const []});

  factory ReceiveRequestState.fromJson(Map<String, dynamic> json) =>
      _$ReceiveRequestStateFromJson(json);

  final ReceiveRequestStatus status;
  final CoagContact? profile;
  final ContactDHTSettings? requestSettings;
  final List<CoagContact> contactProporsalsForLinking;

  Map<String, dynamic> toJson() => _$ReceiveRequestStateToJson(this);

  @override
  List<Object?> get props =>
      [status, profile, requestSettings, contactProporsalsForLinking];
}
