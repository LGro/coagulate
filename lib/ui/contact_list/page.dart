// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../../cubit/contacts_cubit.dart';
import '../../data/repositories/contacts.dart';
import '../../data/models/coag_contact.dart';
import '../widgets/scan_qr_code.dart';
import '../contact_details/page.dart';

Widget avatar(Contact contact,
    [double radius = 48.0, IconData defaultIcon = Icons.person]) {
  if (contact.photoOrThumbnail != null) {
    return CircleAvatar(
      backgroundImage: MemoryImage(contact.photoOrThumbnail!),
      radius: radius,
    );
  }
  return CircleAvatar(radius: radius, child: Icon(defaultIcon));
}

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
                    MaterialPageRoute(
                        builder: (_) => const BarcodeScannerPageView()));
              }),
        ],
      ),
      body: BlocProvider(
          create: (context) =>
              CoagContactCubit(context.read<ContactsRepository>()),
          child: BlocConsumer<CoagContactCubit, CoagContactState>(
              listener: (context, state) async {},
              builder: (context, state) {
                switch (state.status) {
                  case CoagContactStatus.initial:
                    return const Center(child: CircularProgressIndicator());
                  case CoagContactStatus.denied:
                    return const Center(
                        child: TextButton(
                            onPressed: FlutterContacts.requestPermission,
                            child: Text('Grant access to contacts')));
                  case CoagContactStatus.success:
                    // TODO: Figure out sorting
                    return _body(state.contacts.values
                        .where((cc) => cc.details != null)
                        .toList());
                }
              })));

  // TODO: This currently assumes that only contacts with details are passed, make this less implicit
  Widget _body(List<CoagContact> contacts) => ListView.builder(
      itemCount: contacts.length,
      itemBuilder: (context, i) {
        final contact = contacts[i];
        return ListTile(
            leading: avatar(contact.details!, 18),
            title: Text(contact.details!.displayName),
            trailing: Text(contact.dhtSettings == null ? '?' : 'C'),
            onTap: () => Navigator.of(context)
                .push(ContactPage.route(contact.coagContactId)));
      });
}
