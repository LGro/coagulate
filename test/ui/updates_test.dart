// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:coagulate/data/models/coag_contact.dart';
import 'package:coagulate/ui/updates/page.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('compare contact details', () {
    final resultSame = compareContacts(
        ContactDetails(names: const {'0': 'a'}, emails: [Email('e@1.de')]),
        ContactDetails(names: const {'0': 'a'}, emails: [Email('e@1.de')]));
    expect(resultSame, '');

    final resultDifferentEmail = compareContacts(
        ContactDetails(names: const {'0': 'a'}, emails: [Email('e@1.de')]),
        ContactDetails(names: const {'0': 'a'}, emails: [Email('e@2.de')]));
    expect(resultDifferentEmail, 'email addresses');
  });
}
