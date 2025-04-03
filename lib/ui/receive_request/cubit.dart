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
    if (initialState == null) {
      return;
    }
    if (initialState.status.isHandleDirectSharing) {
      unawaited(handleDirectSharing(initialState.fragment ?? ''));
    }
    if (initialState.status.isHandleProfileLink) {
      unawaited(handleProfileLink(initialState.fragment ?? ''));
    }
    if (initialState.status.isHandleSharingOffer) {
      unawaited(handleSharingOffer(initialState.fragment ?? ''));
    }
  }

  final ContactsRepository contactsRepository;

  Future<void> pasteInvite() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData?.text != null) {
      emit(const ReceiveRequestState(ReceiveRequestStatus.processing));
      try {
        final url = Uri.parse(clipboardData!.text!.trim());
        // Deal with /c/ and /c variants of paths
        final path = url.path.split('/').where((p) => p.isNotEmpty).toList();
        if (path.length != 1) {
          // TODO: Signal faulty URL
          emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));
          return;
        }
        if (path.first == 'c') {
          return handleDirectSharing(url.fragment);
        }
        if (path.first == 'p') {
          return handleProfileLink(url.fragment);
        }
        if (path.first == 'o') {
          return handleSharingOffer(url.fragment);
        }
        if (path.first == 'b') {
          return emit(state.copyWith(
              status: ReceiveRequestStatus.handleBatchInvite,
              fragment: url.fragment));
        }
      } on FormatException {
        // TODO: signal back faulty URL
      }
      if (!isClosed) {
        emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));
      }
    }
  }

  void scanQrCode() =>
      emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));

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

        // TODO: Handle malformed Uri, parser error
        final url = Uri.parse(uri);
        if (url.fragment.isEmpty) {
          // TODO: Log / feedback?
          print('Payload is empty');
          if (!isClosed) {
            emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));
          }
          continue;
        }
        final path = url.path.split('/').where((p) => p.isNotEmpty).toList();
        if (path.length != 1) {
          // TODO: Signal faulty URL or just skip?
          continue;
        }
        if (path.first == 'c') {
          return handleDirectSharing(url.fragment);
        }
        if (path.first == 'p') {
          return handleProfileLink(url.fragment);
        }
        if (path.first == 'o') {
          return handleSharingOffer(url.fragment);
        }
        if (path.first == 'b') {
          return emit(state.copyWith(
              status: ReceiveRequestStatus.handleBatchInvite,
              fragment: url.fragment));
        }
      }
      if (!isClosed) {
        emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));
      }
    }
  }

  // name~recordKey~psk
  Future<void> handleDirectSharing(String fragment,
      {bool awaitDhtOperations = false}) async {
    if (!isClosed) {
      emit(const ReceiveRequestState(ReceiveRequestStatus.processing));
    }

    final parts = fragment.split('~');
    if (parts.length < 3) {
      // TODO: Emit error notice
      if (!isClosed) {
        emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));
      }
      return;
    }
    // TODO: Handle fromString parsing errors
    final psk = FixedEncodedString43.fromString(parts.removeLast());
    final recordKey = TypedKey.fromString(parts.removeLast());
    // Allow use of ~ in name
    final name = Uri.decodeComponent(parts.join('~'));

    // If we're already receiving from that record, redirect to existing contact/
    // TODO: Should we check for ID or pubkey change / mismatch?
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
        name: name,
        // TODO: Handle fromString parsing errors
        dhtSettings: DhtSettings(
            recordKeyThemSharing: recordKey,
            initialSecret: psk,
            myKeyPair: await contactsRepository.generateTypedKeyPair()));

    // Save contact and trigger optional DHT update if connected, this allows
    // to scan a QR code offline and fetch data later if not available now
    await contactsRepository.saveContact(contact);
    await contactsRepository.updateCirclesForContact(
        contact.coagContactId, [defaultEveryoneCircleId],
        triggerDhtUpdate: false);

    final addedContact = contactsRepository.getContact(contact.coagContactId);
    if (addedContact == null) {
      if (!isClosed) {
        emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));
      }
      return;
    }

    // Update first to get share back settings and then try to share back
    final dhtOperations = contactsRepository
        .updateContactFromDHT(addedContact)
        .then((success) => success
            ? contactsRepository
                .tryShareWithContactDHT(addedContact.coagContactId)
            : success);
    if (awaitDhtOperations) {
      await dhtOperations;
    } else {
      unawaited(dhtOperations);
    }

    if (!isClosed) {
      return emit(state.copyWith(
          status: ReceiveRequestStatus.success, profile: addedContact));
    }
  }

  // TODO: Does it make sense to check first if we already know this pubkey?
  // TODO: Allow option to match with existing contact?
  // name~publicKey
  Future<void> handleProfileLink(String fragment,
      {bool awaitDhtOperations = false}) async {
    if (!isClosed) {
      emit(const ReceiveRequestState(ReceiveRequestStatus.processing));
    }

    final parts = fragment.split('~');
    if (parts.length < 2) {
      // TODO: Emit error notice
      if (!isClosed) {
        emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));
      }
      return;
    }
    // TODO: Handle fromString parsing errors
    final publicKey = PublicKey.fromString(parts.removeLast());
    // Allow use of ~ in name
    final name = Uri.decodeComponent(parts.join('~'));

    final profileInfo = contactsRepository.getProfileInfo();
    if (profileInfo?.mainKeyPair?.key.toString() == publicKey.toString()) {
      // TODO: Display "this is you, share it with others, it'll be great" msg
      if (!isClosed) {
        emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));
      }
      return;
    }

    // TODO: Check if contact already exists - key generation can take a moment and this can cause duplicate entries if people resubmit
    final contact = await contactsRepository.createContactForInvite(name,
        pubKey: publicKey, awaitDhtSharingAttempt: awaitDhtOperations);

    if (!isClosed) {
      return emit(state.copyWith(
          status: ReceiveRequestStatus.success, profile: contact));
    }
  }

  // name~typedRecordKey~publicKey
  Future<void> handleSharingOffer(String fragment,
      {bool awaitDhtOperations = false}) async {
    if (!isClosed) {
      emit(const ReceiveRequestState(ReceiveRequestStatus.processing));
    }
    final parts = fragment.split('~');
    if (parts.length < 3) {
      // TODO: Emit error notice
      if (!isClosed) {
        emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));
      }
      return;
    }
    // TODO: Handle fromString parsing errors
    final publicKey = PublicKey.fromString(parts.removeLast());
    final recordKey = TypedKey.fromString(parts.removeLast());
    // Allow use of ~ in name
    final name = Uri.decodeComponent(parts.join('~'));

    if (contactsRepository.getProfileInfo()?.mainKeyPair == null) {
      // TODO: Emit error notice
      if (!isClosed) {
        emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));
      }
      return;
    }

    // Otherwise, add new contact with the information we already have
    final contact = CoagContact(
        coagContactId: Uuid().v4(),
        name: name,
        dhtSettings: DhtSettings(
            recordKeyThemSharing: recordKey,
            theirPublicKey: publicKey,
            myKeyPair: contactsRepository.getProfileInfo()!.mainKeyPair!,
            // We skip the DH key exchange and directly start with all pub keys
            theyAckHandshakeComplete: true));

    // Save contact and trigger optional DHT update if connected, this allows
    // to scan a QR code offline and fetch data later if not available now
    await contactsRepository.saveContact(contact);
    await contactsRepository.updateCirclesForContact(
        contact.coagContactId, [defaultEveryoneCircleId],
        triggerDhtUpdate: false);

    final addedContact = contactsRepository.getContact(contact.coagContactId);
    if (addedContact == null) {
      if (!isClosed) {
        emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));
      }
      return;
    }

    final dhtOperations = contactsRepository
        .updateContactFromDHT(addedContact)
        .then((success) => success
            ? contactsRepository
                .tryShareWithContactDHT(addedContact.coagContactId)
            : success);
    if (awaitDhtOperations) {
      await dhtOperations;
    } else {
      unawaited(dhtOperations);
    }

    if (!isClosed) {
      return emit(state.copyWith(
          status: ReceiveRequestStatus.success, profile: addedContact));
    }
  }

  // label~recordKey~psk~subkeyIndex~subkeyWriter
  Future<void> handleBatchInvite({required String myNameId}) async {
    if (state.fragment == null) {
      // TODO: Emit error
      if (!isClosed) {
        emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));
      }
      return;
    }

    final parts = state.fragment!.split('~');
    if (parts.length < 5) {
      // TODO: Emit error notice
      if (!isClosed) {
        emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));
      }
      return;
    }
    if (!isClosed) {
      emit(state.copyWith(status: ReceiveRequestStatus.processing));
    }

    // TODO: Handle parsing errors
    final subkeyWriter = KeyPair.fromString(parts.removeLast());
    final subkeyIndex = int.parse(parts.removeLast());
    final psk = FixedEncodedString43.fromString(parts.removeLast());
    final recordKey = TypedKey.fromString(parts.removeLast());

    await contactsRepository.handleBatchInvite(
        myNameId, recordKey, psk, subkeyIndex, subkeyWriter);

    if (!isClosed) {
      emit(state.copyWith(status: ReceiveRequestStatus.batchInviteSuccess));
    }
  }
}
