// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/coag_contact.dart';
import '../../data/providers/dht.dart';
import '../../data/repositories/contacts.dart';

part 'cubit.g.dart';
part 'state.dart';

class ReceiveRequestCubit extends HydratedCubit<ReceiveRequestState> {
  ReceiveRequestCubit(this.contactsRepository)
      : super(const ReceiveRequestState(ReceiveRequestStatus.qrcode));

  final ContactsRepository contactsRepository;

  @override
  ReceiveRequestState fromJson(Map<String, dynamic> json) =>
      ReceiveRequestState.fromJson(json);

  @override
  Map<String, dynamic> toJson(ReceiveRequestState state) => state.toJson();

  void scanQrCode() =>
      emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));

  Future<void> qrCodeCaptured(BarcodeCapture capture) async {
    emit(ReceiveRequestState(ReceiveRequestStatus.processing));
    for (final barcode in capture.barcodes) {
      if (barcode.rawValue != null &&
          barcode.rawValue!.startsWith('https://coagulate.social')) {
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
        if (![3, 4].contains(components.length)) {
          // TODO: Log / feedback?
          print('Payload malformed, not three or four long, but $fragment');
          if (!isClosed) {
            emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));
          }
          return;
        }

        try {
          final key = '${components[0]}:${components[1]}';
          final psk = components[2];
          // TODO: Handle request qr code in addition to sharing qr code
          final writer = components.elementAtOrNull(3);
          // TODO: Refactor updateContactFromDHT to use here as well?
          final raw =
              await readPasswordEncryptedDHTRecord(recordKey: key, secret: psk);
          print("Retrieved from DHT Record $key:\n$raw");
          // TODO: Error handling
          final contact = CoagContactDHTSchemaV1.fromJson(
              json.decode(raw) as Map<String, dynamic>);
          if (!isClosed) {
            final coagContact = CoagContact(
                coagContactId: const Uuid().v4(),
                details: contact.details,
                locations: contact.locations,
                dhtSettingsForReceiving: ContactDHTSettings(key: key, psk: psk),
                dhtSettingsForSharing: (contact.shareBackDHTKey == null)
                    ? null
                    : ContactDHTSettings(
                        key: contact.shareBackDHTKey!,
                        pubKey: contact.shareBackPubKey,
                        writer: contact.shareBackDHTWriter));
            final proposals = contactsRepository.getContacts().values.asList();
            emit(ReceiveRequestState(ReceiveRequestStatus.received,
                profile: coagContact, contactProporsalsForLinking: proposals));
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

  void linkExistingContact(CoagContact contact) {
    final updatedContact = contact.copyWith(
        dhtSettingsForReceiving: state.profile!.dhtSettingsForReceiving);
    unawaited(contactsRepository.updateContact(updatedContact));
    if (!isClosed) {
      emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));
    }
    // TODO: Forward instead to contact details page to share back etc.
  }

  Future<void> createNewContact() async {
    final CoagContact contact;
    if (await FlutterContacts.requestPermission()) {
      contact = state.profile!.copyWith(
          systemContact: await FlutterContacts.insertContact(
              state.profile!.details!.toSystemContact()));
    } else {
      contact = state.profile!;
    }
    await contactsRepository.updateContact(contact);
    if (!isClosed) {
      emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));
    }
    // TODO: Forward instead to contact details page to share back etc.
  }
}
