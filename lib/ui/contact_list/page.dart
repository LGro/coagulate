// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../../data/models/coag_contact.dart';
import '../../data/repositories/contacts.dart';
import '../../ui/profile/cubit.dart';
import '../../utils.dart';
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
                            child: Column(children: [
                              _searchBar(context, state),
                              const SizedBox(height: 10),
                              Expanded(
                                  child: _body(
                                      state.contacts
                                          .where((c) =>
                                              c.coagContactId !=
                                              profileContactState.profileContact
                                                  ?.coagContactId)
                                          .toList(),
                                      state.circleMemberships))
                            ])));
                }
              })));

  Widget _searchBar(BuildContext context, ContactListState state) =>
      Row(children: [
        Expanded(
            child: TextField(
          onChanged: context.read<ContactListCubit>().filter,
          autocorrect: false,
          decoration: InputDecoration(
              labelText: 'Search',
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
            TextButton(
                onPressed: context.read<ContactListCubit>().unselectCircle,
                child: Text('Circle: ${state.circles[state.selectedCircle]}'))
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
                                  OutlinedButton(
                                      onPressed: () {
                                        context
                                            .read<ContactListCubit>()
                                            .selectCircle(circle.key);
                                        Navigator.pop(context);
                                      },
                                      child: Text(circle.value))
                              ])
                            ]))),
                icon: const Icon(Icons.circle_outlined))
      ]);

  Widget _body(List<CoagContact> contacts,
          Map<String, List<String>> circleMemberships) =>
      ListView.builder(
          itemCount: contacts.length,
          itemBuilder: (context, i) {
            final contact = contacts[i];
            return ListTile(
                leading: avatar(contact.systemContact, radius: 18),
                title: Text(displayName(contact) ?? 'unknown'),
                trailing: Text(contactSharingReceivingStatus(
                    contact,
                    circleMemberships[contact.coagContactId]?.isNotEmpty ??
                        false)),
                onTap: () =>
                    Navigator.of(context).push(ContactPage.route(contact)));
          });
}

String contactSharingReceivingStatus(
    CoagContact contact, bool isMemberAnyCircle) {
  var status = '';
  if (contact.dhtSettingsForSharing != null && isMemberAnyCircle) {
    status = 'S';
  }
  if (contact.details != null) {
    status = 'R$status';
  }
  return status;
}
