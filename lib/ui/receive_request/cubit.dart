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

// TODO: Revisit which statuses we still need
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
            (value.isEmpty ||
                (c.details?.names.values.join() ??
                        c.systemContact?.displayName ??
                        '')
                    .toLowerCase()
                    .contains(value.toLowerCase())))
        .asList();
    // FIXME: Do something with the proposals
  }

  Future<void> handleFragment(String fragment) async {
    final components = fragment.split(':');
    if (![3, 4].contains(components.length)) {
      // TODO: Log / feedback?
      print('Payload malformed, not three or four long, but $fragment');
      if (!isClosed) {
        emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));
      }
      return;
    }

    final name = components.getOrNull(-4);
    final dhtSettingsForReceiving = ContactDHTSettings(
        key: '${components[-3]}:${components[-2]}',
        psk: components[-1],
        pubKey: await getAppUserKeyPair()
            .then((kp) => '${cryptoKindToString(kp.kind)}:${kp.key}'));
    var contact = CoagContact(
        coagContactId: Uuid().v4(),
        // TODO: localize default to language
        name: name ?? 'unknown',
        dhtSettingsForReceiving: dhtSettingsForReceiving);

    try {
      // Just fetch the contact, do not integrate it into the repository yet
      // TODO: Should this live somewhere else? this can be refactored using distributedStorage.getContact
      final contactJson = await contactsRepository.distributedStorage
          .readRecord(
              recordKey: dhtSettingsForReceiving.key,
              psk: dhtSettingsForReceiving.psk);
      if (contactJson.isNotEmpty) {
        final dhtContact = CoagContactDHTSchema.fromJson(
            json.decode(contactJson) as Map<String, dynamic>);
        contact = contact.copyWith(
            // TODO: Use email address if provided instead?
            name: dhtContact.details.names.values.firstOrNull,
            details: dhtContact.details,
            addressLocations: dhtContact.addressLocations,
            temporaryLocations: dhtContact.temporaryLocations,
            dhtSettingsForSharing: (dhtContact.shareBackDHTKey == null)
                ? null
                : ContactDHTSettings(
                    key: dhtContact.shareBackDHTKey!,
                    writer: dhtContact.shareBackDHTWriter,
                    pubKey: dhtContact.shareBackPubKey,
                  ));
      }
    } on Exception catch (e) {
      // Log or display?
    }

    await contactsRepository.saveContact(contact);
    if (!isClosed) {
      return emit(state.copyWith(
          status: ReceiveRequestStatus.success, profile: contact));
    }
  }
}
