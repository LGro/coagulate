// Copyright 2024 Lukas Grossberger
import 'package:change_case/change_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import 'cubit/profile_contact_cubit.dart';

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

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => ProfileContactCubit(),
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
            Card(
                margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: SizedBox(
                    child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(children: [
                          Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: avatar(contact)),
                          Text(
                            contact.displayName,
                            style: TextStyle(fontSize: 19),
                          ),
                        ])))),
            if (contact.phones.isNotEmpty)
              Card(
                  margin: const EdgeInsets.all(20.0),
                  child: SizedBox(
                      child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(children: [
                            const Icon(Icons.phone),
                            ...contact.phones.map((e) => Text(
                                '${e.label.name.toUpperFirstCase()}: ${e.number}',
                                style: TextStyle(fontSize: 19)))
                          ])))),
            if (contact.emails.isNotEmpty)
              Card(
                  margin: const EdgeInsets.all(20.0),
                  child: SizedBox(
                      child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(children: [
                            const Icon(Icons.email),
                            ...contact.emails.map((e) => Text(
                                '${e.label.name.toUpperFirstCase()}: ${e.address}',
                                style: TextStyle(fontSize: 19)))
                          ])))),
            if (contact.addresses.isNotEmpty)
              Card(
                  margin: const EdgeInsets.all(20.0),
                  child: SizedBox(
                      child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(children: [
                            const Icon(Icons.home),
                            ...contact.addresses.map((e) => Column(children: [
                                  Text(
                                      '${e.label.name.toUpperFirstCase()}: ${e.address}',
                                      style: TextStyle(fontSize: 19)),
                                  const Text(
                                      "Coordinates to appear on others' map:"),
                                  Row(
                                    children: [
                                      SizedBox(
                                          width: 100,
                                          child: TextField(
                                              controller: TextEditingController(
                                                  text: (locationCoordinates !=
                                                              null &&
                                                          locationCoordinates
                                                              .containsKey(
                                                                  e.label))
                                                      ? '${locationCoordinates[e.label.toString()]}'
                                                      : ''),
                                              obscureText: true,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: 'Lng',
                                              ))),
                                      SizedBox(
                                          width: 100,
                                          child: TextField(
                                              controller: TextEditingController(
                                                  text: (locationCoordinates !=
                                                              null &&
                                                          locationCoordinates
                                                              .containsKey(e
                                                                  .label
                                                                  .toString()))
                                                      ? '${locationCoordinates[e.label.toString()]}'
                                                      : ''),
                                              obscureText: true,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: 'Lat',
                                              ))),
                                      TextButton(
                                          // TODO: Handle update
                                          onPressed: null,
                                          child: Text('Update'))
                                    ],
                                  ),
                                  TextButton(
                                      child:
                                          const Text('Auto Fetch Coordinates'),
                                      // TODO: Switch to address index instead of label?
                                      //       Can there be duplicates?
                                      onPressed: () => context
                                          .read<ProfileContactCubit>()
                                          .fetchCoordinates(e.label.name))
                                ]))
                          ])))),
          ]))
    ]);

class ProfileViewState extends State<ProfileView> {
  @override
  Widget build(
    BuildContext context,
  ) =>
      Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            // TODO: Add update action; use system update view
            actions: [
              IconButton(
                icon: const Icon(Icons.replay_outlined),
                onPressed: () {
                  context.read<ProfileContactCubit>().setContact(null);
                },
              ),
            ],
          ),
          body: BlocConsumer<ProfileContactCubit, ProfileContactState>(
              listener: (context, state) async {
            if (state.status.isPick) {
              if (await FlutterContacts.requestPermission()) {
                context
                    .read<ProfileContactCubit>()
                    .setContact(await FlutterContacts.openExternalPick());
              } else {
                // TODO: Trigger hint about missing permission
                return;
              }
            } else if (state.status.isCreate) {
              if (await FlutterContacts.requestPermission()) {
                // TODO: This doesn't seem to return the contact after creation
                context
                    .read<ProfileContactCubit>()
                    .setContact(await FlutterContacts.openExternalInsert());
              } else {
                // TODO: Trigger hint about missing permission
                return;
              }
            }
          }, builder: (context, state) {
            switch (state.status) {
              case ProfileContactStatus.initial:
                return Center(
                  child: Column(children: [
                    TextButton(
                        onPressed:
                            context.read<ProfileContactCubit>().promptPick,
                        child: const Text('Pick Profile Contact')),
                    TextButton(
                        onPressed:
                            context.read<ProfileContactCubit>().promptCreate,
                        child: const Text('Create Profile Contact')),
                  ]),
                );
              case ProfileContactStatus.create:
                return const Center(
                  child: CircularProgressIndicator(),
                );
              case ProfileContactStatus.pick:
                return const Center(
                  child: CircularProgressIndicator(),
                );
              case ProfileContactStatus.success:
                return Center(
                  child: buildProfileScrollView(context, state.profileContact!,
                      state.locationCoordinates),
                );
            }
          }));
}
