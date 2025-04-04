// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../data/models/coag_contact.dart';
import '../../data/repositories/contacts.dart';

part 'cubit.g.dart';
part 'state.dart';

class ContactDetailsCubit extends Cubit<ContactDetailsState> {
  ContactDetailsCubit(this.contactsRepository, String coagContactId)
      : super(ContactDetailsState(ContactDetailsStatus.success,
            contact: contactsRepository.getContact(coagContactId),
            circleNames: contactsRepository
                .getCirclesForContact(coagContactId)
                .values
                .toList())) {
    _circlesSubscription = contactsRepository.getCirclesStream().listen((c) {
      if (!isClosed) {
        emit(state.copyWith(
            circleNames: contactsRepository
                .getCirclesForContact(coagContactId)
                .values
                .toList()));
      }
    });
    _contactsSubscription =
        contactsRepository.getContactStream().listen((updtedContactId) {
      if (updtedContactId == coagContactId && !isClosed) {
        final updatedContact = contactsRepository.getContact(updtedContactId);
        if (updatedContact == null) {
          // TODO: Add contact not found status?
          emit(const ContactDetailsState(ContactDetailsStatus.initial));
        } else {
          emit(state.copyWith(
              status: ContactDetailsStatus.success,
              contact: updatedContact,
              circleNames: contactsRepository
                  .getCirclesForContact(coagContactId)
                  .values
                  .toList()));
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

  Future<void> delete(String coagContactId) async =>
      contactsRepository.removeContact(coagContactId);

  Future<void> unlinkFromSystemContact() async =>
      (state.contact?.systemContactId == null)
          ? null
          : contactsRepository
              .saveContact(state.contact!.copyWith(
                  systemContactId: 'coag-non-existing-id-to-trigger-drop'))
              .then((_) => contactsRepository
                  .updateSystemContact(state.contact!.coagContactId));

  // TODO: This takes looong, can we speed it up?
  Future<bool> refresh() async {
    if (state.contact == null) {
      return false;
    }
    final receiveSuccess =
        await contactsRepository.updateContactFromDHT(state.contact!);
    await contactsRepository
        .updateContactSharedProfile(state.contact!.coagContactId);

    final shareSuccess = await contactsRepository
        .tryShareWithContactDHT(state.contact!.coagContactId);

    // TODO: Report more nuanced?
    return receiveSuccess && shareSuccess;
  }

  @override
  Future<void> close() {
    _contactsSubscription.cancel();
    _circlesSubscription.cancel();
    return super.close();
  }
}
