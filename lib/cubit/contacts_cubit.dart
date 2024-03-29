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

String getRandomString(int length) {
  const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final _rnd = Random.secure();
  return String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
}

Map<String, (double, double)> _randomAddressCoordinates(
    List<Address> addresses) {
  final rng = Random();
  return {
    for (var a in addresses)
      a.label.name: (rng.nextDouble() * 50, rng.nextDouble() * 12)
  };
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

  // void updateContact(String id, String sharingProfile) {
  //   if (!state.contacts.containsKey(id)) {
  //     // TODO: Handle id not found
  //     return;
  //   }
  //   // TODO: Is this really the way with all the copying?
  //   state.contacts[id] =
  //       state.contacts[id]!.copyWith(sharingProfile: sharingProfile);
  //   emit(CoagContactState(state.contacts, CoagContactStatus.success));
  // }

  Future<void> shareWithPeer(
      String peerContactId, Contact profileContact) async {
    // if (!state.contacts.containsKey(peerContactId)) {
    //   // TODO: Log because this shouldn't happen
    //   return;
    // }

    // final contact = state.contacts[peerContactId]!;
    // var myRecord = contact.myRecord;
    // if (myRecord == null) {
    //   String key;
    //   String writer;
    //   (key, writer) = await createDHTRecord();
    //   myRecord = MyDHTRecord(key: key, writer: writer);
    // }

    // if (myRecord.psk == null) {
    //   myRecord = MyDHTRecord(
    //       key: myRecord.key, writer: myRecord.writer, psk: getRandomString(32));
    // }

    // // TODO: Somehow only the first emit goes through
    // // state.contacts[peerContactId] =
    // //     contact.copyWith(dhtUpdateStatus: DhtUpdateStatus.progress);
    // // emit(CoagContactState(state.contacts, CoagContactStatus.success));

    // print('Attempting to update DHT Record');
    // final profileJson = generateProfileJsonForSharing(
    //     profileContact, myRecord, contact.peerRecord, null);
    // await updatePasswordEncryptedDHTRecord(
    //     recordKey: myRecord.key,
    //     recordWriter: myRecord.writer,
    //     secret: myRecord.psk!,
    //     content: profileJson);
    // print('Updated DHT Record');

    // // TODO: Set sharing profile when feature available
    // // TODO: Also handle failed coagulation attempts
    // state.contacts[peerContactId] = contact.copyWith(
    //     myRecord: myRecord,
    //     sharingProfile: 'default',
    //     dhtUpdateStatus: DhtUpdateStatus.success);

    // emit(CoagContactState(state.contacts, CoagContactStatus.success));
  }

  Future<void> unshareWithPeer(String peerContactId) async {
    // if (!state.contacts.containsKey(peerContactId)) {
    //   // TODO: Log because this shouldn't happen
    //   return;
    // }

    // var contact = state.contacts[peerContactId]!;
    // if (contact.myRecord == null) {
    //   // TODO: Log because this shouldn't happen
    //   return;
    // }

    // // TODO: Somehow only the first emit goes through; link the follow ups via repository or ui
    // // state.contacts[peerContactId] =
    // //     contact.copyWith(dhtUpdateStatus: DhtUpdateStatus.progress);
    // // emit(CoagContactState(state.contacts, CoagContactStatus.success));

    // print('Attempting to update DHT Record');
    // await updatePasswordEncryptedDHTRecord(
    //     recordKey: contact.myRecord!.key,
    //     recordWriter: contact.myRecord!.key,
    //     secret: contact.myRecord!.psk!,
    //     content: '');
    // print('Updated DHT Record');

    // // TODO: Handle failure
    // state.contacts[peerContactId] = contact.copyWith(
    //     sharingProfile: 'dont', dhtUpdateStatus: DhtUpdateStatus.success);
    // emit(CoagContactState(state.contacts, CoagContactStatus.success));
  }

  Future<void> fetchUpdateFromDHT(PeerDHTRecord contactRecord) async {
    // final contactProfile = await readPasswordEncryptedDHTRecord(
    //     recordKey: contactRecord.key, secret: contactRecord.psk!);
    // // TODO: Unmarshall and store the profiles somewhere
    // // TODO: This needs to be able to handle known and unknown contacts
    // final contact = generateContactFromProfileJson(contactProfile);

    // print('Fetched: ${contactProfile}');
    // print('Fetched: ${contact}');
  }

  Future<void> fetchUpdatesFromDHT() async {
    // for (var contact in state.contacts.values) {
    //   if (contact.peerRecord != null) {
    //     await fetchUpdateFromDHT(contact.peerRecord!);
    //   }
    // }
  }

  @override
  CoagContactState fromJson(Map<String, dynamic> json) =>
      CoagContactState.fromJson(json);

  @override
  Map<String, dynamic> toJson(CoagContactState state) => state.toJson();

  Future<void> handleCoagulationURI(String uri) async {
    // print('Parsing: $uri');
    // String? payload;
    // if (uri.startsWith('https://coagulate.social')) {
    //   final fragment = Uri.parse(uri).fragment;
    //   if (fragment.isEmpty) {
    //     // TODO: Log / feedback?
    //     return;
    //   }
    //   payload = fragment;
    // } else if (uri.startsWith('coag://')) {
    //   payload = uri.substring(7);
    // } else if (uri.startsWith('coagulate://')) {
    //   payload = uri.substring(12);
    // }
    // if (payload == null) {
    //   // TODO: Log / feedback?
    //   return;
    // }
    // final components = payload.split(':');
    // if (components.length != 3) {
    //   // TODO: Log / feedback?
    //   return;
    // }

    // try {
    //   await fetchUpdateFromDHT(PeerDHTRecord(
    //       key: '${components[0]}:${components[1]}', psk: components[2]));
    // } on Exception catch (e) {
    //   // TODO: Log properly / feedback?
    //   print('Error fetching DHT UPDATE: ${e}');
    // }
  }
}
