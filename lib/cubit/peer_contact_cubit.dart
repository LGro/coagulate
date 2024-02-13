// Copyright 2024 Lukas Grossberger
import 'package:equatable/equatable.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';

part 'peer_contact_cubit.g.dart';
part 'peer_contact_state.dart';

class PeerContactCubit extends HydratedCubit<PeerContactState> {
  PeerContactCubit() : super(const PeerContactState({}, PeerContactStatus.initial));

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
        updatedContacts[contact.id] = state.contacts.containsKey(contact.id) ?
        state.contacts[contact.id]!.copyWith(contact: contact):
        PeerContact(contact: contact);
      };
    // TODO: When changing a contact, switching back to the contact list and
    //       leaving it, it seems like it can happen that this still emits a
    //       state after the contacts have been refreshed but the view is
    //       already closed with causes an error.
    emit(PeerContactState(updatedContacts, PeerContactStatus.success));
  }

  @override
  PeerContactState fromJson(Map<String, dynamic> json) =>
      PeerContactState.fromJson(json);

  @override
  Map<String, dynamic> toJson(PeerContactState state) => state.toJson();
}
