// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../data/models/coag_contact.dart';
import '../../../data/repositories/contacts.dart';

part 'cubit.g.dart';
part 'state.dart';

class LinkToSystemContactCubit extends Cubit<LinkToSystemContactState> {
  LinkToSystemContactCubit(this.contactsRepository, String coagContactId)
      : super(LinkToSystemContactState(
            contact: contactsRepository.getContact(coagContactId))) {
    _contactsSubscription =
        contactsRepository.getContactStream().listen((updatedContactId) {
      if (updatedContactId == coagContactId && !isClosed) {
        // TODO: Add contact not found status?
        emit(state.copyWith(
            contact: contactsRepository.getContact(updatedContactId)));
      }
    });
    unawaited(checkPermission());
  }

  final ContactsRepository contactsRepository;
  late final StreamSubscription<String> _contactsSubscription;

  /// Check if system contact access was granted
  Future<void> checkPermission() async =>
      Permission.contacts.status.then((status) async {
        if (!isClosed) {
          emit(state.copyWith(permissionGranted: status.isGranted));
          if (status.isGranted) {
            await loadSystemContacts();
          }
        }
      });

  /// Ask for system contact access (if not already granted)
  Future<void> requestPermission() async =>
      FlutterContacts.requestPermission().then((status) async {
        if (!isClosed) {
          emit(state.copyWith(permissionGranted: status));
          if (status) {
            await loadSystemContacts();
          }
        }
      });

  /// Load contacts from system address book
  Future<void> loadSystemContacts() async => FlutterContacts.getContacts(
              withProperties: true, withThumbnail: true, withAccounts: true)
          .then((contacts) {
        if (!isClosed) {
          final uniqueAccounts = Map.fromEntries(contacts
              .map((c) => c.accounts)
              .expand((a) => a)
              .map((a) => MapEntry(a.name, a))).values.toSet();
          emit(state.copyWith(
              contacts: contacts,
              accounts: uniqueAccounts,
              selectedAccount:
                  (uniqueAccounts.length > 1) ? uniqueAccounts.first : null));
        }
      });

  /// Add new system contact from coagulate contact
  Future<void> createNewSystemContact(String displayName,
          {Account? account}) async =>
      (state.contact == null)
          ? null
          : FlutterContacts.insertContact(Contact(
                  displayName: displayName,
                  name: Name(first: displayName),
                  accounts: (account == null) ? null : [account]))
              .then((systemContact) => contactsRepository.saveContact(
                  state.contact!.copyWith(systemContactId: systemContact.id)))
              .then((_) => contactsRepository
                  .updateSystemContact(state.contact!.coagContactId));

  /// Link coagulate contact to existing system contact
  Future<void> linkExistingSystemContact(String systemContactId) async =>
      (state.contact == null)
          ? null
          : contactsRepository
              .saveContact(
                  state.contact!.copyWith(systemContactId: systemContactId))
              .then((_) => contactsRepository
                  .updateSystemContact(state.contact!.coagContactId));

  /// Select an account to potentially add a new system contact to
  void setSelectedAccount(Account? account) =>
      isClosed ? null : emit(state.copyWith(selectedAccount: account));

  /// Close subscriptions
  @override
  Future<void> close() {
    _contactsSubscription.cancel();
    return super.close();
  }
}
