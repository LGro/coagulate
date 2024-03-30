// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0
import 'dart:convert';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';

import '../data/models/coag_contact.dart';
import '../data/providers/dht.dart';
import '../data/repositories/contacts.dart';

part 'contacts_cubit.g.dart';
part 'contacts_state.dart';

String generateProfileJsonForSharing(Contact profile, MyDHTRecord myRecord,
    PeerDHTRecord? contactRecord, String? shareProfile) {
  // TODO: Add my pubkey here as pubkey
  final coagContact = CoagContactSchema(
      // TODO: Add shareProfile dependent filtering
      contact: Contact(
          name: profile.name,
          emails: profile.emails,
          phones: profile.phones,
          addresses: profile.addresses),
      addressCoordinates: {},
      dhtWriter: contactRecord?.writer,
      dhtKey: contactRecord?.writer,
      publicKey: null);
  return const JsonEncoder().convert(coagContact);
}

CoagContactSchema generateContactFromProfileJson(String profile) {
  // TODO: Error handling for the following two lines
  final mapping = jsonDecode(profile) as Map<String, dynamic>;
  return CoagContactSchema.fromJson(mapping);
}

class CoagContactCubit extends HydratedCubit<CoagContactState> {
  CoagContactCubit(this.contactsRepository)
      : super(const CoagContactState({}, CoagContactStatus.initial)) {
    // TODO: Subscribe to
    // contactsRepository.getUpdateStatus()
    emit(CoagContactState(
        contactsRepository.coagContacts, CoagContactStatus.success));
  }

  final ContactsRepository contactsRepository;

  @override
  CoagContactState fromJson(Map<String, dynamic> json) =>
      CoagContactState.fromJson(json);

  @override
  Map<String, dynamic> toJson(CoagContactState state) => state.toJson();
}
