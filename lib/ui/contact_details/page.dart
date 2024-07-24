// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/coag_contact.dart';
import '../../data/models/contact_location.dart';
import '../../data/repositories/contacts.dart';
import '../../ui/profile/cubit.dart';
import '../../utils.dart';
import '../locations/page.dart';
import '../profile/page.dart';
import '../widgets/avatar.dart';
import '../widgets/circles/cubit.dart';
import '../widgets/circles/widget.dart';
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
                titlePadding:
                    const EdgeInsets.only(left: 20, right: 20, top: 16),
                title: Text(alertTitle),
                shape: const RoundedRectangleBorder(),
                content: SizedBox(
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
                    title: Text((state.contact == null)
                        ? '???'
                        : displayName(state.contact!) ?? 'Contact Details'),
                  ),
                  body: (state.contact == null)
                      ? const SingleChildScrollView(
                          child: Text('Contact not found.'))
                      : _body(context, state.contact!, state.circleNames))));

  Widget _body(BuildContext context, CoagContact contact,
          List<String> circleNames) =>
      SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const SizedBox(height: 24),
        Center(
            child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: avatar(contact.systemContact))),

        BlocConsumer<ProfileCubit, ProfileState>(
            listener: (context, state) async {},
            builder: (context, state) {
              if (state.profileContact == null) {
                return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                        'Pick a profile contact, then you can start sharing.'));
              } else {
                return Container();
              }
            }),

        // if (!kReleaseMode)
        //   Column(children: [
        //     Text('DEBUG INFOS'),
        //     if (contact.dhtSettingsForSharing != null)
        //       Text(
        //           'SHR: ${json.encode(contact.dhtSettingsForSharing!.toJson())}'),
        //     if (contact.dhtSettingsForReceiving != null)
        //       Text(
        //           'RCV: ${json.encode(contact.dhtSettingsForReceiving!.toJson())}'),
        //   ]),

        // Receiving stuff
        if (circleNames.isNotEmpty &&
            contact.dhtSettingsForReceiving != null &&
            contact.dhtSettingsForReceiving?.writer != null &&
            contact.dhtSettingsForReceiving?.psk != null)
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

        // Locations
        if (contact.temporaryLocations.isNotEmpty)
          temporaryLocationsCard(contact.temporaryLocations),

        circlesCard(context, contact.coagContactId, circleNames),

        // Sharing stuff
        if (circleNames.isNotEmpty &&
            contact.dhtSettingsForSharing != null &&
            contact.dhtSettingsForSharing?.writer != null &&
            contact.dhtSettingsForSharing?.psk != null &&
            contact.sharedProfile != null &&
            contact.sharedProfile!.isNotEmpty)
          sharingCard(context, contact),
        if (circleNames.isNotEmpty &&
            contact.sharedProfile != null &&
            contact.sharedProfile!.isNotEmpty)
          ...displayDetails(CoagContactDHTSchemaV1.fromJson(
                  json.decode(contact.sharedProfile!) as Map<String, dynamic>)
              .details),
        // TODO: Switch to a schema instance instead of a string as the sharedProfile? Or at least offer a method to conveniently get it
        if (contact.sharedProfile != null &&
            contact.sharedProfile!.isNotEmpty &&
            CoagContactDHTSchemaV1.fromJson(
                    json.decode(contact.sharedProfile!) as Map<String, dynamic>)
                .temporaryLocations
                .isNotEmpty)
          temporaryLocationsCard(CoagContactDHTSchemaV1.fromJson(
                  json.decode(contact.sharedProfile!) as Map<String, dynamic>)
              .temporaryLocations),

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
        child: Opacity(
            opacity:
                (MediaQuery.of(context).platformBrightness == Brightness.dark)
                    ? 0.2
                    : 0.8,
            child: SvgPicture.asset(
                'assets/images/down_arrow_bg.svg', // Path to your SVG file
                fit: BoxFit.cover)),
      ),
      if (contact.dhtSettingsForReceiving?.key != null &&
          contact.dhtSettingsForReceiving?.psk != null &&
          contact.dhtSettingsForReceiving?.writer != null)
        Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                  'Ask ${displayName(contact) ?? 'them'} to start sharing with you:',
                  textScaler: const TextScaler.linear(1.2)),
              const SizedBox(height: 4),
              Center(
                  child: _qrCodeButton(context,
                      buttonText: 'QR code to request',
                      alertTitle:
                          'Request from ${displayName(contact) ?? 'them'}',
                      qrCodeData: _receiveUrl(
                        key: contact.dhtSettingsForReceiving!.key,
                        psk: contact.dhtSettingsForReceiving!.psk!,
                        writer: contact.dhtSettingsForReceiving!.writer!,
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
                    'Please share with me: ${_receiveUrl(key: contact.dhtSettingsForReceiving!.key, psk: contact.dhtSettingsForReceiving!.psk!, writer: contact.dhtSettingsForReceiving!.writer!)}\n'
                    'Keep this link a secret, it\'s just for you.'),
              )),
              const SizedBox(height: 8),
            ]))
    ]));

Widget temporaryLocationsCard(List<ContactTemporaryLocation> locations) => Card(
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
    child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('locations', style: TextStyle(fontSize: 16)),
          ...locations
              .where((l) => l.end.isAfter(DateTime.now()))
              .map(locationTile)
              .asList()
        ])));

Widget sharingCard(BuildContext context, CoagContact contact) => Card(
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
    child: Stack(children: [
      Positioned.fill(
          child: Opacity(
              opacity:
                  (MediaQuery.of(context).platformBrightness == Brightness.dark)
                      ? 0.2
                      : 0.8,
              child: SvgPicture.asset('assets/images/up_arrow_bg.svg',
                  fit: BoxFit.cover))),
      if (contact.dhtSettingsForSharing?.key != null &&
          contact.dhtSettingsForSharing?.psk != null)
        Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                  'Start sharing your contact details with ${displayName(contact) ?? 'them'}:',
                  textScaler: const TextScaler.linear(1.2)),
              const SizedBox(height: 4),
              // TODO: Only show share back button when receiving key and psk but not writer are set i.e. is receiving updates and has share back settings
              Center(
                  child: _qrCodeButton(context,
                      buttonText: 'QR code to share',
                      alertTitle:
                          'Share with ${displayName(contact) ?? 'them'}',
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
                    'I\'d like to share with you: ${_shareUrl(key: contact.dhtSettingsForSharing!.key, psk: contact.dhtSettingsForSharing!.psk!)}\n'
                    'Keep this link a secret, it\'s just for you.'),
              )),
              const SizedBox(height: 8),
            ]))
    ]));

// TODO: Move to widgets because it's used in two places at least
Iterable<Widget> displayDetails(ContactDetails details) => [
      const Padding(
          padding: EdgeInsets.only(top: 12, left: 8, right: 8, bottom: 8),
          child:
              Text('Shared with this contact based on the selected circles:')),
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

Card circlesCard(
        BuildContext context, String coagContactId, List<String> circleNames) =>
    Card(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
        child: Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 12),
            child: Row(children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const Text('circles', style: TextStyle(fontSize: 16)),
                    if (circleNames.isEmpty)
                      const Text('Add them to circles to start sharing.',
                          style: TextStyle(fontSize: 19))
                    else
                      Text(circleNames.join(', '),
                          style: const TextStyle(fontSize: 19)),
                  ])),
              IconButton(
                  key: const Key('editCircleMembership'),
                  icon: const Icon(Icons.edit),
                  onPressed: () async => showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (modalContext) => Padding(
                          padding: EdgeInsets.only(
                              left: 16,
                              top: 16,
                              right: 16,
                              bottom: MediaQuery.of(modalContext)
                                  .viewInsets
                                  .bottom),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              BlocProvider(
                                  create: (context) => CirclesCubit(
                                      context.read<ContactsRepository>(),
                                      coagContactId),
                                  child:
                                      BlocConsumer<CirclesCubit, CirclesState>(
                                          listener: (context, state) async {},
                                          builder: (context, state) =>
                                              CirclesForm(
                                                  circles: state.circles,
                                                  callback: context
                                                      .read<CirclesCubit>()
                                                      .update)))
                            ],
                          ))))
            ])));
