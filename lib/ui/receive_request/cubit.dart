// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:uuid/uuid.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../data/models/coag_contact.dart';
import '../../data/repositories/contacts.dart';

part 'cubit.g.dart';
part 'state.dart';

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
      final fragment = Uri.parse(clipboardData!.text!.trim()).fragment;
      if (fragment.isEmpty) {
        // TODO: signal back faulty URL
      } else {
        return handleFragment(fragment);
      }
    }
  }

  Future<void> qrCodeCaptured(BarcodeCapture capture) async {
    // Avoid duplicate calls, which apparently happen from the qr detect
    // callback and cause creation of multiple (e.g. 2) contacts
    if (state.status.isProcessing) {
      return;
    }
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

  // name?:dhtRecordKey:psk
  Future<void> handlePersonalInvite(List<String> components) async {
    final name = (components.length == 4) ? components[0] : null;
    final iKey = (components.length == 4) ? 1 : 0;
    final iPsk = (components.length == 4) ? 3 : 2;
    final recordKey = Typed<FixedEncodedString43>.fromString(
        '${components[iKey]}:${components[iKey + 1]}');

    // If we're already receiving from that record, redirect to existing contact
    final existingContactsThemSharing = contactsRepository
        .getContacts()
        .values
        .where((c) => c.dhtSettings.recordKeyThemSharing == recordKey);
    if (existingContactsThemSharing.isNotEmpty) {
      if (!isClosed) {
        emit(state.copyWith(
            status: ReceiveRequestStatus.success,
            profile: existingContactsThemSharing.first));
      }
      return;
    }

    // If I accidentally scanned my own QR code, don't add a contact
    final existingContactsMeSharing = contactsRepository
        .getContacts()
        .values
        .where((c) => c.dhtSettings.recordKeyMeSharing == recordKey);
    if (existingContactsMeSharing.isNotEmpty) {
      if (!isClosed) {
        // TODO: Provide error feedback
        emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));
      }
      return;
    }

    // Otherwise, add new contact with the information we already have
    final contact = CoagContact(
        coagContactId: Uuid().v4(),
        // TODO: localize default to language
        name: name ?? 'unknown',
        // TODO: Handle fromString parsing errors
        dhtSettings: DhtSettings(
            recordKeyThemSharing: recordKey,
            initialSecret: FixedEncodedString43.fromString(components[iPsk]),
            myKeyPair: await DHTRecordPool.instance.veilid
                .bestCryptoSystem()
                .then((cs) => cs
                    .generateKeyPair()
                    .then((kp) => TypedKeyPair.fromKeyPair(cs.kind(), kp)))));

    // Save contact and trigger optional DHT update if connected, this allows
    // to scan a QR code offline and fetch data later if not available now
    await contactsRepository.saveContact(contact);
    unawaited(contactsRepository.updateContactFromDHT(contact));
    if (!isClosed) {
      return emit(state.copyWith(
          status: ReceiveRequestStatus.success, profile: contact));
    }
  }

  // label:dhtRecordKey:psk:subkey:writer
  Future<void> handleBatchInvite(String myName) async {
    if (state.fragment == null) {
      return;
    }
    // TODO: Handle parsing errors and report
    final components = state.fragment!.split(':');
    final recordKey = Typed<FixedEncodedString43>.fromString(
        '${components[1]}:${components[2]}');
    final psk = FixedEncodedString43.fromString(components[3]);
    final mySubkey = int.parse(components[4]);
    final subkeyWriter = KeyPair.fromString(components[5]);

    emit(state.copyWith(status: ReceiveRequestStatus.processing));

    await contactsRepository.handleBatchInvite(
        myName, recordKey, psk, mySubkey, subkeyWriter);

    if (!isClosed) {
      emit(state.copyWith(status: ReceiveRequestStatus.batchInviteSuccess));
    }
  }

  Future<void> handleFragment(String fragment) async {
    final components = fragment.split(':');

    // One person shows another a QR code to connect
    if (![3, 4].contains(components.length)) {
      return handlePersonalInvite(components);
    }

    // Scanning a QR code or handling an invite link from a batch invite
    if (components.length == 6 && !isClosed) {
      return emit(ReceiveRequestState(ReceiveRequestStatus.receivedBatchInvite,
          fragment: fragment));
    }

    // TODO: Log / feedback?
    print('Payload malformed: $fragment');

    if (!isClosed) {
      emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));
    }
  }
}
