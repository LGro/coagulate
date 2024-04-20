// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../data/models/coag_contact.dart';
import '../../data/repositories/contacts.dart';

part 'cubit.g.dart';
part 'state.dart';

String extractAllValuesToString(dynamic value) {
  if (value is Map) {
    return value.values.map(extractAllValuesToString).join('|');
  } else if (value is List) {
    return value.map(extractAllValuesToString).join('|');
  } else {
    return value.toString();
  }
}

Iterable<CoagContact> _filterAndSort(Iterable<CoagContact> contacts,
        {String filter = ''}) =>
    ((filter.isEmpty)
            ? contacts
            : contacts.where((c) =>
                (c.details != null &&
                    extractAllValuesToString(c.details!.toJson())
                        .toLowerCase()
                        .contains(filter.toLowerCase())) ||
                (c.systemContact != null &&
                    extractAllValuesToString(c.systemContact!.toJson())
                        .toLowerCase()
                        .contains(filter.toLowerCase()))))
        .toList()
      ..sort((a, b) =>
          compareNatural(a.details!.displayName, b.details!.displayName));

// TODO: Figure out sorting of the contacts
class ContactListCubit extends Cubit<ContactListState> {
  ContactListCubit(this.contactsRepository)
      : super(const ContactListState(ContactListStatus.initial)) {
    _contactsSuscription =
        contactsRepository.getContactUpdates().listen((contact) {
      if (!isClosed) {
        emit(ContactListState(ContactListStatus.success,
            contacts: _filterAndSort([
              ...state.contacts
                  .where((c) => c.coagContactId != contact.coagContactId),
              contact
            ])));
      }
    });
    emit(ContactListState(ContactListStatus.success,
        contacts: _filterAndSort(contactsRepository.getContacts().values)));
  }

  final ContactsRepository contactsRepository;
  late final StreamSubscription<CoagContact> _contactsSuscription;

  void filter(String filter) => emit(ContactListState(ContactListStatus.success,
      contacts: _filterAndSort(contactsRepository.getContacts().values,
          filter: filter)));

  @override
  Future<void> close() {
    _contactsSuscription.cancel();
    return super.close();
  }
}
