// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../data/repositories/contacts.dart';

part 'cubit.g.dart';
part 'state.dart';

class CirclesCubit extends Cubit<CirclesState> {
  CirclesCubit(this.contactsRepository, this.coagContactId)
      : super(CirclesState(
            contactsRepository.circlesWithMembership(coagContactId))) {
    _circlesSubscription = contactsRepository.getCirclesStream().listen((c) {
      if (!isClosed) {
        emit(CirclesState(
            contactsRepository.circlesWithMembership(coagContactId)));
      }
    });
    if (!isClosed) {
      emit(CirclesState(
          contactsRepository.circlesWithMembership(coagContactId)));
    }
  }

  final ContactsRepository contactsRepository;
  final String coagContactId;
  late final StreamSubscription<void> _circlesSubscription;

  Future<void> update(List<(String, String, bool)> circles) async {
    // Check if there is a new circle, add it
    final storedCircles = contactsRepository.getCircles();
    for (final (id, label, _) in circles) {
      if (!storedCircles.containsKey(id)) {
        storedCircles[id] = label;
        await contactsRepository.addCircle(id, label);
      }
    }

    await contactsRepository.updateCirclesForContact(
        coagContactId, circles.where((c) => c.$3).map((c) => c.$1).asList());

    if (!isClosed) {
      emit(CirclesState(
          contactsRepository.circlesWithMembership(coagContactId)));
    }
  }

  @override
  Future<void> close() {
    _circlesSubscription.cancel();
    return super.close();
  }
}
