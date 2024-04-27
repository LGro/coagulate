// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/coag_contact.dart';
import '../../data/repositories/contacts.dart';
import '../../ui/profile/cubit.dart';
import '../profile/page.dart';
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

List<Widget> _withSpacing(List<Widget> widgets) {
  final spacer = SizedBox(height: 8);
  return <Widget>[spacer] +
      widgets.map((p) => [p, spacer]).expand((p) => p).toList();
}

Card _makeCard(
    String title, List fields, List<Widget> Function(dynamic) mapper) {
  var elements = <Widget>[];
  fields.forEach((field) => elements.addAll(mapper(field)));
  return Card(
      child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _withSpacing(<Widget>[
                  Text(title, style: TextStyle(fontSize: 22)),
                ] +
                elements),
          )));
}

Uri _shareURL(ContactDHTSettings settings) => Uri(
    scheme: 'https',
    host: 'coagulate.social',
    // TODO: Make language dependent on local language setting?
    path: 'en/c',
    fragment: '${settings.key}:${settings.psk}');

Widget _coagulateButton(
    BuildContext context, CoagContact contact, CoagContact myProfile) {
  if (contact.sharedProfile == null || contact.sharedProfile!.isEmpty) {
    return TextButton(
        onPressed: () async =>
            {context.read<ContactDetailsCubit>().share(myProfile)},
        child: const Text('Coagulate'));
  } else {
    return TextButton(
        onPressed: context.read<ContactDetailsCubit>().unshare,
        child: const Text('Dissolve'));
  }
}

class ContactPage extends StatelessWidget {
  const ContactPage({super.key, required this.coagContactId});

  final String coagContactId;

  static Route<void> route(CoagContact contact) => MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => ContactPage(coagContactId: contact.coagContactId));

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
          providers: [
            BlocProvider(
                create: (context) => ContactDetailsCubit(
                    context.read<ContactsRepository>(), coagContactId)),
            BlocProvider(
                create: (context) =>
                    ProfileCubit(context.read<ContactsRepository>())),
          ],
          child: BlocConsumer<ContactDetailsCubit, ContactDetailsState>(
              listener: (context, state) async {},
              builder: (context, state) => Scaffold(
                  appBar: AppBar(
                    title: Text(state.contact!.details!.displayName),
                  ),
                  body: _body(context, state.contact))));

  Widget _body(BuildContext context, CoagContact? contact) {
    if (contact?.details?.name == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const SizedBox(height: 40),
      if (contact!.systemContact != null)
        Center(child: avatar(contact.systemContact!)),
      BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) async {},
          builder: (context, state) {
            if (state.profileContact == null) {
              return const Card(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero),
                  margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                  child: Padding(
                      padding: EdgeInsets.all(16),
                      child:
                          Text('Pick a profile contact, then you can share.')));
            } else {
              return Card(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero),
                  margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                  child: Center(
                      child: _coagulateButton(
                          context,
                          contact,
                          // TODO: Make my profile a first class citizen coag contact?
                          CoagContact(
                              coagContactId: Uuid().v4(),
                              systemContact:
                                  state.profileContact?.systemContact))));
            }
          }),

      // TODO: Display name(s)
      // TODO: Display merged view of contact details, where
      // if a matching name with the same value is present
      //   - show entry with managed or unmanaged indicator
      // if a matching name with a different value is present
      //   - if managed, override, collapse to same
      //   - if not managed, display side by side, show option to enable dht management
      // if no matching name and value is present
      //   - add as new entry to system contact, mark managed
      // if no matching name but matching value is present, think about displaying them next to each other still
      if (contact.systemContact != null &&
          contact.systemContact!.phones.isNotEmpty)
        phones(contact.systemContact!.phones),
      if (contact.details!.phones.isNotEmpty) phones(contact.details!.phones),

      if (contact.systemContact != null &&
          contact.systemContact!.emails.isNotEmpty)
        emails(contact.systemContact!.emails),
      if (contact.details!.emails.isNotEmpty) emails(contact.details!.emails),

      if (contact.systemContact != null &&
          contact.systemContact!.addresses.isNotEmpty)
        addresses(context, contact.systemContact!.addresses),
      if (contact.details!.addresses.isNotEmpty)
        addresses(context, contact.details!.addresses),
      // TODO: Switch to drop down selection when profiles are ready
      //  DropdownButton(
      //   // TODO make state dependent
      //   value: (c.sharingProfile == null) ? 'dont' : c.sharingProfile ,
      //   // TODO: Get from my profile preferences
      //   items: [
      //     DropdownMenuItem<String>(child: Text("Nothing"), value: "dont"),
      //     DropdownMenuItem<String>(child: Text("Friends"), value: "friends"),
      //     DropdownMenuItem<String>(child: Text("Work"), value: "work"),
      //     ],
      //   onChanged: (v) => context.read<>().updateContact(
      //     c.contact.id as String, v! as String))]),
      if (contact.dhtSettingsForSharing != null &&
          contact.dhtSettingsForSharing!.writer != null &&
          contact.dhtSettingsForSharing!.psk != null &&
          contact.sharedProfile != null &&
          contact.sharedProfile!.isNotEmpty) ...[
        Card(
            shape:
                const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(
                    child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(Icons.share),
                          SizedBox(width: 8),
                          Text('Share via Trusted Channel'),
                          SizedBox(width: 4),
                        ]),
                    // TODO: Add warning dialogue that the link contains a secret and should only be transmitted via an end to end encrypted messenger
                    onPressed: () async => Share.share(
                        'I\'d like to coagulate with you: ${_shareURL(contact.dhtSettingsForSharing!)}\nKeep this link a secret, it\'s just for you.'),
                  ),
                  const Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Text('or scan this QR code')),
                  QrImageView(
                      data:
                          _shareURL(contact.dhtSettingsForSharing!).toString(),
                      backgroundColor: Colors.white,
                      size: 200),
                  const SizedBox(height: 8),
                ]))
      ],
      Center(
          child: TextButton(
              onPressed: () => context
                  .read<ContactDetailsCubit>()
                  .delete(contact.coagContactId),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
              ),
              // TODO: Add subtext that this will retain the system contact in case it was linked
              child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Text(
                    'Delete from Coagulate',
                    style: TextStyle(color: Colors.black),
                  )))),
      // TODO: Display sharedProfile when sharing
      if (contact.sharedProfile != null && contact.sharedProfile!.isNotEmpty)
        Card(
            shape:
                const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
            child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Shared Profile Details',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(contact.sharedProfile!),
                    ]))),
    ]));
  }
}
