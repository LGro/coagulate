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

class ProfileViewState extends State<ProfileView> {
  static const _textStyle = TextStyle(fontSize: 19);

  Widget _buildProfileScrollView(Contact contact) => CustomScrollView(slivers: [
        SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                      margin: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 20),
                      child: SizedBox(
                          child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(children: [
                                Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: avatar(contact)),
                                Text(
                                  contact.displayName,
                                  style: _textStyle,
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
                                      style: _textStyle))
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
                                      style: _textStyle))
                                ])))),
                  if (contact.addresses.isNotEmpty)
                    Card(
                        margin: const EdgeInsets.all(20.0),
                        child: SizedBox(
                            child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(children: [
                                  const Icon(Icons.home),
                                  ...contact.addresses.map((e) => Text(
                                      '${e.label.name.toUpperFirstCase()}: ${e.address}',
                                      style: _textStyle))
                                ])))),
                ]))
      ]);

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
            if (state.status.isUnavailable) {
              if (await FlutterContacts.requestPermission()) {
                context
                    .read<ProfileContactCubit>()
                    .setContact(await FlutterContacts.openExternalPick());
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
                            context.read<ProfileContactCubit>().updateContact,
                        child: const Text('Pick Profile Contact')),
                    // TODO: Add possibility to create contact in case the user does not have themselves as a contact
                    // TextButton(
                    //     onPressed: () => {},
                    //     child: const Text('Create Profile Contact')),
                  ]),
                );
              case ProfileContactStatus.loading:
                return const Center(
                  child: CircularProgressIndicator(),
                );
              case ProfileContactStatus.unavailable:
                return const Center(
                  child: CircularProgressIndicator(),
                );
              case ProfileContactStatus.success:
                return Center(
                  child: _buildProfileScrollView(state.profileContact!),
                );
            }
          }));
}
