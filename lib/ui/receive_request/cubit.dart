// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';

import 'package:equatable/equatable.dart';
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
          emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));
          return;
        }

        final components = fragment.split(':');
        if (components.length != 3) {
          // TODO: Log / feedback?
          print('Payload malformed, not three long, but $fragment');
          emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));
          return;
        }

        try {
          final key = '${components[0]}:${components[1]}';
          final psk = components[2];
          // TODO: Refactor updateContactFromDHT to use here as well?
          final raw =
              await readPasswordEncryptedDHTRecord(recordKey: key, secret: psk);
          print("Retrieved from DHT Record $key:\n$raw");
          // TODO: Error handling
          final contact = CoagContactDHTSchemaV1.fromJson(
              json.decode(raw) as Map<String, dynamic>);
          emit(ReceiveRequestState(ReceiveRequestStatus.received,
              profile: CoagContact(
                  coagContactId: const Uuid().v4(),
                  details: contact.details,
                  locations: contact.locations,
                  dhtSettingsForReceiving:
                      ContactDHTSettings(key: key, psk: psk),
                  dhtSettingsForSharing: (contact.shareBackDHTKey == null)
                      ? null
                      : ContactDHTSettings(
                          key: contact.shareBackDHTKey!,
                          pubKey: contact.shareBackPubKey,
                          writer: contact.shareBackDHTWriter))));
        } on Exception catch (e) {
          // TODO: Log properly / feedback?
          print('Error fetching DHT UPDATE: ${e}');
          emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));
        }
      }
    }
  }

  // TODO: Replace with proper type instead of string
  void linkExistingContact() {
    // TODO: Replace with proper deserialized profile
    // final nameFromDHT = state.profile;
    // final potentialMatches = contactsRepository.coagContacts.values.firstWhere(
    //     (c) =>
    //         c.systemContact?.name == nameFromDHT ||
    //         c.details?.name == nameFromDHT);
    // TODO: Propose potential matches; compute earlier, move to state
  }

  // TODO: Replace with proper type instead of string
  Future<void> createNewContact() async {
    // TODO: Allow creation of linked system contact
    await contactsRepository.updateContact(state.profile!);
    emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));
    // TODO: Forward instead to contact details page to share back etc.
  }
}
