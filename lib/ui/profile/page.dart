// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:io';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../../data/models/coag_contact.dart';
import '../../data/models/contact_location.dart';
import '../../data/repositories/contacts.dart';
import '../widgets/address_coordinates_form.dart';
import 'cubit.dart';

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
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
    child: SizedBox(
        child: Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ...emails.map((e) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: _label(e.label.name, e.customLabel)),
                        Padding(
                            padding: const EdgeInsets.only(top: 0),
                            child: Text(e.address,
                                style: const TextStyle(fontSize: 19)))
                      ])),
            ]))));

Widget phones(List<Phone> phones) => Card(
    color: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
    child: SizedBox(
        child: Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ...phones.map((e) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: _label(e.label.name, e.customLabel)),
                        Padding(
                            padding: const EdgeInsets.only(top: 0),
                            child: Text(e.number,
                                style: const TextStyle(fontSize: 19)))
                      ]))
            ]))));

Widget websites(List<Website> websites) => Card(
    color: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
    child: SizedBox(
        child: Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ...websites.map((e) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: _label(e.label.name, e.customLabel)),
                        Padding(
                            padding: const EdgeInsets.only(top: 0),
                            child: Text(e.url,
                                style: const TextStyle(fontSize: 19)))
                      ]))
            ]))));

String _commaToNewline(String s) =>
    s.replaceAll(', ', ',').replaceAll(',', '\n');

/// Potentially custom label for fields like email, phone, website
Text _label(String name, String customLabel) =>
    Text((name != 'custom') ? name : customLabel,
        style: const TextStyle(fontSize: 16, color: Colors.black54));

Widget addresses(BuildContext context, List<Address> addresses,
        List<AddressLocation> locations) =>
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
                                _label(e.label.name, e.customLabel),
                                Text(_commaToNewline(e.address),
                                    style: const TextStyle(fontSize: 19)),
                                // TODO: The usage of first below might result in exceptions
                                AddressCoordinatesForm(
                                    lng: locations
                                        .where((l) => l.name == e.label.name)
                                        .firstOrNull
                                        ?.longitude,
                                    lat: locations
                                        .where((l) => l.name == e.label.name)
                                        .firstOrNull
                                        ?.latitude,
                                    callback: (num lng, num lat) => context
                                        .read<ProfileCubit>()
                                        .updateCoordinates(
                                            e.label.name, lng, lat)),
                                TextButton(
                                    child: const Text('Auto Fetch Coordinates'),
                                    // TODO: Switch to address index instead of label? Can there be duplicates?
                                    onPressed: () async => showDialog<void>(
                                        context: context,
                                        // barrierDismissible: false,
                                        builder: (dialogContext) =>
                                            _confirmPrivacyLeakDialog(
                                                dialogContext,
                                                e.address,
                                                () => unawaited(context
                                                    .read<ProfileCubit>()
                                                    .fetchCoordinates(
                                                        e.label.name)))))
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

AlertDialog _confirmPrivacyLeakDialog(
        BuildContext context, String address, Function() addressLookup) =>
    AlertDialog(
        title: const Text('Potential Privacy Leak'),
        content: SingleChildScrollView(
            child: ListBody(children: <Widget>[
          // TODO: Show google / apple depending on which OS
          Text('Looking up the coordinates of "$address" automatically '
              'only works by sending that address to '
              '${(Platform.isIOS) ? 'Apple' : 'Google'}. '
              'Are you ok with leaking to them that you relate somehow '
              'to this address?'),
        ])),
        actions: <Widget>[
          // TODO: Store choice and don't ask again
          // Row(mainAxisSize: MainAxisSize.min, children: [
          //   Checkbox(value: false, onChanged: (v) => {}),
          //   const Text('remember')
          // ]),
          TextButton(
              child: const Text('Approve'),
              onPressed: () async {
                addressLookup();
                Navigator.of(context).pop();
              }),
          TextButton(
              child: const Text('Cancel'),
              onPressed: () async {
                Navigator.of(context).pop();
              })
        ]);

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider<ProfileCubit>(
        create: (context) => ProfileCubit(context.read<ContactsRepository>()),
        child: const ProfileView(),
      );
}

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  ProfileViewState createState() => ProfileViewState();
}

Widget buildProfileScrollView(BuildContext context, CoagContact contact) =>
    RefreshIndicator(
        onRefresh: () async =>
            context.read<ProfileCubit>().setContact(contact.systemContact?.id),
        child: CustomScrollView(slivers: [
          SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    header(contact.systemContact!),
                    if (contact.systemContact!.phones.isNotEmpty)
                      phones(contact.systemContact!.phones),
                    if (contact.systemContact!.emails.isNotEmpty)
                      emails(contact.systemContact!.emails),
                    if (contact.systemContact!.addresses.isNotEmpty)
                      addresses(
                          context,
                          contact.systemContact!.addresses,
                          contact.locations
                              .whereType<AddressLocation>()
                              .asList()),
                    if (contact.systemContact!.websites.isNotEmpty)
                      websites(contact.systemContact!.websites),
                  ]))
        ]));

class ProfileViewState extends State<ProfileView> {
  Widget _scaffoldBody(BuildContext context, ProfileState state) {
    switch (state.status) {
      case ProfileStatus.initial:
        return Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 28),
                child: const Text(
                    'Welcome to Coagulate. To start sharing your '
                    'contact details with others, create a new '
                    'profile or pick an existing contact that '
                    'contains your data from the address book.',
                    textScaler: TextScaler.linear(1.2))),
            TextButton(
                onPressed: context.read<ProfileCubit>().promptCreate,
                child: const Text('Create Profile',
                    textScaler: TextScaler.linear(1.2))),
            Container(
                padding: const EdgeInsets.all(8),
                child: const Text('or', textScaler: TextScaler.linear(1.2))),
            TextButton(
                onPressed: context.read<ProfileCubit>().promptPick,
                child: const Text('Pick Contact as Profile',
                    textScaler: TextScaler.linear(1.2))),
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
          child: buildProfileScrollView(context, state.profileContact!),
        );
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) =>
      BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) async {
            if (state.status.isPick) {
              if (await FlutterContacts.requestPermission()) {
                await context
                    .read<ProfileCubit>()
                    .setContact((await FlutterContacts.openExternalPick())?.id);
              } else {
                // TODO: Trigger hint about missing permission
                return;
              }
            } else if (state.status.isCreate) {
              if (await FlutterContacts.requestPermission()) {
                // TODO: This doesn't seem to return the contact after creation
                await context.read<ProfileCubit>().setContact(
                    (await FlutterContacts.openExternalInsert())?.id);
              } else {
                // TODO: Trigger hint about missing permission
                return;
              }
            }
          },
          builder: (context, state) => Scaffold(
              appBar: AppBar(
                title: const Text('My Profile'),
                // TODO: Add generate QR code for sharing with someone who I haven't as a contact yet
                // TODO: Add update action; use system update view
                actions: [
                  // IconButton(
                  //   icon: const Icon(Icons.add_task_rounded),
                  //   onPressed: () {
                  //     // TODO: Manage profile sharing settings
                  //   },
                  // ),
                  if (state.status == ProfileStatus.success &&
                      state.profileContact?.systemContact?.id != null)
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async => FlutterContacts.openExternalEdit(
                              state.profileContact!.systemContact!.id)
                          .then((contact) => context
                              .read<ProfileCubit>()
                              .setContact(
                                  state.profileContact!.systemContact!.id)),
                    ),
                  if (state.status == ProfileStatus.success)
                    IconButton(
                      icon: const Icon(Icons.cancel_outlined),
                      onPressed: () async =>
                          context.read<ProfileCubit>().setContact(null),
                    ),
                ],
              ),
              body: _scaffoldBody(context, state)));
}
