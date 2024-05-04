// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/coag_contact.dart';
import '../../data/repositories/contacts.dart';
import '../../ui/profile/cubit.dart';
import '../profile/page.dart';
import '../widgets/avatar.dart';
import 'cubit.dart';

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

Widget _coagulateButton(BuildContext context,
    {required CoagContact contact, required CoagContact myProfile}) {
  // TODO: Directly prep sharing when visiting the contact details instead of hiding it behind a button?
  //       Maybe when there are sharing profiles and we can default to one that just contains the name.
  if (contact.sharedProfile == null || contact.sharedProfile!.isEmpty) {
    return TextButton(
        onPressed: () async =>
            {context.read<ContactDetailsCubit>().share(myProfile)},
        child: const Text('Prepare Coagulation'));
  } else {
    // TODO: Replace by choosing the "no details" sharing profile
    return TextButton(
        onPressed: context.read<ContactDetailsCubit>().unshare,
        child: const Text('Stop Sharing'));
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
                  // TODO: Theme
                  backgroundColor: const Color.fromARGB(255, 244, 244, 244),
                  appBar: AppBar(
                    title: Text(state.contact.details?.displayName ??
                        state.contact.systemContact?.displayName ??
                        'Contact Details'),
                  ),
                  body: _body(context, state.contact))));

  Widget _body(BuildContext context, CoagContact contact) =>
      SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const SizedBox(height: 24),
        Center(
            child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: avatar(contact.systemContact))),

        // TODO: We don't need to integrate profile and sharing via the UI, we can also do it via the repository layer.
        //       It might make sense when we introduce the sharing profile settings, though, so let's see then.
        BlocConsumer<ProfileCubit, ProfileState>(
            listener: (context, state) async {},
            builder: (context, state) {
              if (state.profileContact == null) {
                return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                        'Pick a profile contact, then you can start sharing.'));
              }
              return Center(
                  child: _coagulateButton(context,
                      contact: contact, myProfile: state.profileContact!));
            }),

        // Receiving stuff
        if (contact.dhtSettingsForReceiving != null &&
            contact.dhtSettingsForReceiving!.writer != null &&
            contact.dhtSettingsForReceiving!.psk != null)
          receivingCard(context, contact),

        // First phase?
        // for all incoming ones, show as synced to local
        // for all local ones that don't match incoming ones, show as local
        // match by index when linking for the first time

        // TODO: Display merged view of contact details and system contact second phase, where
        // if a matching name with the same value is present
        //   - show entry with managed or unmanaged indicator
        // if a matching name with a different value is present
        //   - if managed, override, collapse to same
        //   - if not managed, display side by side, show option to enable dht management
        // if no matching name and value is present
        //   - add as new entry to system contact, mark managed
        // if no matching name but matching value is present, think about displaying them next to each other still

        // Contact details
        if (contact.details?.phones.isNotEmpty ?? false)
          phones(contact.details!.phones)
        else if (contact.systemContact?.phones.isNotEmpty ?? false)
          phones(contact.systemContact!.phones),

        if (contact.details?.emails.isNotEmpty ?? false)
          emails(contact.details!.emails)
        else if (contact.systemContact != null &&
            contact.systemContact!.emails.isNotEmpty)
          emails(contact.systemContact!.emails),

        if (contact.details?.addresses.isNotEmpty ?? false)
          addresses(contact.details!.addresses)
        else if (contact.systemContact?.addresses.isNotEmpty ?? false)
          addresses(contact.systemContact!.addresses),

        if (contact.details?.websites.isNotEmpty ?? false)
          websites(contact.details!.websites)
        else if (contact.systemContact?.websites.isNotEmpty ?? false)
          websites(contact.systemContact!.websites),

        if (contact.details?.socialMedias.isNotEmpty ?? false)
          socialMedias(contact.details!.socialMedias)
        else if (contact.systemContact?.socialMedias.isNotEmpty ?? false)
          socialMedias(contact.systemContact!.socialMedias),

        // Sharing stuff
        if (contact.dhtSettingsForSharing != null &&
            contact.dhtSettingsForSharing!.writer != null &&
            contact.dhtSettingsForSharing!.psk != null &&
            contact.sharedProfile != null &&
            contact.sharedProfile!.isNotEmpty)
          sharingCard(context, contact),
        if (contact.sharedProfile != null && contact.sharedProfile!.isNotEmpty)
          ...displayDetails(CoagContactDHTSchemaV1.fromJson(
                  json.decode(contact.sharedProfile!) as Map<String, dynamic>)
              .details),

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
      ]));
}

Widget receivingCard(BuildContext context, CoagContact contact) => Card(
    shape: const RoundedRectangleBorder(),
    margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
    child: Stack(children: [
      Positioned.fill(
        child: SvgPicture.asset(
            'assets/images/down_arrow_bg.svg', // Path to your SVG file
            fit: BoxFit.cover),
      ),
      Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
                'Ask ${contact.details?.displayName ?? contact.systemContact!.displayName} to start sharing with you:',
                textScaler: const TextScaler.linear(1.2)),
            const SizedBox(height: 4),
            Center(
                child: _qrCodeButton(context,
                    buttonText: 'QR code to request',
                    alertTitle:
                        'Request from ${contact.details?.displayName ?? contact.systemContact!.displayName}',
                    qrCodeData: _receiveUrl(
                      key: contact.dhtSettingsForReceiving!.key,
                      psk: contact.dhtSettingsForReceiving!.psk!,
                      writer: contact.dhtSettingsForReceiving!.writer!,
                    ).toString())),
            const Center(child: Text('or')),
            Center(
                child: TextButton(
              child:
                  const Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
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
          ]))
    ]));

Widget sharingCard(BuildContext context, CoagContact contact) => Card(
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
    child: Stack(children: [
      Positioned.fill(
          child: SvgPicture.asset('assets/images/up_arrow_bg.svg',
              fit: BoxFit.cover)),
      Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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

            Text(
                'Start sharing your contact details with ${contact.details?.displayName ?? contact.systemContact!.displayName}:',
                textScaler: const TextScaler.linear(1.2)),
            const SizedBox(height: 4),
            // TODO: Only show share back button when receiving key and psk but not writer are set i.e. is receiving updates and has share back settings
            Center(
                child: _qrCodeButton(context,
                    buttonText: 'QR code to share',
                    alertTitle:
                        'Share with ${contact.details?.displayName ?? contact.systemContact!.displayName}',
                    qrCodeData: _shareUrl(
                      key: contact.dhtSettingsForSharing!.key,
                      psk: contact.dhtSettingsForSharing!.psk!,
                    ).toString())),
            const Center(child: Text('or')),
            Center(
                child: TextButton(
              child:
                  const Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
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
            const SizedBox(height: 8),
          ]))
    ]));

// TODO: Move to widgets because it's used in two places at least
Iterable<Widget> displayDetails(ContactDetails details) => [
      Card(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
          child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(details.displayName,
                  textScaler: const TextScaler.linear(1.2),
                  style: const TextStyle(fontWeight: FontWeight.normal)))),
      if (details.phones.isNotEmpty) phones(details.phones),
      if (details.emails.isNotEmpty) emails(details.emails),
      if (details.addresses.isNotEmpty) addresses(details.addresses),
      if (details.websites.isNotEmpty) websites(details.websites),
      if (details.socialMedias.isNotEmpty) socialMedias(details.socialMedias),
    ];
