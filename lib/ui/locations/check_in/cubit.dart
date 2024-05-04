// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../data/models/contact_location.dart';
import '../../../data/repositories/contacts.dart';

part 'cubit.g.dart';
part 'state.dart';

class CheckInCubit extends Cubit<CheckInState> {
  CheckInCubit(this.contactsRepository) : super(const CheckInState());

  final ContactsRepository contactsRepository;

  Future<void> checkIn(ContactTemporaryLocation location) async {
    emit(const CheckInState(checkingIn: true));
    final profileContact = await contactsRepository.getProfileContact();
    if (profileContact == null) {
      return;
    }
    await contactsRepository.updateContact(profileContact.copyWith(
        temporaryLocations: [...profileContact.temporaryLocations, location]));
    emit(const CheckInState(checkingIn: false));
  }
}
