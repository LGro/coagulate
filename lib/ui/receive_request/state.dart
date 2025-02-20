// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

part of 'cubit.dart';

enum ReceiveRequestStatus { qrcode, processing, success, receivedUriFragment }

extension ReceiveRequestStatusX on ReceiveRequestStatus {
  bool get isQrcode => this == ReceiveRequestStatus.qrcode;
  bool get isProcessing => this == ReceiveRequestStatus.processing;
  bool get isSuccess => this == ReceiveRequestStatus.success;
  bool get isReceivedUriFragment =>
      this == ReceiveRequestStatus.receivedUriFragment;
}

@JsonSerializable()
final class ReceiveRequestState extends Equatable {
  const ReceiveRequestState(
    this.status, {
    this.profile,
    this.requestSettings,
    this.fragment,
    this.contactProposalsForLinking = const [],
  });

  factory ReceiveRequestState.fromJson(Map<String, dynamic> json) =>
      _$ReceiveRequestStateFromJson(json);

  final ReceiveRequestStatus status;
  final CoagContact? profile;
  final String? fragment;
  // TODO: Consider renaming these if they really apply to both when a contact is requesting as well as sharing
  final ContactDHTSettings? requestSettings;
  final List<CoagContact> contactProposalsForLinking;

  Map<String, dynamic> toJson() => _$ReceiveRequestStateToJson(this);

  ReceiveRequestState copyWith({
    ReceiveRequestStatus? status,
    CoagContact? profile,
    String? fragment,
    ContactDHTSettings? requestSettings,
    List<CoagContact>? contactProposalsForLinking,
  }) =>
      ReceiveRequestState(
        status ?? this.status,
        profile: profile ?? this.profile,
        fragment: fragment ?? this.fragment,
        requestSettings: requestSettings ?? this.requestSettings,
        contactProposalsForLinking:
            contactProposalsForLinking ?? this.contactProposalsForLinking,
      );

  @override
  List<Object?> get props =>
      [status, profile, requestSettings, fragment, contactProposalsForLinking];
}
