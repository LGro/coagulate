// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_scanner/src/objects/barcode_capture.dart';

import '../../data/providers/dht.dart';
import '../../data/repositories/contacts.dart';
import '../../data/models/coag_contact.dart';

part 'cubit.g.dart';
part 'state.dart';

class RecieveRequestCubit extends HydratedCubit<RecieveRequestState> {
  RecieveRequestCubit(this.contactsRepository)
      : super(const RecieveRequestState(RecieveRequestStatus.pickMode)) {
    // TODO: Subscribe to
    // contactsRepository.getUpdateStatus()
  }

  final ContactsRepository contactsRepository;

  @override
  RecieveRequestState fromJson(Map<String, dynamic> json) =>
      RecieveRequestState.fromJson(json);

  @override
  Map<String, dynamic> toJson(RecieveRequestState state) => state.toJson();

  void scanQrCode() =>
      emit(const RecieveRequestState(RecieveRequestStatus.qrcode));

  void readNfcTag() =>
      emit(const RecieveRequestState(RecieveRequestStatus.nfc));

  void pickMode() =>
      emit(const RecieveRequestState(RecieveRequestStatus.pickMode));

  Future<void> qrCodeCaptured(BarcodeCapture capture) async {
    emit(RecieveRequestState(RecieveRequestStatus.processing));
    for (final barcode in capture.barcodes) {
      if (barcode.rawValue != null &&
          barcode.rawValue!.startsWith('https://coagulate.social')) {
        final uri = barcode.rawValue!;

        print('Parsing: $uri');
        String? payload;
        final fragment = Uri.parse(uri).fragment;
        if (fragment.isEmpty) {
          // TODO: Log / feedback?
          print('Payload is empty');
          emit(const RecieveRequestState(RecieveRequestStatus.qrcode));
          return;
        }

        final components = fragment.split(':');
        if (components.length != 3) {
          // TODO: Log / feedback?
          print('Payload malformed, not three long, but $fragment');
          emit(const RecieveRequestState(RecieveRequestStatus.qrcode));
          return;
        }

        try {
          final key = '${components[0]}:${components[1]}';
          final psk = components[2];
          final raw =
              await readPasswordEncryptedDHTRecord(recordKey: key, secret: psk);
          print("Retrieved from DHT Record $key:\n$raw");
          emit(
              RecieveRequestState(RecieveRequestStatus.recieved, profile: raw));
        } on Exception catch (e) {
          // TODO: Log properly / feedback?
          print('Error fetching DHT UPDATE: ${e}');
          emit(const RecieveRequestState(RecieveRequestStatus.qrcode));
        }
      }
    }
  }
}
