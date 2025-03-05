// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:veilid/veilid.dart';

import '../../data/models/coag_contact.dart';
import '../../data/repositories/contacts.dart';
import '../contact_details/page.dart';
import '../create_new_contact/page.dart';
import '../receive_request/page.dart';
import '../updates/page.dart';
import '../utils.dart';
import '../widgets/dht_sharing_status/widget.dart';
import '../widgets/searchable_list.dart';
import 'cubit.dart';

Widget contactsListView(BuildContext context, List<CoagContact> contacts,
        Map<String, List<String>> circleMemberships) =>
    SearchableList<CoagContact>(
        items: contacts,
        buildItemWidget: (contact) => ListTile(
            leading:
                roundPictureOrPlaceholder(contact.details?.picture, radius: 18),
            title: Text(contact.name),
            trailing: contactSharingReceivingStatus(contact,
                circleMemberships[contact.coagContactId]?.isNotEmpty ?? false),
            onTap: () async =>
                Navigator.of(context).push(ContactPage.route(contact))),
        // TODO: Also allow searching shared locations?
        matchesItem: (search, contact) =>
            contact.name.toLowerCase().contains(search.toLowerCase()) ||
            (contact.details != null &&
                extractAllValuesToString(contact.details!.toJson())
                    .toLowerCase()
                    .contains(search.toLowerCase())));

class ContactListPage extends StatefulWidget {
  const ContactListPage({super.key});

  @override
  _ContactListPageState createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  Widget _noContactsBody() => Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Column(children: [
        const Expanded(
          child: Row(children: [
            Expanded(
                child: Text(
              'You do not have any contacts yet. Create an invite for someone, '
              'or accept an invite from someone else.',
              textScaler: TextScaler.linear(1.2),
            ))
          ]),
        ),
        const SizedBox(height: 24),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          FilledButton(
              child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // This could be qr_code_2_add if available, is that better?
                    Icon(Icons.person_add),
                    SizedBox(width: 8),
                    Text('Create invite'),
                  ]),
              onPressed: () async {
                await Navigator.of(context).push(
                    MaterialPageRoute<CreateNewContactPage>(
                        builder: (_) => CreateNewContactPage()));
              }),
          FilledButton(
              child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_scanner),
                    SizedBox(width: 8),
                    Text('Accept invite'),
                  ]),
              onPressed: () async {
                await Navigator.of(context).push(
                    MaterialPageRoute<ReceiveRequestPage>(
                        builder: (_) => ReceiveRequestPage()));
              }),
        ]),
      ]));

  Widget _contactsBody(BuildContext context, ContactListState state) =>
      Column(children: [
        Expanded(
            child: contactsListView(
                context, state.contacts.toList(), state.circleMemberships)),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          FilledButton(
              child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // This could be qr_code_2_add if available, is that better?
                    Icon(Icons.person_add),
                    SizedBox(width: 8),
                    Text('Create invite'),
                  ]),
              onPressed: () async {
                await Navigator.of(context).push(
                    MaterialPageRoute<CreateNewContactPage>(
                        builder: (_) => CreateNewContactPage()));
              }),
          FilledButton(
              child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_scanner),
                    SizedBox(width: 8),
                    Text('Accept invite'),
                  ]),
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

  var _dummyToTriggerRebuild = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Trigger a rebuild to make sure that when we edited the name of a contact
    // it shows up in the list up-to-date
    setState(() {
      _dummyToTriggerRebuild = _dummyToTriggerRebuild + 1;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Contacts'), actions: [
        // Notifications -> show updates page
        // TODO: Only show when there are updates?
        IconButton(
            onPressed: () async => Navigator.of(context).push(
                MaterialPageRoute<ContactPage>(
                    builder: (context) => const UpdatesPage())),
            icon: const Icon(Icons.notifications))
      ]),
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
                      // TODO: Add pull to refresh?
                      : RefreshIndicator(
                          onRefresh: () async => context
                              .read<ContactListCubit>()
                              .refresh()
                              .then((success) => context.mounted
                                  ? (success
                                      ? ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'Successfully refreshed!')))
                                      : ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                          content: Text(
                                              'Refreshing failed, try again later!'),
                                        )))
                                  : null),
                          child: _contactsBody(context, state))))));
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
  if (contact.dhtSettings.theirPublicKey != null) {
    return const Icon(Icons.hourglass_empty);
  }
  return const Icon(Icons.question_mark);
}
