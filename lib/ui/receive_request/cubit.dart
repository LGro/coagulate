// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:uuid/uuid.dart';
import 'package:veilid/veilid.dart';

import '../../data/models/coag_contact.dart';
import '../../data/repositories/contacts.dart';

part 'cubit.g.dart';
part 'state.dart';

// NOTE: When we make this a hydrated cubit again, we need to find a way how to reset to the initial state after success
class ReceiveRequestCubit extends Cubit<ReceiveRequestState> {
  ReceiveRequestCubit(this.contactsRepository,
      {ReceiveRequestState? initialState})
      : super(initialState ??
            const ReceiveRequestState(ReceiveRequestStatus.qrcode)) {
    if ((initialState?.status.isReceivedUriFragment ?? false) &&
        initialState?.fragment != null) {
      unawaited(handleFragment(initialState!.fragment!));
    }
  }

  final ContactsRepository contactsRepository;

  void scanQrCode() =>
      emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));

  Future<void> pasteInvite() async {
    ClipboardData? clipboardData =
        await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData?.text != null) {
      final fragment = Uri.parse(clipboardData!.text!).fragment;
      if (fragment.isEmpty) {
        // TODO: signal back faulty URL
      } else {
        return handleFragment(fragment);
      }
    }
  }

  Future<void> qrCodeCaptured(BarcodeCapture capture) async {
    emit(const ReceiveRequestState(ReceiveRequestStatus.processing));
    for (final barcode in capture.barcodes) {
      if (barcode.rawValue?.startsWith('https://coagulate.social') ?? false) {
        final uri = barcode.rawValue!;

        final fragment = Uri.parse(uri).fragment;
        if (fragment.isEmpty) {
          // TODO: Log / feedback?
          print('Payload is empty');
          if (!isClosed) {
            emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));
          }
          continue;
        }

        return handleFragment(fragment);
      }
      emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));
    }
  }

  Future<void> linkExistingContact(String coagContactId) async {
    if (state.profile == null) {
      // TODO: more meaningful error handling? because this shouldn't happen
      return emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));
    }

    final contact = state.profile!.copyWith(coagContactId: coagContactId);
    await contactsRepository.saveContact(contact);

    if (!isClosed) {
      emit(ReceiveRequestState(ReceiveRequestStatus.success, profile: contact));
    }
  }

  Future<void> createNewContact() async {
    if (state.profile == null) {
      return emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));
    }

    await contactsRepository.saveContact(state.profile!);

    if (!isClosed) {
      emit(state.copyWith(status: ReceiveRequestStatus.success));
    }
  }

  void updateNewRequesterContact(String value) {
    // Find existing contacts with similar name
    final proposals = contactsRepository
        .getContacts()
        .values
        .where((c) =>
            (c.details != null || c.systemContact != null) &&
            c.coagContactId !=
                contactsRepository.getProfileContact()?.coagContactId &&
            (value.isEmpty ||
                (c.details?.names.values.join() ??
                        c.systemContact?.displayName ??
                        '')
                    .toLowerCase()
                    .contains(value.toLowerCase())))
        .asList();
    // TODO: Slim down this state to what it actually needs to have
    emit(state.copyWith(
        status: ReceiveRequestStatus.receivedRequest,
        profile: CoagContact(
            // TODO: Does it hurt to regenerate a new id each time?
            coagContactId: Uuid().v4(),
            details: ContactDetails(names: {Uuid().v4(): value}),
            dhtSettingsForSharing: state.requestSettings),
        contactProposalsForLinking: proposals));
  }

  Future<void> handleFragment(String fragment) async {
    final components = fragment.split(':');
    if (![3, 5].contains(components.length)) {
      // TODO: Log / feedback?
      print('Payload malformed, not three or five long, but ${fragment}');
      if (!isClosed) {
        emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));
      }
      return;
    }

    final proposals = contactsRepository
        .getContacts()
        .values
        .where((c) =>
            c.coagContactId !=
            contactsRepository.getProfileContact()?.coagContactId)
        .asList();

    final key = '${components[0]}:${components[1]}';
    final psk = components[2];

    try {
      // Just fetch the contact, do not integrate it into the repository yet
      // TODO: Should this live somewhere else? this can be refactored using distributedStorage.getContact
      final contactJson = await contactsRepository.distributedStorage
          .readRecord(recordKey: key, psk: psk);
      if (contactJson.isNotEmpty) {
        final dhtContact = CoagContactDHTSchema.fromJson(
            json.decode(contactJson) as Map<String, dynamic>);
        final contact = CoagContact(
            // TODO: Does it make sense to receive a uuid, to allow unique ID?
            //       Or do it via their pubkey instead?
            coagContactId: Uuid().v4(),
            details: dhtContact.details,
            addressLocations: dhtContact.addressLocations,
            temporaryLocations: dhtContact.temporaryLocations,
            dhtSettingsForReceiving: ContactDHTSettings(
                key: key,
                psk: psk,
                pubKey: await getAppUserKeyPair()
                    .then((kp) => '${cryptoKindToString(kp.kind)}:${kp.key}')),
            dhtSettingsForSharing: (dhtContact.shareBackDHTKey == null)
                ? null
                : ContactDHTSettings(
                    key: dhtContact.shareBackDHTKey!,
                    writer: dhtContact.shareBackDHTWriter,
                    pubKey: dhtContact.shareBackPubKey));

        if (!isClosed) {
          emit(ReceiveRequestState(ReceiveRequestStatus.receivedShare,
              profile: contact,
              requestSettings: contact.dhtSettingsForReceiving,
              // TODO: Intelligently sort depending on profile contact details
              contactProposalsForLinking: proposals));
        }
      }
    } on Exception catch (e) {
      // TODO: Log properly / feedback?
      print('Error fetching DHT UPDATE: ${e}');
      if (!isClosed) {
        emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));
      }
    }
  }
}
