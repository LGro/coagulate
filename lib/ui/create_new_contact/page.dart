// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../../data/models/coag_contact.dart';
import '../receive_request/page.dart';

class CreateNewContactPage extends StatelessWidget {
  const CreateNewContactPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Invite someone'),
      ),
      body: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Who would you like to invite?'),
              const SizedBox(height: 4),
              TextField(
                controller: TextEditingController(text: ''),
                autofocus: true,
                autocorrect: false,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 4),
              FilledButton(
                  onPressed: () => {}, child: const Text('prepare invite')),
              // If there are any after typing in the first character
              const SizedBox(height: 8),
              const Text('or pick an existing contact with a matching name:'),
              const SizedBox(height: 4),
              Expanded(
                  child: pickExistingContact([
                CoagContact(
                    coagContactId: 'dummy1',
                    systemContact: Contact(displayName: 'Dummy 1')),
                CoagContact(
                    coagContactId: 'dummy2',
                    systemContact: Contact(displayName: 'Dummy 2')),
              ], (cId) async => {})),
            ],
          )));
}
