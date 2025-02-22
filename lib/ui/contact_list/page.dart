// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:veilid/veilid.dart';

import '../../data/models/coag_contact.dart';
import '../../data/repositories/contacts.dart';
import '../contact_details/page.dart';
import '../create_new_contact/page.dart';
import '../receive_request/page.dart';
import '../widgets/dht_sharing_status/widget.dart';
import 'cubit.dart';

class ContactListPage extends StatefulWidget {
  const ContactListPage({super.key});

  @override
  _ContactListPageState createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  Widget _noContactsBody() => Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Column(children: [
        const SizedBox(height: 8),
        const Text('Add your first contact.',
            textScaler: TextScaler.linear(1.4)),
        const SizedBox(height: 24),
        const Text('Invite someone', textScaler: TextScaler.linear(1.2)),
        const SizedBox(height: 8),
        Center(
            child: FilledButton(
                child: const Text('Create invite'),
                onPressed: () async {
                  await Navigator.of(context).push(
                      MaterialPageRoute<CreateNewContactPage>(
                          builder: (_) => CreateNewContactPage()));
                })),
        const SizedBox(height: 8),
        const Text('or accept an invite you received',
            textScaler: TextScaler.linear(1.2)),
        const SizedBox(height: 8),
        Center(
            child: FilledButton(
                child: const Text('Accept invite'),
                onPressed: () async {
                  await Navigator.of(context).push(
                      MaterialPageRoute<ReceiveRequestPage>(
                          builder: (_) => ReceiveRequestPage()));
                })),
      ]));

  Widget _contactsBody(BuildContext context, ContactListState state) =>
      Column(children: [
        _searchBar(context, state),
        const SizedBox(height: 10),
        Expanded(
            child: _body(state.contacts.toList(), state.circleMemberships)),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          FilledButton(
              child: const Text('Create invite'),
              onPressed: () async {
                await Navigator.of(context).push(
                    MaterialPageRoute<CreateNewContactPage>(
                        builder: (_) => CreateNewContactPage()));
              }),
          FilledButton(
              child: const Text('Accept invite'),
              onPressed: () async {
                await Navigator.of(context).push(
                    MaterialPageRoute<ReceiveRequestPage>(
                        builder: (_) => ReceiveRequestPage()));
              }),
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          DhtSharingStatusWidget(
              recordKeys: state.contacts
                  .map((c) => c.dhtSettings.recordKeyMeSharing)
                  .whereType<Typed<FixedEncodedString43>>())
        ]),
      ]);

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Contacts')),
      body: MultiBlocProvider(
          providers: [
            BlocProvider(
                create: (context) =>
                    ContactListCubit(context.read<ContactsRepository>())),
          ],
          child: BlocConsumer<ContactListCubit, ContactListState>(
              listener: (context, state) async {},
              builder: (context, state) => Container(
                  padding: const EdgeInsets.all(10),
                  child: (state.contacts.isEmpty)
                      ? _noContactsBody()
                      : _contactsBody(context, state)))));

  Widget _searchBar(BuildContext context, ContactListState state) =>
      Row(children: [
        Expanded(
            child: TextField(
          onChanged: context.read<ContactListCubit>().filter,
          autocorrect: false,
          decoration: InputDecoration(
              labelText: 'Search',
              isDense: true,
              prefixIcon: const Icon(Icons.search),
              // TODO: Clear the actual text as well
              suffixIcon: IconButton(
                onPressed: () async =>
                    context.read<ContactListCubit>().filter(''),
                icon: const Icon(Icons.clear),
              ),
              border: const OutlineInputBorder()),
        )),
        if (state.circleMemberships.values.expand((c) => c).isNotEmpty)
          if (state.selectedCircle != null)
            ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 100),
                child: TextButton(
                    onPressed: context.read<ContactListCubit>().unselectCircle,
                    child: Text(
                      'Circle: ${state.circles[state.selectedCircle]}',
                      overflow: TextOverflow.ellipsis,
                    )))
          else
            IconButton(
                onPressed: () async => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (modalContext) => Padding(
                        padding: EdgeInsets.only(
                            left: 24,
                            top: 24,
                            right: 24,
                            bottom: 16 +
                                MediaQuery.of(modalContext).viewInsets.bottom),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Only display contacts from circle:',
                                  textScaler: TextScaler.linear(1.2)),
                              const SizedBox(height: 16),
                              Wrap(spacing: 8, runSpacing: 6, children: [
                                for (final circle in state.circles.entries)
                                  if (state.circleMemberships.values
                                      .expand((c) => c)
                                      .contains(circle.key))
                                    OutlinedButton(
                                        onPressed: () {
                                          context
                                              .read<ContactListCubit>()
                                              .selectCircle(circle.key);
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                            '${circle.value} (${state.circleMemberships.values.where((ids) => ids.contains(circle.key)).length})'))
                              ])
                            ]))),
                icon: const Icon(Icons.bubble_chart))
      ]);

  Widget _body(List<CoagContact> contacts,
          Map<String, List<String>> circleMemberships) =>
      ListView.builder(
          itemCount: contacts.length,
          itemBuilder: (context, i) {
            final contact = contacts[i];
            return ListTile(
                leading: (contact.details?.picture == null)
                    ? const CircleAvatar(radius: 18, child: Icon(Icons.person))
                    : CircleAvatar(
                        backgroundImage: MemoryImage(
                            Uint8List.fromList(contact.details!.picture!)),
                        radius: 18,
                      ),
                title: Text(contact.name),
                trailing: contactSharingReceivingStatus(
                    contact,
                    circleMemberships[contact.coagContactId]?.isNotEmpty ??
                        false),
                onTap: () async =>
                    Navigator.of(context).push(ContactPage.route(contact)));
          });
}

Widget? contactSharingReceivingStatus(
    CoagContact contact, bool isMemberAnyCircle) {
  // Me and them are sharing
  if (contact.dhtSettings.theyAckHandshakeComplete) {
    return const Icon(Icons.done_all);
  }
  // I'm sharing but they aren't sharing back
  if (contact.dhtSettings.recordKeyMeSharing != null &&
      contact.dhtSettings.theirPublicKey == null) {
    return const Icon(Icons.call_made);
  }
  // They're sharing but I'm not sharing back
  if (contact.dhtSettings.theirPublicKey != null && !isMemberAnyCircle) {
    return const Icon(Icons.call_received);
  }
  // We're both sharing, but haven't received the ack
  if (contact.dhtSettings.recordKeyMeSharing != null &&
      contact.dhtSettings.recordKeyThemSharing != null) {
    // TODO: Use Icons.done to differentiate from full handshake DH switch?
    return const Icon(Icons.done_all);
  }
  return null;
}
