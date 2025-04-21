// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:coagulate/data/models/coag_contact.dart';
import 'package:coagulate/data/models/contact_location.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../mocked_providers.dart';

void main() {
  test('migrate contact address locations from int to label indexing', () {
    const legacyJson = {
      'address_locations': {
        '0': {'longitude': 1.0, 'latitude': 0.0, 'name': 'address-loc'}
      },
      'unrelated': 'unchanged',
    };
    final migrated =
        migrateContactAddressLocationFromIntToLabelIndexing(legacyJson);
    expect(migrated['unrelated'], 'unchanged');
    expect(migrated['address_locations'].keys, contains('address-loc'));
  });

  test('migrate contact address locations in profile info', () {
    const legacyAddressJson = {
      '0': {'longitude': 1.0, 'latitude': 0.0, 'name': 'address-loc'}
    };
    final json = const ProfileInfo('profileId').toJson();
    json['address_locations'] = legacyAddressJson;
    final migrated = migrateContactAddressLocationFromIntToLabelIndexing(json);
    expect(migrated['id'], 'profileId');
    expect(migrated['address_locations'].keys, contains('address-loc'));
    final info = ProfileInfo.fromJson(migrated);
    expect(info.id, 'profileId');
    expect(info.addressLocations.keys.firstOrNull, 'address-loc');
  });

  test(
      'no need to migrate contact address locations from int to label indexing',
      () {
    final upToDateJson = {
      'address_locations': {
        'address-loc':
            const ContactAddressLocation(longitude: 1.0, latitude: 0.0)
                .toJson(),
      },
      'unrelated': 'unchanged',
    };
    final migrated =
        migrateContactAddressLocationFromIntToLabelIndexing(upToDateJson);
    expect(migrated['unrelated'], 'unchanged');
    expect(migrated['address_locations'].keys, contains('address-loc'));
  });

  test('load schema v2 from legacy json', () {
    const addressLocationJson = {
      'longitude': 1.0,
      'latitude': 0.0,
      'name': 'address-loc'
    };
    final temporaryLocation = ContactTemporaryLocation(
        longitude: 0,
        latitude: 0,
        name: 'temp-loc',
        start: DateTime(1909),
        end: DateTime(1910),
        details: '');
    final schemaJsonV2 = {
      'details': {
        'phones': [
          Phone('123', label: PhoneLabel.custom, customLabel: 'bananaphone')
              .toJson()
        ],
        'emails': [
          Email('hi@test.local',
                  label: EmailLabel.custom, customLabel: 'custom-email')
              .toJson()
        ],
        'addresses': [
          Address('Home Sweet Home',
                  label: AddressLabel.custom, customLabel: 'custom-address')
              .toJson()
        ],
        'websites': [
          Website('awesomesite',
                  label: WebsiteLabel.custom, customLabel: 'custom-website')
              .toJson()
        ],
        'social_medias': [
          SocialMedia('@coag', label: SocialMediaLabel.discord).toJson()
        ],
        'events': [],
      },
      'share_back_d_h_t_key': dummyDhtRecordKey().toString(),
      'share_back_pub_key': dummyTypedKeyPair().key.toString(),
      'share_back_d_h_t_writer': dummyTypedKeyPair().toKeyPair().toString(),
      'personal_unique_id': 'unicorn',
      'address_locations': {'0': addressLocationJson},
      'temporary_locations': {'0t': temporaryLocation.toJson()},
      'ack_handshake_complete': true,
      'known_personal_contact_ids': ['homie1', 'homie2'],
    };
    final schema = CoagContactDHTSchemaV2.fromJson(schemaJsonV2);
    expect(schema.details.phones, {'bananaphone': '123'});
    expect(schema.details.emails, {'custom-email': 'hi@test.local'});
    expect(schema.details.websites, {'custom-website': 'awesomesite'});
    expect(schema.details.socialMedias, {'discord': '@coag'});
    expect(schema.shareBackDHTKey, schemaJsonV2['share_back_d_h_t_key']);
    expect(schema.shareBackPubKey, schemaJsonV2['share_back_pub_key']);
    expect(schema.shareBackDHTWriter, schemaJsonV2['share_back_d_h_t_writer']);
    expect(schema.personalUniqueId, schemaJsonV2['personal_unique_id']);
    expect(schema.addressLocations.values.first.longitude, 1);
    expect(schema.addressLocations.keys.first, 'address-loc');
    expect(schema.temporaryLocations.values.first, temporaryLocation);
    expect(schema.ackHandshakeComplete, schemaJsonV2['ack_handshake_complete']);
    expect(schema.knownPersonalContactIds,
        schemaJsonV2['known_personal_contact_ids']);
  });
}
