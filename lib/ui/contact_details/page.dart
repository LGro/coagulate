// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
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

Uri _shareUrl({required String key, required String psk}) => Uri(
    scheme: 'https',
    host: 'coagulate.social',
    // TODO: Make language dependent on local language setting?
    path: 'en/c',
    fragment: '$key:$psk');

Uri _receiveUrl(
        {required String key, required String psk, required String writer}) =>
    Uri(
        scheme: 'https',
        host: 'coagulate.social',
        // TODO: Make language dependent on local language setting?
        path: 'en/c',
        fragment: '$key:$psk:$writer');

Widget _coagulateButton(
    BuildContext context, CoagContact contact, CoagContact myProfile) {
  if (contact.sharedProfile == null || contact.sharedProfile!.isEmpty) {
    return TextButton(
        onPressed: () async =>
            {context.read<ContactDetailsCubit>().share(myProfile)},
        child: const Text('initialize sharing'));
  } else {
    return TextButton(
        onPressed: context.read<ContactDetailsCubit>().unshare,
        child: const Text('cancel sharing'));
  }
}

Widget _qrCodeButton(BuildContext context,
        {required String buttonText,
        required String alertTitle,
        required String qrCodeData}) =>
    TextButton(
        child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
          const Icon(Icons.qr_code),
          const SizedBox(width: 8),
          Text(buttonText),
          const SizedBox(width: 4),
        ]),
        onPressed: () async => showDialog<void>(
            context: context,
            builder: (_) => AlertDialog(
                title: Text(alertTitle),
                shape: const RoundedRectangleBorder(),
                content: Container(
                    height: 200,
                    width: 200,
                    child: Center(
                        child: QrImageView(
                            // TODO: This needs to be receive URL because it needs to include the writer
                            data: qrCodeData,
                            backgroundColor: Colors.white,
                            size: 200))))));

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
      // Sharing stuff
      Card(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
          child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Start sharing your contact details with ${contact.details?.displayName}:',
                        textScaler: const TextScaler.linear(1.2)),
                    const SizedBox(height: 4),
                    // TODO: Add when custom sharing profiles are there
                    // DropdownButton(
                    //     // TODO make state dependent
                    //     // TODO: Get from my profile preferences
                    //     value: 'full',
                    //     items: const [
                    //       DropdownMenuItem<String>(
                    //           value: 'full', child: Text('Full Profile')),
                    //     ],
                    //     onChanged: (v) => ()),
                    if (contact.dhtSettingsForSharing != null &&
                        contact.dhtSettingsForSharing!.writer != null &&
                        contact.dhtSettingsForSharing!.psk != null &&
                        contact.sharedProfile != null &&
                        contact.sharedProfile!.isNotEmpty) ...[
                      Center(
                          child: _qrCodeButton(context,
                              buttonText: 'QR code to share',
                              alertTitle:
                                  'Share with ${contact.details!.displayName}',
                              qrCodeData: _shareUrl(
                                key: contact.dhtSettingsForSharing!.key,
                                psk: contact.dhtSettingsForSharing!.psk!,
                              ).toString())),
                      const Center(child: Text('or')),
                      Center(
                          child: TextButton(
                        child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(Icons.share),
                              SizedBox(width: 8),
                              Text('share link via trusted channel'),
                              SizedBox(width: 4),
                            ]),
                        // TODO: Add warning dialogue that the link contains a secret and should only be transmitted via an end to end encrypted messenger
                        onPressed: () async => Share.share(
                            'I\'d like to coagulate with you: ${_shareUrl(key: contact.dhtSettingsForSharing!.key, psk: contact.dhtSettingsForSharing!.psk!)}\n'
                            'Keep this link a secret, it\'s just for you.'),
                      )),
                    ],
                    BlocConsumer<ProfileCubit, ProfileState>(
                        listener: (context, state) async {},
                        builder: (context, state) {
                          if (state.profileContact == null) {
                            return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                    'Pick a profile contact, then you can share.'));
                          } else {
                            return Center(
                                child: _coagulateButton(
                                    context,
                                    contact,
                                    // TODO: Make my profile a first class citizen coag contact?
                                    CoagContact(
                                        coagContactId: Uuid().v4(),
                                        systemContact: state
                                            .profileContact?.systemContact)));
                          }
                        }),
                    const SizedBox(height: 8),
                  ]))),
      // Receiving stuff // TODO: Add background image to differentiate between sharing and receiving
      if (contact.dhtSettingsForReceiving != null &&
          contact.dhtSettingsForReceiving!.writer != null &&
          contact.dhtSettingsForReceiving!.psk != null &&
          contact.dhtSettingsForReceiving!.lastUpdated == null)
        Card(
            shape: const RoundedRectangleBorder(),
            margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
            child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Ask ${contact.details?.displayName} to start sharing with you:',
                          textScaler: const TextScaler.linear(1.2)),
                      const SizedBox(height: 4),
                      Center(
                          child: _qrCodeButton(context,
                              buttonText: 'QR code to request',
                              alertTitle:
                                  'Request from ${contact.details!.displayName}',
                              qrCodeData: _receiveUrl(
                                key: contact.dhtSettingsForReceiving!.key,
                                psk: contact.dhtSettingsForReceiving!.psk!,
                                writer:
                                    contact.dhtSettingsForReceiving!.writer!,
                              ).toString())),
                      const Center(child: Text('or')),
                      Center(
                          child: TextButton(
                        child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(Icons.share),
                              SizedBox(width: 8),
                              Text('request via trusted channel'),
                              SizedBox(width: 4),
                            ]),
                        // TODO: Add warning dialogue that the link contains a secret and should only be transmitted via an end to end encrypted messenger
                        onPressed: () async => Share.share(
                            'I\'d like to coagulate with you: ${_receiveUrl(key: contact.dhtSettingsForReceiving!.key, psk: contact.dhtSettingsForReceiving!.psk!, writer: contact.dhtSettingsForReceiving!.writer!)}\n'
                            'Keep this link a secret, it\'s just for you.'),
                      )),
                      const SizedBox(height: 8),
                    ]))),
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
