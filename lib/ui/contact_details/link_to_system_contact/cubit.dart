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
  }

  final ContactsRepository contactsRepository;
  late final StreamSubscription<String> _contactsSubscription;

  /// Check if system contact access was granted
  Future<void> checkPermission() async =>
      Permission.contacts.status.then((status) => isClosed
          ? null
          : emit(state.copyWith(permissionGranted: status.isGranted)));

  /// Ask for system contact access (if not already granted)
  Future<void> requestPermission() async =>
      FlutterContacts.requestPermission().then((status) =>
          isClosed ? null : emit(state.copyWith(permissionGranted: status)));

  /// Load contacts from system address book
  Future<void> loadSystemContacts() async =>
      FlutterContacts.getContacts(withProperties: true, withThumbnail: true)
          .then((contacts) =>
              isClosed ? null : emit(state.copyWith(contacts: contacts)));

  /// Add new system contact from coagulate contact
  Future<void> createNewSystemContact(String displayName) async =>
      (state.contact?.details == null)
          ? null
          : FlutterContacts.insertContact(
                  state.contact!.details!.toSystemContact(displayName))
              .then((systemContact) => contactsRepository.saveContact(
                  state.contact!.copyWith(systemContactId: systemContact.id)));

  /// Link coagulate contact to existing system contact
  Future<void> linkExistingSystemContact(String systemContactId) async =>
      (state.contact == null)
          ? null
          : contactsRepository
              .saveContact(
                  state.contact!.copyWith(systemContactId: systemContactId))
              .then((_) => contactsRepository
                  .updateSystemContact(state.contact!.coagContactId));

  @override
  Future<void> close() {
    _contactsSubscription.cancel();
    return super.close();
  }
}
