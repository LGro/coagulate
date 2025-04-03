// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';

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
              // pop, go back to details
            }
            if (state.permissionGranted) {
              await context
                  .read<LinkToSystemContactCubit>()
                  .loadSystemContacts();
            }
          },
          builder: (context, state) => Scaffold(
                appBar: AppBar(title: const Text('Sync to address book')),
                body: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                          'You can synchronize contacts from Coagulate to your '
                          "phone's address book. The contact details from "
                          'coagulate then get a suffix like '
                          '"phone [coagulate]" and will be automatically kept '
                          'up to date. You can still add or change all other '
                          'details of that contact in your address book as '
                          'usual.'),
                      const SizedBox(height: 16),
                      if (!state.permissionGranted)
                        ElevatedButton(
                          onPressed: () async => context
                              .read<LinkToSystemContactCubit>()
                              .requestPermission(),
                          child: const Text('Grant address book access'),
                        )
                      else
                        Column(
                          children: [
                            ElevatedButton(
                              onPressed: () async => context
                                  .read<LinkToSystemContactCubit>()
                                  .createNewSystemContact,
                              child: const Text('Add as new contact'),
                            ),
                            SearchableList<Contact>(
                                items: state.contacts,
                                matchesItem: (search, contact) =>
                                    jsonEncode(contact.toJson())
                                        .contains(search),
                                buildItemWidget: (contact) => ListTile(
                                      leading: roundPictureOrPlaceholder(
                                          contact.photoOrThumbnail),
                                      // TODO: Handle empty display name, can happen on iOS I think if only email or phone is provided
                                      title: Text(contact.displayName),
                                    )),
                          ],
                        ),
                    ],
                  ),
                ),
              )));
}
