// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:uuid/uuid.dart';

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

  /// Link the request of a contact for met to share to an existing contact
  Future<void> linkExistingContactRequested(String coagContactId) async {
    if (state.requestSettings == null) {
      // TODO: more meaningful error handling? because this shouldn't happen
      emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));
      return;
    }

    await contactsRepository.updateContactSharingSettings(
        coagContactId, state.requestSettings!);

    if (!isClosed) {
      emit(ReceiveRequestState(ReceiveRequestStatus.success,
          profile: contactsRepository.getContact(coagContactId)));
    }
  }

  /// Link the request of a contact to share with me to an existing contact
  Future<void> linkExistingContactSharing(String coagContactId) async {
    if (state.requestSettings == null) {
      // TODO: more meaningful error handling? because this shouldn't happen
      emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));
      return;
    }

    await contactsRepository.updateContactReceivingSettings(
        coagContactId, state.requestSettings!);

    if (!isClosed) {
      emit(ReceiveRequestState(ReceiveRequestStatus.success,
          profile: contactsRepository.getContact(coagContactId)));
    }
  }

  Future<void> createNewContact() async {
    if (state.requestSettings == null) {
      return;
    }

    // Immediately signal ongoing processing; because otherwise the UI will not change until this finishes
    // TODO: Add details about what processing means
    emit(state.copyWith(status: ReceiveRequestStatus.processing));

    final coagContactId = const Uuid().v4();
    await contactsRepository.updateContactFromDHT(CoagContact(
        coagContactId: coagContactId,
        dhtSettingsForReceiving: state.requestSettings));

    if (!isClosed) {
      final contact = contactsRepository.getContact(coagContactId);
      if (contact == null) {
        // TODO: add error infos
        emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));
      } else {
        emit(ReceiveRequestState(ReceiveRequestStatus.success,
            profile: contact));
      }
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
                (c.details?.displayName ?? c.systemContact?.displayName ?? '')
                    .toLowerCase()
                    .contains(value.toLowerCase())))
        .asList();
    emit(state.copyWith(
        status: ReceiveRequestStatus.receivedRequest,
        profile: CoagContact(
            // TODO: Does it hurt to regenerate a new id each time?
            coagContactId: Uuid().v4(),
            details:
                ContactDetails(displayName: value, name: Name(first: value)),
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
    final writer =
        (components.length == 5) ? '${components[3]}:${components[4]}' : null;

    if (writer != null) {
      if (!isClosed) {
        emit(ReceiveRequestState(ReceiveRequestStatus.receivedRequest,
            requestSettings:
                ContactDHTSettings(key: key, psk: psk, writer: writer),
            contactProposalsForLinking: proposals));
      }
      return;
    }

    final initialContact = CoagContact(
      coagContactId: const Uuid().v4(),
      dhtSettingsForReceiving: ContactDHTSettings(key: key, psk: psk),
    );
    try {
      // Just fetch the contact, do not integrate it into the repository yet
      final contact = await contactsRepository.distributedStorage
          .updateContactReceivingDHT(initialContact);
      if (!isClosed) {
        emit(ReceiveRequestState(ReceiveRequestStatus.receivedShare,
            profile: contact,
            requestSettings: contact.dhtSettingsForReceiving,
            // TODO: Intelligently sort depending on profile contact details
            contactProposalsForLinking: proposals));
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
