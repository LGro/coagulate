// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../data/models/coag_contact.dart';
import '../../data/repositories/contacts.dart';

part 'cubit.g.dart';
part 'state.dart';

class ContactDetailsCubit extends Cubit<ContactDetailsState> {
  ContactDetailsCubit(this.contactsRepository, String coagContactId)
      : super(ContactDetailsState(ContactDetailsStatus.success,
            contact: contactsRepository.getContact(coagContactId),
            knownContacts: Map.fromEntries(contactsRepository
                .getContacts()
                .entries
                .where((c) => (contactsRepository
                            .getContact(coagContactId)
                            ?.knownPersonalContactIds ??
                        [])
                    .contains(c.key))
                .map((c) => MapEntry(c.key, c.value.name))),
            circles: contactsRepository.getCirclesForContact(coagContactId))) {
    _circlesSubscription = contactsRepository.getCirclesStream().listen((c) {
      if (!isClosed) {
        emit(state.copyWith(
            circles: contactsRepository.getCirclesForContact(coagContactId)));
      }
    });
    _contactsSubscription =
        contactsRepository.getContactStream().listen((updatedContactId) {
      if (updatedContactId == coagContactId && !isClosed) {
        final updatedContact = contactsRepository.getContact(updatedContactId);
        if (updatedContact == null) {
          // TODO: Add contact not found status to trigger redirect to contacts list
          emit(const ContactDetailsState(ContactDetailsStatus.initial));
        } else {
          emit(state.copyWith(
              status: ContactDetailsStatus.success,
              contact: updatedContact,
              knownContacts: Map.fromEntries(contactsRepository
                  .getContacts()
                  .entries
                  .where((c) => (contactsRepository
                              .getContact(coagContactId)
                              ?.knownPersonalContactIds ??
                          [])
                      .contains(c.value.theirPersonalUniqueId))
                  .map((c) => MapEntry(c.key, c.value.name))),
              circles: contactsRepository.getCirclesForContact(coagContactId)));
        }
      }
    });

    // Attempt to share straight await, when a contact details page is visited
    if (state.contact != null) {
      unawaited(contactsRepository
          .updateContactSharedProfile(state.contact!.coagContactId));
    }
  }

  final ContactsRepository contactsRepository;
  late final StreamSubscription<String> _contactsSubscription;
  late final StreamSubscription<void> _circlesSubscription;

  Future<void> updateComment(String comment) async =>
      contactsRepository.saveContact(state.contact!.copyWith(comment: comment));

  Future<void> updateName(String name) async =>
      contactsRepository.saveContact(state.contact!.copyWith(name: name));

  Future<bool> delete(String coagContactId) async =>
      contactsRepository.removeContact(coagContactId);

  Future<void> unlinkFromSystemContact() async =>
      contactsRepository.unlinkSystemContact(state.contact!.coagContactId);

  // TODO: This takes looong, can we speed it up?
  Future<(bool, bool)> refresh() async {
    if (state.contact == null) {
      return (false, false);
    }
    final results = await Future.wait([
      contactsRepository.updateContactFromDHT(state.contact!),
      contactsRepository
          .updateContactSharedProfile(state.contact!.coagContactId)
          .then((_) => contactsRepository
              .tryShareWithContactDHT(state.contact!.coagContactId)),
      contactsRepository
          .updateBatchInviteForContact(state.contact!.coagContactId)
          .then((_) => true)
    ]);
    return (results[0], results[1]);
  }

  bool wasNotIntroduced(CoagContact contact) => contactsRepository
      .getContacts()
      .values
      .where((c) => c.introductionsByThem
          .map((i) => i.dhtRecordKeyReceiving)
          .contains(contact.dhtSettings.recordKeyThemSharing))
      .isEmpty;

  @override
  Future<void> close() {
    _contactsSubscription.cancel();
    _circlesSubscription.cancel();
    return super.close();
  }
}
