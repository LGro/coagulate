// Copyright 2024 Lukas Grossberger
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';

import '../veilid_support/veilid_support.dart';

part 'peer_contact_cubit.g.dart';
part 'peer_contact_state.dart';

String generateProfileJsonForSharing(Contact profile, String? shareProfile) {
  final profileJson = <String, dynamic>{};
  // TODO: Replace with shareProfile dependent filtering
  profileJson['name'] = profile.name.toJson();
  profileJson['emails'] = profile.emails.map((e) => e.toJson());
  profileJson['phones'] = profile.phones.map((p) => p.toJson());
  final profileJsonString = const JsonEncoder().convert(profileJson);
  return profileJsonString;
}

class PeerContactCubit extends HydratedCubit<PeerContactState> {
  PeerContactCubit()
      : super(const PeerContactState({}, PeerContactStatus.initial));

  void refreshContactsFromSystem() async {
    if (!await FlutterContacts.requestPermission()) {
      emit(PeerContactState(state.contacts, PeerContactStatus.denied));
      return;
    }

    // TODO: Can this be done one the fly somehow instead of all at once
    //       or is it fast enough to not be a bottleneck?
    Map<String, PeerContact> updatedContacts = {};
    // TODO: Consider loading them first without tumbnail and then with, to speed things up
    for (Contact contact in (await FlutterContacts.getContacts(
        withThumbnail: true, withProperties: true))) {
      updatedContacts[contact.id] = state.contacts.containsKey(contact.id)
          ? state.contacts[contact.id]!.copyWith(contact: contact)
          : PeerContact(contact: contact);
    }
    ;
    // TODO: When changing a contact, switching back to the contact list and
    //       leaving it, it seems like it can happen that this still emits a
    //       state after the contacts have been refreshed but the view is
    //       already closed with causes an error.
    //       It also happens when a contact is updated in the address book in
    //       the background.
    //       https://stackoverflow.com/questions/55536461/flutter-unhandled-exception-bad-state-cannot-add-new-events-after-calling-clo
    emit(PeerContactState(updatedContacts, PeerContactStatus.success));
  }

  void updateContact(String id, String sharingProfile) {
    // TODO: Handle id not found
    // TODO: Is this really the way with all the copying?
    state.contacts[id] =
        state.contacts[id]!.copyWith(sharingProfile: sharingProfile);
    emit(PeerContactState(state.contacts, PeerContactStatus.success));
  }

  Future<void> shareWithPeer(String contactId, Contact profileContact) async {
    if (!state.contacts.containsKey(contactId)) {
      // TODO: Log because this shouldn't happen
      return;
    }

    final contact = state.contacts[contactId]!;
    var myRecord = contact.myRecord;
    if (myRecord == null) {
      String key;
      String writer;
      (key, writer) = await createDHTRecord();
      myRecord = MyDHTRecord(key: key, writer: writer);
    }

    if (myRecord.psk == null) {
      myRecord = MyDHTRecord(
          key: myRecord.key,
          writer: myRecord.writer,
          // TODO: Generate from strong randomness
          psk: 'randomsecret1234');
    }
    final profileJson = generateProfileJsonForSharing(profileContact, null);
    await updateDHTRecord(myRecord, profileJson);

    // TODO: Set sharing profile when feature available
    state.contacts[contactId] =
        contact.copyWith(myRecord: myRecord, sharingProfile: 'default');

    emit(PeerContactState(state.contacts, PeerContactStatus.success));
  }

  Future<void> unshareWithPeer(String contactId) async {
    if (!state.contacts.containsKey(contactId)) {
      // TODO: Log because this shouldn't happen
      return;
    }

    var contact = state.contacts[contactId]!;
    if (contact.myRecord == null) {
      // TODO: Log because this shouldn't happen
      return;
    }

    // TODO: Do we find writing empty more convenient because of the re-coagulation potential
    //       or is deleting cleaner to not pollute the DHT?
    await updateDHTRecord(contact.myRecord!, '');

    state.contacts[contactId] = contact.copyWith(sharingProfile: 'dont');

    emit(PeerContactState(state.contacts, PeerContactStatus.success));
  }

  @override
  PeerContactState fromJson(Map<String, dynamic> json) =>
      PeerContactState.fromJson(json);

  @override
  Map<String, dynamic> toJson(PeerContactState state) => state.toJson();
}

Future<(String, String)> createDHTRecord() async {
  final pool = await DHTRecordPool.instance();
  final record = await pool.create();
  await record.close();
  return (record.key.toString(), record.writer!.toString());
}

Future<void> updateDHTRecord(MyDHTRecord myRecordInfo, String profile) async {
  final _key = Typed<FixedEncodedString43>.fromString(myRecordInfo.key);
  final writer = KeyPair.fromString(myRecordInfo.writer);
  final pool = await DHTRecordPool.instance();
  final record = await pool.openWrite(_key, writer,
      // TODO: Is the record crypto really needed when we do veilid independent psk enc?
      crypto: await DHTRecordCryptoPrivate.fromTypedKeyPair(
          TypedKeyPair.fromKeyPair(_key.kind, writer)));

  final cs = await pool.veilid.bestCryptoSystem();
  // TODO: Ensure via type that psk is available
  final encryptedProfile =
      await cs.encryptAeadWithPassword(utf8.encode(profile), myRecordInfo.psk!);

  await record.eventualWriteBytes(encryptedProfile);
  await record.close();
}

Future<void> deleteDHTRecord(String key, String writer) async {
  final _key = Typed<FixedEncodedString43>.fromString(key);
  final pool = await DHTRecordPool.instance();
  // TODO: Is the record crypto really needed when we do veilid independent psk enc?
  final retrievedRecord = await pool.openRead(_key,
      crypto: await DHTRecordCryptoPrivate.fromTypedKeyPair(
          TypedKeyPair.fromKeyPair(_key.kind, KeyPair.fromString(writer))));
  await retrievedRecord.delete();
}
