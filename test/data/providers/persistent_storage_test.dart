// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:coagulate/data/models/coag_contact.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('contact details from address book types to simple maps', () {
    final json = {
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
    };
    final details = ContactDetails.fromJson(
        migrateContactDetailsJsonFromFlutterContactsTypeToSimpleMaps(json));
    expect(details.phones, {'bananaphone': '123'});
    expect(details.emails, {'custom-email': 'hi@test.local'});
    expect(details.websites, {'custom-website': 'awesomesite'});
    expect(details.socialMedias, {'discord': '@coag'});
  });
}
