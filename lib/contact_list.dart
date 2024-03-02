// Copyright 2024 Lukas Grossberger
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import 'contact_page.dart';
import 'cubit/contacts_cubit.dart';

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
      ),
      body: BlocProvider(
          create: (context) => CoagContactCubit()..refreshContactsFromSystem(),
          child: BlocConsumer<CoagContactCubit, CoagContactState>(
              listener: (context, state) async {},
              builder: (context, state) {
                // TODO: Is  this in the right place, here?
                FlutterContacts.addListener(
                    context.read<CoagContactCubit>().refreshContactsFromSystem);
                switch (state.status) {
                  case CoagContactStatus.initial:
                    return const Center(child: CircularProgressIndicator());
                  case CoagContactStatus.denied:
                    return Center(
                        child: TextButton(
                            onPressed: context
                                .read<CoagContactCubit>()
                                .refreshContactsFromSystem,
                            child: const Text('Grant access to contacts')));
                  case CoagContactStatus.success:
                    // TODO: Figure out sorting
                    return _body(state.contacts.values.toList());
                }
              })));

  Widget _body(List<CoagContact> contacts) => ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, i) {
          final contact = contacts[i];
          return ListTile(
            leading: avatar(contact.contact, 18),
            title: Text(contact.contact.displayName),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ContactPage(contactId: contact.contact.id),
                ),
              );
            },
          );
        },
      );
}
