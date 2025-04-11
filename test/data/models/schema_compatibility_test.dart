// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:coagulate/data/models/coag_contact.dart';
import 'package:coagulate/data/models/contact_location.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../mocked_providers.dart';

void main() {
  test('load schema v2 from json', () {
    const details = ContactDetails();
    const addressLocation =
        ContactAddressLocation(longitude: 0, latitude: 0, name: 'address-loc');
    final temporaryLocation = ContactTemporaryLocation(
        longitude: 0,
        latitude: 0,
        name: 'temp-loc',
        start: DateTime(1909),
        end: DateTime(1910),
        details: '');
    final schemaJsonV2 = {
      'details': details.toJson(),
      'share_back_d_h_t_key': dummyDhtRecordKey().toString(),
      'share_back_pub_key': dummyTypedKeyPair().key.toString(),
      'share_back_d_h_t_writer': dummyTypedKeyPair().toKeyPair().toString(),
      'personal_unique_id': 'unicorn',
      'address_locations': {'0': addressLocation.toJson()},
      'temporary_locations': {'0t': temporaryLocation.toJson()},
      'ack_handshake_complete': true,
      'known_personal_contact_ids': ['homie1', 'homie2'],
    };
    final schema = CoagContactDHTSchemaV2.fromJson(schemaJsonV2);
    expect(schema.details, details);
    expect(schema.shareBackDHTKey, schemaJsonV2['share_back_d_h_t_key']);
    expect(schema.shareBackPubKey, schemaJsonV2['share_back_pub_key']);
    expect(schema.shareBackDHTWriter, schemaJsonV2['share_back_d_h_t_writer']);
    expect(schema.personalUniqueId, schemaJsonV2['personal_unique_id']);
    expect(schema.addressLocations.values.first, addressLocation);
    expect(schema.temporaryLocations.values.first, temporaryLocation);
    expect(schema.ackHandshakeComplete, schemaJsonV2['ack_handshake_complete']);
    expect(schema.knownPersonalContactIds,
        schemaJsonV2['known_personal_contact_ids']);
  });
}
