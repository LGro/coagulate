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

// TODO: Refine filtering by only searching through all values (not like now, also the field names)
Iterable<CoagContact> _filterAndSort(Iterable<CoagContact> contacts,
        {String filter = ''}) =>
    contacts
        .where((c) =>
            (c.details != null &&
                c.details!
                    .toString()
                    .toLowerCase()
                    .contains(filter.toLowerCase())) ||
            (c.systemContact != null &&
                c.systemContact!
                    .toString()
                    .toLowerCase()
                    .contains(filter.toLowerCase())))
        .toList()
      ..sort((a, b) =>
          compareNatural(a.details!.displayName, b.details!.displayName));

// TODO: Figure out sorting of the contacts
class ContactListCubit extends HydratedCubit<ContactListState> {
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
      contacts: _filterAndSort(state.contacts, filter: filter)));

  @override
  ContactListState fromJson(Map<String, dynamic> json) =>
      ContactListState.fromJson(json);

  @override
  Map<String, dynamic> toJson(ContactListState state) => state.toJson();

  @override
  Future<void> close() {
    _contactsSuscription.cancel();
    return super.close();
  }
}
