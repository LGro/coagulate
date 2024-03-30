// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../../cubit/profile_cubit.dart';
import '../widgets/address_coordinates_form.dart';

Widget avatar(Contact contact,
    [double radius = 48.0, IconData defaultIcon = Icons.person]) {
  if (contact.photoOrThumbnail != null) {
    return CircleAvatar(
      backgroundImage: MemoryImage(contact.photoOrThumbnail!),
      radius: radius,
    );
  }
  return CircleAvatar(
    radius: radius,
    child: Icon(defaultIcon),
  );
}

Widget emails(List<Email> emails) => Card(
    color: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
    child: SizedBox(
        child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ...emails.map((e) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.label.name,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black54)),
                        Text(e.address, style: const TextStyle(fontSize: 19))
                      ])),
            ]))));

Widget phones(List<Phone> phones) => Card(
    color: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
    child: SizedBox(
        child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ...phones.map((e) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.label.name,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black54)),
                        Text(e.number, style: const TextStyle(fontSize: 19))
                      ]))
            ]))));

String _commaToNewline(String s) =>
    s.replaceAll(', ', ',').replaceAll(',', '\n');

Widget addresses(BuildContext context, List<Address> addresses,
        Map<String, (num, num)>? locationCoordinates) =>
    Card(
        color: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
        child: SizedBox(
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...addresses.map((e) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    (e.label.name != 'custom')
                                        ? e.label.name
                                        : e.customLabel,
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.black54)),
                                Text(_commaToNewline(e.address),
                                    style: const TextStyle(fontSize: 19)),
                                AddressCoordinatesForm(
                                    lng: locationCoordinates?[e.label.name]?.$1,
                                    lat: locationCoordinates?[e.label.name]?.$2,
                                    callback: (num lng, num lat) => context
                                        .read<ProfileCubit>()
                                        .updateCoordinates(
                                            e.label.name, lng, lat)),
                                TextButton(
                                    child: const Text('Auto Fetch Coordinates'),
                                    // TODO: Switch to address index instead of label? Can there be duplicates?
                                    onPressed: () async => context
                                        .read<ProfileCubit>()
                                        .fetchCoordinates(e.label.name))
                              ]))
                    ]))));

Widget header(Contact contact) => Card(
    color: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
    child: SizedBox(
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: avatar(contact)),
              Text(
                contact.displayName,
                style: const TextStyle(fontSize: 19),
              ),
            ]))));

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => ProfileCubit(),
        child: ProfileView(),
      );
}

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  ProfileViewState createState() => ProfileViewState();
}

Widget buildProfileScrollView(BuildContext context, Contact contact,
        Map<String, (num, num)>? locationCoordinates) =>
    CustomScrollView(slivers: [
      SliverFillRemaining(
          hasScrollBody: false,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            header(contact),
            if (contact.phones.isNotEmpty) phones(contact.phones),
            if (contact.emails.isNotEmpty) emails(contact.emails),
            if (contact.addresses.isNotEmpty)
              addresses(context, contact.addresses, locationCoordinates),
            // if (contact.websites.isNotEmpty) websites(contact.websites), #2
          ]))
    ]);

class ProfileViewState extends State<ProfileView> {
  @override
  Widget build(
    BuildContext context,
  ) =>
      Scaffold(
          appBar: AppBar(
            title: const Text('My Profile'),
            // TODO: Add update action; use system update view
            actions: [
              IconButton(
                icon: const Icon(Icons.add_task_rounded),
                onPressed: () {
                  // TODO: Manage profile sharing settings
                },
              ),
              IconButton(
                icon: const Icon(Icons.replay_outlined),
                onPressed: () {
                  context.read<ProfileCubit>().setContact(null);
                },
              ),
            ],
          ),
          body: BlocConsumer<ProfileCubit, ProfileState>(
              listener: (context, state) async {
            if (state.status.isPick) {
              if (await FlutterContacts.requestPermission()) {
                context
                    .read<ProfileCubit>()
                    .setContact(await FlutterContacts.openExternalPick());
              } else {
                // TODO: Trigger hint about missing permission
                return;
              }
            } else if (state.status.isCreate) {
              if (await FlutterContacts.requestPermission()) {
                // TODO: This doesn't seem to return the contact after creation
                context
                    .read<ProfileCubit>()
                    .setContact(await FlutterContacts.openExternalInsert());
              } else {
                // TODO: Trigger hint about missing permission
                return;
              }
            }
          }, builder: (context, state) {
            switch (state.status) {
              case ProfileStatus.initial:
                return Center(
                  child: Column(children: [
                    TextButton(
                        onPressed: context.read<ProfileCubit>().promptPick,
                        child: const Text('Pick Profile Contact')),
                    TextButton(
                        onPressed: context.read<ProfileCubit>().promptCreate,
                        child: const Text('Create Profile Contact')),
                  ]),
                );
              case ProfileStatus.create:
                return const Center(
                  child: CircularProgressIndicator(),
                );
              case ProfileStatus.pick:
                return const Center(
                  child: CircularProgressIndicator(),
                );
              case ProfileStatus.success:
                return Center(
                  child: buildProfileScrollView(context, state.profileContact!,
                      state.locationCoordinates),
                );
            }
          }));
}
