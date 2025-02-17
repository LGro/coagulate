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

String extractAllValuesToString(dynamic value) {
  if (value is Map) {
    return value.values.map(extractAllValuesToString).join('|');
  } else if (value is List) {
    return value.map(extractAllValuesToString).join('|');
  } else {
    return value.toString();
  }
}

Iterable<CoagContact> filterAndSortContacts(
        Iterable<CoagContact> contacts, String filter) =>
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
      ..sort((a, b) => compareNatural(a.name, b.name));

class ContactListCubit extends Cubit<ContactListState> {
  ContactListCubit(this.contactsRepository)
      : super(const ContactListState(ContactListStatus.initial)) {
    // TODO: Also listen to circle updates?
    _contactsSuscription =
        contactsRepository.getContactStream().listen((idUpdatedContact) {
      if (!isClosed) {
        final contact = contactsRepository.getContact(idUpdatedContact);
        if (contact == null) {
          return;
        }
        emit(state.copyWith(
            circleMemberships: contactsRepository.getCircleMemberships(),
            circles: contactsRepository.getCircles(),
            contacts: filterAndSortContactsInSelectedCircles(
                state.filter, state.selectedCircle)));
      }
    });

    emit(ContactListState(ContactListStatus.success,
        contacts: filterAndSortContactsInSelectedCircles(
            state.filter, state.selectedCircle),
        circles: contactsRepository.getCircles(),
        circleMemberships: contactsRepository.getCircleMemberships()));
  }

  final ContactsRepository contactsRepository;
  late final StreamSubscription<String> _contactsSuscription;

  void filter(String filter) => emit(state.copyWith(
      // FIXME: Needing to pass "filter" to two places feels awkward
      filter: filter,
      contacts: filterAndSortContactsInSelectedCircles(
          filter, state.selectedCircle)));

  void selectCircle(String circleId) => emit(state.copyWith(
      selectedCircle: circleId,
      contacts:
          filterAndSortContactsInSelectedCircles(state.filter, circleId)));

  // TODO: Explicitly re-initializing the state instead of a copy with is erroneous
  //       do something about it like moving unselect circle to state
  void unselectCircle() => emit(ContactListState(state.status,
      filter: state.filter,
      circleMemberships: state.circleMemberships,
      circles: state.circles,
      contacts: filterAndSortContactsInSelectedCircles(state.filter, null)));

  Iterable<CoagContact> filterAndSortContactsInSelectedCircles(
          String filter, String? selectedCircle) =>
      filterAndSortContacts(
          contactsRepository.getContacts().values.where((contact) =>
              selectedCircle == null ||
              contactsRepository
                  .getContactIdsForCircle(selectedCircle)
                  .toSet()
                  .contains(contact.coagContactId)),
          filter);

  @override
  Future<void> close() {
    _contactsSuscription.cancel();
    return super.close();
  }
}
