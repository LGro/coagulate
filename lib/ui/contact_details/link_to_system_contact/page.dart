// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../../../data/repositories/contacts.dart';
import '../../utils.dart';
import '../../widgets/searchable_list.dart';
import 'cubit.dart';

class LinkToSystemContactPage extends StatefulWidget {
  const LinkToSystemContactPage({super.key, required this.coagContactId});

  final String coagContactId;

  @override
  _LinkToSystemContactPageState createState() =>
      _LinkToSystemContactPageState();
}

class _LinkToSystemContactPageState extends State<LinkToSystemContactPage> {
  @override
  Widget build(BuildContext context) => BlocProvider(
      create: (context) => LinkToSystemContactCubit(
          context.read<ContactsRepository>(), widget.coagContactId),
      child: BlocConsumer<LinkToSystemContactCubit, LinkToSystemContactState>(
          listener: (context, state) async {
            if (state.contact?.systemContactId != null) {
              return Navigator.of(context).pop();
            }
          },
          builder: (context, state) => Scaffold(
              appBar: AppBar(
                  // Avoid app bar background color changing when parts of the
                  // page scroll up
                  notificationPredicate: (notification) => false,
                  title: const Text('Sync to address book')),
              body: _body(context, state))));

  Widget _body(BuildContext context, LinkToSystemContactState state) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('You can synchronize contacts from Coagulate to your '
                  "phone's address book. The contact details from coagulate "
                  'then get a suffix like "phone [coagulate]" and will be '
                  'automatically kept up to date. You can still add or change '
                  'all other details of that contact in your address book as '
                  'usual.'),
            ),
            if (!state.permissionGranted)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: ElevatedButton(
                  onPressed: () async => context
                      .read<LinkToSystemContactCubit>()
                      .requestPermission(),
                  child: const Text('Grant address book access'),
                ),
              )
            else if (state.contact != null) ...[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: Row(children: [
                  if (state.accounts.length > 1)
                    Expanded(
                      child: DropdownMenu<Account>(
                        initialSelection: state.selectedAccount,
                        requestFocusOnTap: false,
                        inputDecorationTheme: const InputDecorationTheme(
                            border: OutlineInputBorder(), isDense: true),
                        label: const Text('Account'),
                        onSelected: context
                            .read<LinkToSystemContactCubit>()
                            .setSelectedAccount,
                        dropdownMenuEntries: state.accounts
                            .map((a) =>
                                DropdownMenuEntry(label: a.name, value: a))
                            .toList(),
                      ),
                    ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () async => context
                        .read<LinkToSystemContactCubit>()
                        .createNewSystemContact(
                          state.contact!.name,
                          account: state.selectedAccount,
                        ),
                    child: const Text('Add contact'),
                  ),
                ]),
              ),
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  alignment: Alignment.center,
                  child: const Text('or link to an existing contact')),
              const SizedBox(height: 16),
              Expanded(
                  child: SearchableList<Contact>(
                      items: state.contacts,
                      matchesItem: (search, contact) =>
                          jsonEncode(contact.toJson())
                              .toLowerCase()
                              .contains(search.toLowerCase()),
                      buildItemWidget: (contact) => ListTile(
                            leading: roundPictureOrPlaceholder(
                                contact.photoOrThumbnail,
                                radius: 18),
                            // TODO: Handle empty display name, can happen on iOS I think if only email or phone is provided
                            title: Text((contact.displayName.isNotEmpty)
                                ? contact.displayName
                                : contact.emails.firstOrNull?.address ??
                                    contact.phones.firstOrNull?.number ??
                                    '(no name)'),
                            onTap: () async => context
                                .read<LinkToSystemContactCubit>()
                                .linkExistingSystemContact(contact.id),
                            enabled: !context
                                .read<ContactsRepository>()
                                .getAllLinkedSystemContactIds()
                                .contains(contact.id),
                          ))),
            ],
          ],
        ),
      );
}
