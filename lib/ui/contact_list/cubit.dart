// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../data/models/coag_contact.dart';
import '../../data/repositories/contacts.dart';

part 'cubit.g.dart';
part 'state.dart';

class ContactListCubit extends Cubit<ContactListState> {
  ContactListCubit(this.contactsRepository)
      : super(const ContactListState(ContactListStatus.initial)) {
    // TODO: Also listen to circle updates?
    _contactsSubscription =
        contactsRepository.getContactStream().listen((idUpdatedContact) {
      if (!isClosed) {
        final contact = contactsRepository.getContact(idUpdatedContact);
        if (contact == null) {
          return;
        }
        emit(state.copyWith(
            circleMemberships: contactsRepository.getCircleMemberships(),
            circles: contactsRepository.getCircles(),
            contacts: contactsRepository.getContacts().values.toList()
              ..sortedBy((c) => c.name)));
      }
    });

    emit(ContactListState(ContactListStatus.success,
        contacts: contactsRepository.getContacts().values.toList()
          ..sortedBy((c) => c.name),
        circles: contactsRepository.getCircles(),
        circleMemberships: contactsRepository.getCircleMemberships()));
  }

  final ContactsRepository contactsRepository;
  late final StreamSubscription<String> _contactsSubscription;

  // TODO: This takes looong, can we speed it up?
  Future<bool> refresh() async {
    // TODO: Parallelize these two?
    final receiveSuccess =
        await contactsRepository.updateAndWatchReceivingDHT();
    final sharingSuccess = await contactsRepository.updateSharingDHT();
    return receiveSuccess && sharingSuccess;
  }

  @override
  Future<void> close() {
    _contactsSubscription.cancel();
    return super.close();
  }
}
