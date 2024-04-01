// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

part of 'cubit.dart';

enum ReceiveRequestStatus { qrcode, processing, received }

extension ReceiveRequestStatusX on ReceiveRequestStatus {
  bool get isQrcode => this == ReceiveRequestStatus.qrcode;
  bool get isProcessing => this == ReceiveRequestStatus.processing;
  bool get isreceived => this == ReceiveRequestStatus.received;
}

@JsonSerializable()
final class ReceiveRequestState extends Equatable {
  const ReceiveRequestState(this.status, {this.profile});

  factory ReceiveRequestState.fromJson(Map<String, dynamic> json) =>
      _$ReceiveRequestStateFromJson(json);

  final ReceiveRequestStatus status;
  final CoagContact? profile;

  Map<String, dynamic> toJson() => _$ReceiveRequestStateToJson(this);

  @override
  List<Object?> get props => [status, profile];
}
