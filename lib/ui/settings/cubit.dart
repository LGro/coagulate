// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:math';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:faker/faker.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:image/image.dart' as img;
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:veilid/veilid.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../data/models/coag_contact.dart';
import '../../data/models/contact_location.dart';
import '../../data/repositories/contacts.dart';

part 'cubit.g.dart';
part 'state.dart';

Uint8List generateRandomImage(int width, int height) {
  // Create an empty image
  final image = img.Image(width: width, height: height);

  final random = Random();

  // Fill image with random colors
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      image.setPixel(
          x,
          y,
          img.ColorInt8.rgba(
            random.nextInt(256), // Red
            random.nextInt(256), // Green
            random.nextInt(256), // Blue
            255, // Alpha
          ));
    }
  }

  return img.encodeJpg(image);
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this.contactsRepository)
      : super(const SettingsState(
            message: '',
            status: SettingsStatus.initial,
            darkMode: false,
            autoAddressResolution: true,
            mapProvider: 'mapbox'));

  ContactsRepository contactsRepository;

  Future<void> addDummyContact() async {
    final faker = Faker();
    final coagContactId = Uuid().v4();
    final c1 = CoagContact(
        coagContactId: coagContactId,
        name: faker.person.name(),
        details: ContactDetails(
            // TODO: do too large noisy images break things?
            picture: generateRandomImage(20, 20),
            phones: [
              Phone(faker.phoneNumber.de(),
                  label: PhoneLabel.custom, customLabel: 'mobile')
            ]),
        addressLocations: Map.fromEntries([1, 2, 3].map((index) => MapEntry(
            index,
            ContactAddressLocation(
                longitude: faker.geo.longitude(),
                latitude: faker.geo.latitude(),
                name: faker.address.streetAddress(),
                coagContactId: coagContactId)))),
        temporaryLocations:
            Map.fromEntries([Uuid().v4(), Uuid().v4(), Uuid().v4()].map((id) {
          final start = faker.date.dateTime();
          return MapEntry(
              id,
              ContactTemporaryLocation(
                  longitude: faker.geo.longitude(),
                  latitude: faker.geo.latitude(),
                  name: faker.address.streetAddress(),
                  start: start,
                  end: start
                      .add(Duration(days: faker.randomGenerator.integer(30))),
                  details: faker.lorem.sentence()));
        })),
        dhtSettings: DhtSettings(
            myKeyPair: await DHTRecordPool.instance.veilid
                .bestCryptoSystem()
                .then((cs) => cs
                    .generateKeyPair()
                    .then((kp) => TypedKeyPair.fromKeyPair(cs.kind(), kp)))));
    await contactsRepository.saveContact(c1);
  }
}
