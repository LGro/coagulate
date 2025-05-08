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
        emit(state.copyWith(
            circleMemberships: contactsRepository.getCircleMemberships(),
            circles: contactsRepository.getCircles(),
            contacts: contactsRepository.getContacts().values.toList()
              ..sortBy((c) => c.name.toLowerCase())));
      }
    });

    emit(ContactListState(ContactListStatus.success,
        contacts: contactsRepository.getContacts().values.toList()
          ..sortBy((c) => c.name.toLowerCase()),
        circles: contactsRepository.getCircles(),
        circleMemberships: contactsRepository.getCircleMemberships()));
  }

  final ContactsRepository contactsRepository;
  late final StreamSubscription<String> _contactsSubscription;

  Future<bool> refresh() async {
    final results = await Future.wait([
      contactsRepository.updateAndWatchReceivingDHT(),
      contactsRepository.updateSharingDHT(),
      contactsRepository.updateAllBatchInvites().then((_) => true)
    ]);
    return results.every((r) => r);
  }

  @override
  Future<void> close() {
    _contactsSubscription.cancel();
    return super.close();
  }
}
