// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

part of 'cubit.dart';

enum RecieveRequestStatus { pickMode, processing, nfc, qrcode, paste, recieved }

extension RecieveRequestStatusX on RecieveRequestStatus {
  bool get isPickMode => this == RecieveRequestStatus.pickMode;
  bool get isNfc => this == RecieveRequestStatus.nfc;
  bool get isQrcode => this == RecieveRequestStatus.qrcode;
  bool get isPaste => this == RecieveRequestStatus.paste;
  bool get isProcessing => this == RecieveRequestStatus.processing;
  bool get isRecieved => this == RecieveRequestStatus.recieved;
}

@JsonSerializable()
final class RecieveRequestState extends Equatable {
  const RecieveRequestState(this.status, {this.profile});

  factory RecieveRequestState.fromJson(Map<String, dynamic> json) =>
      _$RecieveRequestStateFromJson(json);

  final RecieveRequestStatus status;
  final String? profile;

  Map<String, dynamic> toJson() => _$RecieveRequestStateToJson(this);

  @override
  List<Object?> get props => [status, profile];
}
