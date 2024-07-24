// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../../data/models/coag_contact.dart';
import '../../data/repositories/contacts.dart';
import '../contact_details/page.dart';
import 'cubit.dart';

String formatTimeDifference(Duration d) {
  if (d.isNegative || d < const Duration(minutes: 1)) {
    return 'now';
  }
  if (d < const Duration(hours: 1)) {
    return '${d.inMinutes}m';
  }
  if (d < const Duration(days: 1)) {
    return '${d.inHours}h';
  }
  return '${d.inDays}d';
}

String compareContacts(ContactDetails oldContact, ContactDetails newContact) {
  final results = <String>[];

  if (oldContact.displayName != newContact.displayName) {
    results.add('name');
  } else if (oldContact.name != newContact.name) {
    results.add('name');
  }

  if (!const ListEquality<Email>()
      .equals(oldContact.emails, newContact.emails)) {
    results.add('email addresses');
  }

  if (!const ListEquality<Address>()
      .equals(oldContact.addresses, newContact.addresses)) {
    results.add('addresses');
  }

  if (!const ListEquality<Phone>()
      .equals(oldContact.phones, newContact.phones)) {
    results.add('phone numbers');
  }

  if (!const ListEquality<Website>()
      .equals(oldContact.websites, newContact.websites)) {
    results.add('websites');
  }

  if (!const ListEquality<SocialMedia>()
      .equals(oldContact.socialMedias, newContact.socialMedias)) {
    results.add('social media');
  }

  if (!const ListEquality<Organization>()
      .equals(oldContact.organizations, newContact.organizations)) {
    results.add('organizations');
  }

  if (!const ListEquality<Event>()
      .equals(oldContact.events, newContact.events)) {
    results.add('events');
  }

  return results.join(', ');
}

Widget updateTile(String name, String timing, String change,
        {required void Function()? onTap}) =>
    ListTile(
        onTap: onTap,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: Text(name, overflow: TextOverflow.ellipsis)),
            Text(timing),
          ],
        ),
        subtitle: Row(
          children: [
            // TODO: Use flexible for old and new value to trim them both dynamically
            // Or use Expanded for dynamic multiline
            Expanded(child: Text('Updated $change'))
          ],
        ));

class UpdatesPage extends StatelessWidget {
  const UpdatesPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Updates'),
      ),
      body: BlocProvider(
          create: (context) => UpdatesCubit(context.read<ContactsRepository>()),
          child: BlocConsumer<UpdatesCubit, UpdatesState>(
              listener: (context, state) async {},
              builder: (context, state) => RefreshIndicator(
                  onRefresh: context.read<UpdatesCubit>().refresh,
                  child: ListView(
                    children: (state.updates.isEmpty)
                        ? [
                            Container(
                                padding: const EdgeInsets.all(20),
                                child: const Text(
                                    'No updates yet, share with others or ask others to share with you!',
                                    style: TextStyle(fontSize: 16)))
                          ]
                        : state.updates
                            .map((u) => updateTile(
                                (u.oldContact.displayName.isNotEmpty)
                                    ? u.oldContact.displayName
                                    : u.newContact.displayName,
                                formatTimeDifference(
                                    DateTime.now().difference(u.timestamp)),
                                compareContacts(u.oldContact, u.newContact),
                                // TODO: For location updates, bring to map, centered around location with time slider at right time instead
                                onTap: (u.coagContactId == null)
                                    ? null
                                    : () {
                                        final contact = context
                                            .read<ContactsRepository>()
                                            .getContact(u.coagContactId!);
                                        if (contact == null) {
                                          // TODO: display error?
                                          return;
                                        }
                                        unawaited(Navigator.push(context,
                                            ContactPage.route(contact)));
                                      }))
                            .toList(),
                    // updateTile(
                    //     'Ronja Dudeli van Makolle Longname The Fourth',
                    //     '(today)',
                    //     'Name: Timo => Ronja Dudeli van Makolle Longname The Fourth'),
                    // updateTile('Ronja Dudeli', '(4 days)',
                    //     'Will be near Hamburg, 2024-10-21 till 2024-10-28'),
                    // updateTile(
                    //     'Ronja Dudeli', '(5 days)', 'Started sharing with you'),
                    // updateTile('Timo Dudeli', '(1 month)',
                    //     'Home: Heimsheimer St... => Burgstraße 21, 81992 Heidelberg'),
                    // updateTile('Helli Schmudela', '(2 years)',
                    //     'Work: +3011311411 => +2144242200'),
                  )))));
}
