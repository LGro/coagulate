// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../../data/models/coag_contact.dart';
import '../../data/repositories/contacts.dart';
import '../../ui/profile/cubit.dart';
import '../contact_details/page.dart';
import '../receive_request/page.dart';
import '../widgets/avatar.dart';
import 'cubit.dart';

class ContactListPage extends StatefulWidget {
  const ContactListPage({super.key});

  @override
  _ContactListPageState createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        actions: [
          IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute<ReceiveRequestPage>(
                        builder: (_) => const ReceiveRequestPage()));
              }),
        ],
      ),
      body: MultiBlocProvider(
          providers: [
            BlocProvider(
                create: (context) =>
                    ContactListCubit(context.read<ContactsRepository>())),
            BlocProvider(
                create: (context) =>
                    ProfileCubit(context.read<ContactsRepository>())),
          ],
          child: BlocConsumer<ContactListCubit, ContactListState>(
              listener: (context, state) async {},
              builder: (context, state) {
                switch (state.status) {
                  // TODO: This is barely ever shown, remove
                  case ContactListStatus.initial:
                    return const Center(child: CircularProgressIndicator());
                  // TODO: This is never shown; but we want to see it at least when e.g. the contact list is empty
                  case ContactListStatus.denied:
                    return const Center(
                        child: TextButton(
                            onPressed: FlutterContacts.requestPermission,
                            child: Text('Grant access to contacts')));
                  case ContactListStatus.success:
                    return BlocConsumer<ProfileCubit, ProfileState>(
                        listener: (_, __) async {},
                        builder: (_, profileContactState) => Container(
                            padding: const EdgeInsets.all(10),
                            child: Column(children: <Widget>[
                              TextField(
                                onChanged:
                                    context.read<ContactListCubit>().filter,
                                autocorrect: false,
                                decoration: const InputDecoration(
                                    labelText: 'Search',
                                    prefixIcon: Icon(Icons.search),
                                    border: OutlineInputBorder()),
                              ),
                              const SizedBox(height: 10),
                              Expanded(
                                  child: _body(state.contacts
                                      .where((c) =>
                                          c.coagContactId !=
                                          profileContactState
                                              .profileContact?.coagContactId)
                                      .toList()))
                            ])));
                }
              })));

  Widget _body(List<CoagContact> contacts) => ListView.builder(
      itemCount: contacts.length,
      itemBuilder: (context, i) {
        final contact = contacts[i];
        return ListTile(
            leading: avatar(contact.systemContact, radius: 18),
            title: Text(contact.details?.displayName ??
                contact.systemContact?.displayName ??
                'unknown'),
            trailing: Text(_contactSyncStatus(contact)),
            onTap: () =>
                Navigator.of(context).push(ContactPage.route(contact)));
      });
}

String _contactSyncStatus(CoagContact contact) {
  var status = '';
  if (contact.dhtSettingsForSharing != null) {
    status = 'S';
  }
  if (contact.dhtSettingsForReceiving != null) {
    status = 'R$status';
  }
  if (status.isEmpty) {
    status = '?';
  }
  return status;
}
