// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

part of 'cubit.dart';

enum LinkToSystemContactStatus { initial, success, denied }

extension LinkToSystemContactStatusX on LinkToSystemContactStatus {
  bool get isInitial => this == LinkToSystemContactStatus.initial;
  bool get isSuccess => this == LinkToSystemContactStatus.success;
  bool get isDenied => this == LinkToSystemContactStatus.denied;
}

@JsonSerializable()
final class LinkToSystemContactState extends Equatable {
  const LinkToSystemContactState({
    this.status = LinkToSystemContactStatus.initial,
    this.contact,
    this.contacts = const [],
    this.accounts = const {},
    this.permissionGranted = false,
    this.selectedAccount,
  });

  factory LinkToSystemContactState.fromJson(Map<String, dynamic> json) =>
      _$LinkToSystemContactStateFromJson(json);

  final LinkToSystemContactStatus status;
  final bool permissionGranted;
  final CoagContact? contact;
  final List<Contact> contacts;
  final Set<Account> accounts;
  final Account? selectedAccount;

  Map<String, dynamic> toJson() => _$LinkToSystemContactStateToJson(this);

  LinkToSystemContactState copyWith({
    LinkToSystemContactStatus? status,
    bool? permissionGranted,
    CoagContact? contact,
    List<Contact>? contacts,
    Set<Account>? accounts,
    Account? selectedAccount,
  }) =>
      LinkToSystemContactState(
        status: status ?? this.status,
        permissionGranted: permissionGranted ?? this.permissionGranted,
        contact: contact ?? this.contact?.copyWith(),
        contacts: contacts ?? [...this.contacts],
        accounts: accounts ?? {...this.accounts},
        selectedAccount: selectedAccount ?? selectedAccount,
      );

  @override
  List<Object?> get props =>
      [status, permissionGranted, accounts, selectedAccount, contact, contacts];
}
