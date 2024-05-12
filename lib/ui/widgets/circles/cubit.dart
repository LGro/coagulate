// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../data/repositories/contacts.dart';

part 'cubit.g.dart';
part 'state.dart';

// TODO: Do we need this layer inbetween the repo and the ui?
class CirclesCubit extends Cubit<CirclesState> {
  CirclesCubit(this.contactsRepository, this.coagContactId)
      : super(CirclesState(contactsRepository.circles
            .map((id, label) => MapEntry(id, (
                  id,
                  label,
                  contactsRepository.circleMemberships[id]?.contains(id) ??
                      false
                )))
            .values
            .toList()));

  final ContactsRepository contactsRepository;
  final String coagContactId;

  void update(List<(String, String, bool)> circles) {
    // Check if there is a new circle, add it
    for (final (id, label, _) in circles) {
      if (!contactsRepository.circles.containsKey(id)) {
        contactsRepository.circles[id] = label;
      }
    }

    // Update circle membership
    final memberships =
        Map<String, List<String>>.from(contactsRepository.circleMemberships);
    memberships[coagContactId] =
        circles.where((c) => c.$3).map((c) => c.$1).asList();
    contactsRepository.circleMemberships = memberships;
  }
}
