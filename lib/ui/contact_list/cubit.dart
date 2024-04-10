// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:collection/collection.dart';

import '../../data/models/coag_contact.dart';
import '../../data/repositories/contacts.dart';

part 'cubit.g.dart';
part 'state.dart';

// TODO: Figure out sorting of the contacts
class ContactListCubit extends HydratedCubit<ContactListState> {
  ContactListCubit(this.contactsRepository)
      : super(const ContactListState(ContactListStatus.initial)) {
    contactsRepository.getUpdateStatus().listen((event) {
      // TODO: Is there something smarter than always replacing the full state?
      if (!isClosed) {
        filter('');
      }
    });

    if (!isClosed) {
      filter('');
    }
  }

  final ContactsRepository contactsRepository;

  // TODO: Refine filtering by only searching through all values (not like now, also the field names)
  void filter(String filter) => emit(ContactListState(ContactListStatus.success,
      contacts: contactsRepository.coagContacts.values
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
            compareNatural(a.details!.displayName, b.details!.displayName))));

  @override
  ContactListState fromJson(Map<String, dynamic> json) =>
      ContactListState.fromJson(json);

  @override
  Map<String, dynamic> toJson(ContactListState state) => state.toJson();
}
