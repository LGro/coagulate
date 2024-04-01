// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

part of 'cubit.dart';

enum RecieveRequestStatus { qrcode, processing, received }

extension RecieveRequestStatusX on RecieveRequestStatus {
  bool get isQrcode => this == RecieveRequestStatus.qrcode;
  bool get isProcessing => this == RecieveRequestStatus.processing;
  bool get isreceived => this == RecieveRequestStatus.received;
}

@JsonSerializable()
final class RecieveRequestState extends Equatable {
  const RecieveRequestState(this.status, {this.profile});

  factory RecieveRequestState.fromJson(Map<String, dynamic> json) =>
      _$RecieveRequestStateFromJson(json);

  final RecieveRequestStatus status;
  final CoagContact? profile;

  Map<String, dynamic> toJson() => _$RecieveRequestStateToJson(this);

  @override
  List<Object?> get props => [status, profile];
}
