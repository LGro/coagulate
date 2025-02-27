// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/coag_contact.dart';
import '../../data/repositories/contacts.dart';

part 'cubit.g.dart';
part 'state.dart';

class CirclesListCubit extends Cubit<CirclesListState> {
  CirclesListCubit(this.contactsRepository)
      : super(const CirclesListState(CirclesListStatus.initial)) {
    _circlesSuscription = contactsRepository.getCirclesStream().listen((_) {
      if (!isClosed) {
        emit(state.copyWith(
            circleMemberships: contactsRepository.getCircleMemberships(),
            circles: contactsRepository.getCircles()));
      }
    });

    emit(CirclesListState(CirclesListStatus.success,
        circles: contactsRepository.getCircles(),
        circleMemberships: contactsRepository.getCircleMemberships()));
  }

  final ContactsRepository contactsRepository;
  late final StreamSubscription<void> _circlesSuscription;

  Future<String> addCircle(String circleName) async {
    final circleId = Uuid().v4();
    await contactsRepository.addCircle(circleId, circleName);
    return circleId;
  }

  @override
  Future<void> close() {
    _circlesSuscription.cancel();
    return super.close();
  }
}
