// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0
import 'dart:convert';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';

import '../veilid_support/veilid_support.dart';

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
  CoagContactCubit()
      : super(const CoagContactState({}, CoagContactStatus.initial));

  Future<void> refreshContactsFromSystem() async {
    if (!await FlutterContacts.requestPermission()) {
      emit(CoagContactState(state.contacts, CoagContactStatus.denied));
      return;
    }

    // TODO: Can this be done one the fly somehow instead of all at once
    //       or is it fast enough to not be a bottleneck?
    final updatedContacts = <String, CoagContact>{};
    // TODO: Consider loading them first without tumbnail and then with, to speed things up
    for (final contact in await FlutterContacts.getContacts(
        withThumbnail: true, withProperties: true)) {
      updatedContacts[contact.id] = state.contacts.containsKey(contact.id)
          ? state.contacts[contact.id]!.copyWith(contact: contact)
          : CoagContact(
              contact: contact,
              // TODO: replace
              addressCoordinates: _randomAddressCoordinates(contact.addresses));
    }
    // TODO: When changing a contact, switching back to the contact list and
    //       leaving it, it seems like it can happen that this still emits a
    //       state after the contacts have been refreshed but the view is
    //       already closed with causes an error.
    //       It also happens when a contact is updated in the address book in
    //       the background.
    //       https://stackoverflow.com/questions/55536461/flutter-unhandled-exception-bad-state-cannot-add-new-events-after-calling-clo
    //       However, it might also instead be the case that we need to trigger
    //       refreshs from somewhere more UI independent.
    emit(CoagContactState(updatedContacts, CoagContactStatus.success));
  }

  void updateContact(String id, String sharingProfile) {
    if (!state.contacts.containsKey(id)) {
      // TODO: Handle id not found
      return;
    }
    // TODO: Is this really the way with all the copying?
    state.contacts[id] =
        state.contacts[id]!.copyWith(sharingProfile: sharingProfile);
    emit(CoagContactState(state.contacts, CoagContactStatus.success));
  }

  Future<void> shareWithPeer(
      String peerContactId, Contact profileContact) async {
    if (!state.contacts.containsKey(peerContactId)) {
      // TODO: Log because this shouldn't happen
      return;
    }

    final contact = state.contacts[peerContactId]!;
    var myRecord = contact.myRecord;
    if (myRecord == null) {
      String key;
      String writer;
      (key, writer) = await createDHTRecord();
      myRecord = MyDHTRecord(key: key, writer: writer);
    }

    if (myRecord.psk == null) {
      myRecord = MyDHTRecord(
          key: myRecord.key, writer: myRecord.writer, psk: getRandomString(32));
    }

    // TODO: Somehow only the first emit goes through
    // state.contacts[peerContactId] =
    //     contact.copyWith(dhtUpdateStatus: DhtUpdateStatus.progress);
    // emit(CoagContactState(state.contacts, CoagContactStatus.success));

    print('Attempting to update DHT Record');
    final profileJson = generateProfileJsonForSharing(
        profileContact, myRecord, contact.peerRecord, null);
    await updateDHTRecord(myRecord, profileJson);
    print('Updated DHT Record');

    // TODO: Set sharing profile when feature available
    // TODO: Also handle failed coagulation attempts
    state.contacts[peerContactId] = contact.copyWith(
        myRecord: myRecord,
        sharingProfile: 'default',
        dhtUpdateStatus: DhtUpdateStatus.success);

    emit(CoagContactState(state.contacts, CoagContactStatus.success));
  }

  Future<void> unshareWithPeer(String peerContactId) async {
    if (!state.contacts.containsKey(peerContactId)) {
      // TODO: Log because this shouldn't happen
      return;
    }

    var contact = state.contacts[peerContactId]!;
    if (contact.myRecord == null) {
      // TODO: Log because this shouldn't happen
      return;
    }

    // TODO: Somehow only the first emit goes through
    // state.contacts[peerContactId] =
    //     contact.copyWith(dhtUpdateStatus: DhtUpdateStatus.progress);
    // emit(CoagContactState(state.contacts, CoagContactStatus.success));

    print('Attempting to update DHT Record');
    await updateDHTRecord(contact.myRecord!, '');
    print('Updated DHT Record');

    // TODO: Handle failure
    state.contacts[peerContactId] = contact.copyWith(
        sharingProfile: 'dont', dhtUpdateStatus: DhtUpdateStatus.success);
    emit(CoagContactState(state.contacts, CoagContactStatus.success));
  }

  Future<void> fetchUpdateFromDHT(PeerDHTRecord contactRecord) async {
    final contactProfile = await readDHTRecord(contactRecord);
    // TODO: Unmarshall and store the profiles somewhere
    // TODO: This needs to be able to handle known and unknown contacts
    final contact = generateContactFromProfileJson(contactProfile);

    print('Fetched: ${contactProfile}');
    print('Fetched: ${contact}');
  }

  Future<void> fetchUpdatesFromDHT() async {
    for (var contact in state.contacts.values) {
      if (contact.peerRecord != null) {
        await fetchUpdateFromDHT(contact.peerRecord!);
      }
    }
  }

  @override
  CoagContactState fromJson(Map<String, dynamic> json) =>
      CoagContactState.fromJson(json);

  @override
  Map<String, dynamic> toJson(CoagContactState state) => state.toJson();

  Future<void> handleCoagulationURI(String uri) async {
    print('Parsing: $uri');
    String? payload;
    if (uri.startsWith('https://coagulate.social')) {
      final fragment = Uri.parse(uri).fragment;
      if (fragment.isEmpty) {
        // TODO: Log / feedback?
        return;
      }
      payload = fragment;
    } else if (uri.startsWith('coag://')) {
      payload = uri.substring(7);
    } else if (uri.startsWith('coagulate://')) {
      payload = uri.substring(12);
    }
    if (payload == null) {
      // TODO: Log / feedback?
      return;
    }
    final components = payload.split(':');
    if (components.length != 3) {
      // TODO: Log / feedback?
      return;
    }

    try {
      await fetchUpdateFromDHT(PeerDHTRecord(
          key: '${components[0]}:${components[1]}', psk: components[2]));
    } on Exception catch (e) {
      // TODO: Log properly / feedback?
      print('Error fetching DHT UPDATE: ${e}');
    }
  }
}

// DHT Utils

Future<(String, String)> createDHTRecord() async {
  final pool = await DHTRecordPool.instance();
  final record = await pool.create(crypto: const DHTRecordCryptoPublic());
  await record.close();
  return (record.key.toString(), record.writer!.toString());
}

Future<String> readDHTRecord(PeerDHTRecord contactRecord) async {
  final _key = Typed<FixedEncodedString43>.fromString(contactRecord.key);
  final pool = await DHTRecordPool.instance();
  final record =
      await pool.openRead(_key, crypto: const DHTRecordCryptoPublic());
  final raw = await record.get();
  final cs = await pool.veilid.bestCryptoSystem();
  // TODO: Error handling
  final decryptedProfile =
      await cs.decryptAeadWithPassword(raw!, contactRecord.psk!);
  await record.close();

  return utf8.decode(decryptedProfile);
}

Future<void> updateDHTRecord(MyDHTRecord myRecordInfo, String profile) async {
  final _key = Typed<FixedEncodedString43>.fromString(myRecordInfo.key);
  final writer = KeyPair.fromString(myRecordInfo.writer);
  final pool = await DHTRecordPool.instance();
  final record =
      await pool.openWrite(_key, writer, crypto: const DHTRecordCryptoPublic());

  final cs = await pool.veilid.bestCryptoSystem();
  // TODO: Ensure via type that psk is available
  final encryptedProfile =
      await cs.encryptAeadWithPassword(utf8.encode(profile), myRecordInfo.psk!);

  await record.tryWriteBytes(encryptedProfile);
  await record.close();
}

Future<void> deleteDHTRecord(String key, String writer) async {
  final _key = Typed<FixedEncodedString43>.fromString(key);
  final pool = await DHTRecordPool.instance();
  // TODO: Is the record crypto really needed when we do veilid independent psk enc?
  final retrievedRecord =
      await pool.openRead(_key, crypto: const DHTRecordCryptoPublic());
  await retrievedRecord.delete();
}
