// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/coag_contact.dart';
import '../../data/providers/distributed_storage/dht.dart';
import '../../data/repositories/contacts.dart';

part 'cubit.g.dart';
part 'state.dart';

// NOTE: When we make this a hydrated cubit again, we need to find a way how to reset to the initial state after success
class ReceiveRequestCubit extends Cubit<ReceiveRequestState> {
  ReceiveRequestCubit(this.contactsRepository)
      : super(const ReceiveRequestState(ReceiveRequestStatus.qrcode));

  final ContactsRepository contactsRepository;

  void scanQrCode() =>
      emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));

  Future<void> qrCodeCaptured(BarcodeCapture capture) async {
    emit(ReceiveRequestState(ReceiveRequestStatus.processing));
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
          return;
        }

        final components = fragment.split(':');
        if (![3, 5].contains(components.length)) {
          // TODO: Log / feedback?
          print('Payload malformed, not three or five long, but $fragment');
          if (!isClosed) {
            emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));
          }
          return;
        }

        final proposals = contactsRepository.getContacts().values.asList();

        final key = '${components[0]}:${components[1]}';
        final psk = components[2];
        final writer = (components.length == 5)
            ? '${components[3]}:${components[4]}'
            : null;

        if (writer != null) {
          if (!isClosed) {
            emit(ReceiveRequestState(ReceiveRequestStatus.receivedRequest,
                requestSettings:
                    ContactDHTSettings(key: key, psk: psk, writer: writer),
                contactProporsalsForLinking: proposals));
          }
          return;
        }

        // TODO: Refactor updateContactFromDHT to use here as well?
        try {
          final raw = await VeilidDhtStorage()
              .readPasswordEncryptedDHTRecord(recordKey: key, secret: psk);
          print("Retrieved from DHT Record $key:\n$raw");
          // TODO: Error handling
          final contact = CoagContactDHTSchemaV1.fromJson(
              json.decode(raw) as Map<String, dynamic>);
          final coagContact = CoagContact(
              coagContactId: const Uuid().v4(),
              details: contact.details,
              addressLocations: contact.addressLocations,
              temporaryLocations: contact.temporaryLocations,
              dhtSettingsForReceiving: ContactDHTSettings(key: key, psk: psk),
              dhtSettingsForSharing: (contact.shareBackDHTKey == null)
                  ? null
                  : ContactDHTSettings(
                      key: contact.shareBackDHTKey!,
                      pubKey: contact.shareBackPubKey,
                      writer: contact.shareBackDHTWriter));
          if (!isClosed) {
            emit(ReceiveRequestState(
              ReceiveRequestStatus.receivedShare,
              profile: coagContact,

              // TODO: Intelligently sort depending on profile contact
              contactProporsalsForLinking: proposals,
            ));
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
  }

  /// Link an existing contact that has requested sharing
  Future<void> linkExistingContactRequested(CoagContact contact) async {
    final updatedContact = contact.copyWith(
      dhtSettingsForReceiving: state.requestSettings,
      sharedProfile: (contactsRepository.profileContactId == null)
          ? null
          : json.encode(removeNullOrEmptyValues(filterAccordingToSharingProfile(
                  contactsRepository
                      .getContact(contactsRepository.profileContactId!))
              .toJson())),
    );
    await contactsRepository.updateContact(updatedContact);
    if (!isClosed) {
      emit(ReceiveRequestState(ReceiveRequestStatus.success,
          profile: updatedContact));
    }
  }

  /// Link an existing contact that has shared
  Future<void> linkExistingContactSharing(CoagContact contact) async {
    final updatedContact = contact.copyWith(
        dhtSettingsForReceiving: state.profile?.dhtSettingsForReceiving,
        details: state.profile?.details);
    await contactsRepository.updateContact(updatedContact);
    if (!isClosed) {
      emit(ReceiveRequestState(ReceiveRequestStatus.success,
          profile: updatedContact));
    }
  }

  Future<void> createNewContact() async {
    if (state.profile == null) {
      return;
    }
    // TODO: This can result in creating the contact twice (I guess when we create the system contact first, coagulate picks up on that, creates the coag contact and then we run update with a separate ID)
    final contact = state.profile?.details != null &&
            await FlutterContacts.requestPermission()
        ? state.profile!.copyWith(
            systemContact: await FlutterContacts.insertContact(
                state.profile!.details!.toSystemContact()))
        : state.profile!;

    await contactsRepository.updateContact(contact);

    if (!isClosed) {
      emit(ReceiveRequestState(ReceiveRequestStatus.success, profile: contact));
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
                (c.details?.displayName ?? c.systemContact?.displayName ?? '')
                    .toLowerCase()
                    .contains(value.toLowerCase())))
        .asList();
    emit(ReceiveRequestState(ReceiveRequestStatus.receivedRequest,
        profile: CoagContact(
            // TODO: Does it hurt to regenerate a new id each time?
            coagContactId: Uuid().v4(),
            details:
                ContactDetails(displayName: value, name: Name(first: value)),
            dhtSettingsForSharing: state.requestSettings),
        contactProporsalsForLinking: proposals));
  }
}
