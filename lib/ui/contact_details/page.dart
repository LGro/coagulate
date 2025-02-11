// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:math';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as flutterContacts;
import 'package:qr_flutter/qr_flutter.dart';

import '../../data/models/coag_contact.dart';
import '../../data/models/contact_location.dart';
import '../../data/repositories/contacts.dart';
import '../../ui/profile/cubit.dart';
import '../../utils.dart';
import '../locations/page.dart';
import '../profile/page.dart';
import '../widgets/circles/cubit.dart';
import '../widgets/circles/widget.dart';
import '../widgets/dht_status/widget.dart';
import '../widgets/veilid_status/widget.dart';
import 'cubit.dart';

Uri _shareUrl({required String key, required String psk}) => Uri(
    scheme: 'https',
    host: 'coagulate.social',
    // TODO: Make language dependent on local language setting?
    path: 'en/c',
    fragment: '$key:$psk');

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
                    const EdgeInsets.only(left: 16, right: 16, top: 16),
                title: Center(child: Text(alertTitle)),
                // shape: const RoundedRectangleBorder(),
                content: SizedBox(
                    height: 200,
                    width: 200,
                    child: Center(
                        child: QrImageView(
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

        // Contact details
        ...contactDetailsAndLocations(context, contact),

        // Sharing stuff
        Padding(
            padding: const EdgeInsets.only(left: 12, top: 16, right: 12),
            child: Text('Connection settings',
                textScaler: const TextScaler.linear(1.2),
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary))),
        Padding(
            padding:
                const EdgeInsets.only(left: 4, top: 4, bottom: 4, right: 4),
            child: sharingSettings(context, contact, circleNames)),

        Center(
            child: TextButton(
                onPressed: () async => context
                    .read<ContactDetailsCubit>()
                    .delete(contact.coagContactId)
                    .then((_) =>
                        (context.mounted) ? Navigator.of(context).pop() : null),
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

        // if (!kReleaseMode)
        // Debug output about update timestamps and receive / share DHT records
        Column(children: [
          const SizedBox(height: 16),
          const Text('Developer debug information',
              textScaler: TextScaler.linear(1.2)),
          const SizedBox(height: 8),
          const VeilidStatusWidget(statusWidgets: {}),
          const SizedBox(height: 8),
          if (contact.dhtSettingsForSharing?.key != null)
            DhtStatusWidget(
              dhtSettings: contact.dhtSettingsForSharing!,
              statusWidgets: const {},
            ),
          if (contact.dhtSettingsForReceiving?.key != null)
            DhtStatusWidget(
              dhtSettings: contact.dhtSettingsForReceiving!,
              statusWidgets: const {},
            ),
          const SizedBox(height: 8),
          Text('Updated: ${contact.mostRecentUpdate}'),
          Text('Changed: ${contact.mostRecentChange}'),
          if (contact.dhtSettingsForReceiving?.key != null)
            const Padding(
                padding: EdgeInsets.only(left: 16, right: 16),
                child: Divider(color: Colors.grey)),
          if (contact.dhtSettingsForReceiving?.key != null)
            Text(
                'DHT Rcv Key: ${contact.dhtSettingsForReceiving!.key.substring(5, 25)}...'),
          if (contact.dhtSettingsForReceiving?.psk != null)
            Text(
                'DHT Rcv Sec: ${contact.dhtSettingsForReceiving!.psk!.substring(0, min(20, contact.dhtSettingsForReceiving!.psk!.length))}...'),
          if (contact.dhtSettingsForReceiving?.writer != null)
            Text(
                'DHT Rcv Wrt: ${contact.dhtSettingsForReceiving!.writer!.substring(0, min(20, contact.dhtSettingsForReceiving!.writer!.length))}...'),
          if (contact.dhtSettingsForReceiving?.pubKey != null)
            Text(
                'DHT Rcv Pub: ${contact.dhtSettingsForReceiving!.pubKey!.substring(0, min(20, contact.dhtSettingsForReceiving!.pubKey!.length))}...'),
          if (contact.dhtSettingsForSharing?.key != null)
            const Padding(
                padding: EdgeInsets.only(left: 16, right: 16),
                child: Divider(color: Colors.grey)),
          if (contact.dhtSettingsForSharing?.key != null)
            Text(
                'DHT Shr Key: ${contact.dhtSettingsForSharing!.key.substring(5, 25)}...'),
          if (contact.dhtSettingsForSharing?.psk != null)
            Text(
                'DHT Shr Sec: ${contact.dhtSettingsForSharing!.psk!.substring(0, min(20, contact.dhtSettingsForSharing!.psk!.length))}...'),
          if (contact.dhtSettingsForSharing?.writer != null)
            Text(
                'DHT Shr Wrt: ${contact.dhtSettingsForSharing!.writer!.substring(0, min(20, contact.dhtSettingsForSharing!.writer!.length))}...'),
          if (contact.dhtSettingsForSharing?.pubKey != null)
            Text(
                'DHT Shr Pub: ${contact.dhtSettingsForSharing!.pubKey!.substring(0, min(20, contact.dhtSettingsForSharing!.pubKey!.length))}...'),
          const SizedBox(height: 16),
        ]),
      ]));
}

// NOTE: This is also used in receive requests page
List<Widget> contactDetailsAndLocations(
        BuildContext context, CoagContact contact) =>
    [
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

      Padding(
          padding:
              const EdgeInsets.only(left: 12, top: 8, right: 12, bottom: 8),
          child: Text('Contact details',
              textScaler: const TextScaler.linear(1.2),
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary))),

      // Contact details
      if (contact.details?.names.isNotEmpty ?? false)
        detailsList<String>(
          contact.details!.names.values.toList(),
          title: Text('Names'),
          getValue: (v) => v,
          // This doesn't do anything when hideLabel, maybe it can be optional
          getLabel: (v) => v,
          hideLabel: true,
        ),
      if (contact.details?.phones.isNotEmpty ?? false)
        detailsList<flutterContacts.Phone>(
          contact.details!.phones,
          title: Text('Phone numbers'),
          getLabel: (v) =>
              (v.label.name != 'custom') ? v.label.name : v.customLabel,
          getValue: (v) => v.number,
        ),
      if (contact.details?.emails.isNotEmpty ?? false)
        detailsList<flutterContacts.Email>(
          contact.details!.emails,
          title: Text('E-Mail addresses'),
          getLabel: (v) =>
              (v.label.name != 'custom') ? v.label.name : v.customLabel,
          getValue: (v) => v.address,
        ),
      if (contact.details?.addresses.isNotEmpty ?? false)
        detailsList<flutterContacts.Address>(
          contact.details!.addresses,
          title: Text('Addresses'),
          getLabel: (v) =>
              (v.label.name != 'custom') ? v.label.name : v.customLabel,
          getValue: (v) => v.address,
        ),
      if (contact.details?.socialMedias.isNotEmpty ?? false)
        detailsList<flutterContacts.SocialMedia>(
          contact.details!.socialMedias,
          title: Text('Social media profiles'),
          getLabel: (v) =>
              (v.label.name != 'custom') ? v.label.name : v.customLabel,
          getValue: (v) => v.userName,
        ),
      if (contact.details?.websites.isNotEmpty ?? false)
        detailsList<flutterContacts.Website>(
          contact.details!.websites,
          title: Text('Websites'),
          getLabel: (v) =>
              (v.label.name != 'custom') ? v.label.name : v.customLabel,
          getValue: (v) => v.url,
        ),

      // Locations
      if (contact.temporaryLocations.isNotEmpty)
        temporaryLocationsCard(
            Text('Locations',
                textScaler: const TextScaler.linear(1.2),
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary)),
            contact.temporaryLocations),
    ];

Widget _paddedDivider() => const Padding(
    padding: EdgeInsets.only(left: 16, right: 16), child: Divider());

Widget sharingSettings(
        BuildContext context, CoagContact contact, List<String> circleNames) =>
    Card(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      circlesCard(context, contact.coagContactId, circleNames),

      if (circleNames.isNotEmpty &&
          contact.dhtSettingsForSharing != null &&
          contact.dhtSettingsForSharing?.writer != null &&
          contact.dhtSettingsForSharing?.psk != null &&
          contact.sharedProfile != null &&
          contact.sharedProfile!.isNotEmpty) ...[
        _paddedDivider(),
        connectingCard(context, contact),
      ],

      if (circleNames.isNotEmpty &&
          contact.sharedProfile != null &&
          contact.sharedProfile!.isNotEmpty) ...[
        _paddedDivider(),
        ...displayDetails(CoagContactDHTSchema.fromJson(
                json.decode(contact.sharedProfile!) as Map<String, dynamic>)
            .details),
      ],
      // TODO: Switch to a schema instance instead of a string as the sharedProfile? Or at least offer a method to conveniently get it
      if (contact.sharedProfile != null &&
          contact.sharedProfile!.isNotEmpty &&
          CoagContactDHTSchema.fromJson(
                  json.decode(contact.sharedProfile!) as Map<String, dynamic>)
              .temporaryLocations
              .isNotEmpty) ...[
        _paddedDivider(),
        temporaryLocationsCard(
            const Row(children: [
              Icon(Icons.share_location),
              SizedBox(width: 8),
              Text('Shared locations', textScaler: TextScaler.linear(1.2))
            ]),
            CoagContactDHTSchema.fromJson(
                    json.decode(contact.sharedProfile!) as Map<String, dynamic>)
                .temporaryLocations),
        const Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
            child: Text(
                'These current and future locations are available to them based '
                'on the circles you shared the locations with.')),
      ],
    ]));

Widget temporaryLocationsCard(
        Widget title, List<ContactTemporaryLocation> locations) =>
    Padding(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          title,
          ...locations
              .where((l) => l.end.isAfter(DateTime.now()))
              .map((l) => Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: locationTile(l)))
              .asList(),
        ]));

Widget connectingCard(BuildContext context, CoagContact contact) =>
    Stack(children: [
      if (contact.dhtSettingsForSharing?.key != null &&
          contact.dhtSettingsForSharing?.psk != null)
        Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, top: 8),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.private_connectivity),
                const SizedBox(width: 4),
                Text('To connect with ${displayName(contact) ?? 'them'}:',
                    textScaler: const TextScaler.linear(1.2))
              ]),
              const SizedBox(height: 4),
              // TODO: Only show share back button when receiving key and psk but not writer are set i.e. is receiving updates and has share back settings
              _qrCodeButton(context,
                  buttonText: 'Show them this QR code',
                  alertTitle: 'Show to ${displayName(contact) ?? 'them'}',
                  qrCodeData: _shareUrl(
                    key: contact.dhtSettingsForSharing!.key,
                    psk: contact.dhtSettingsForSharing!.psk!,
                  ).toString()),
              // TextButton(
              //   child: const Row(
              //       mainAxisSize: MainAxisSize.min,
              //       children: <Widget>[
              //         Icon(Icons.share),
              //         SizedBox(width: 8),
              //         Text('Paste their profile link'),
              //         SizedBox(width: 4),
              //       ]),
              //       // TODO: Paste from clipboard and generate invite text to share
              //   onPressed: () {},
              // ),
              const SizedBox(height: 4),
              // TODO: Link "create an invite" to the corresponding page, and maybe also "contact page" to contacts list?
              Text(
                  'This QR code is specifically for ${displayName(contact) ?? 'this contact'}. '
                  'If you want to connect with someone else, go to their '
                  'contact details or create an invite.'),
              const SizedBox(height: 8),
            ]))
    ]);

Iterable<Widget> displayDetails(ContactDetails details) => [
      const Padding(
          padding: EdgeInsets.only(top: 8, left: 12, right: 12, bottom: 8),
          child: Row(children: [
            Icon(Icons.contact_page),
            SizedBox(width: 4),
            Text('Shared profile', textScaler: TextScaler.linear(1.2))
          ])),
      if (details.names.isNotEmpty)
        detailsList<String>(
          details.names.values.toList(),
          title: Text('Names'),
          getValue: (v) => v,
          // This doesn't do anything when hideLabel, maybe it can be optional
          getLabel: (v) => v,
          hideLabel: true,
        ),
      if (details.phones.isNotEmpty)
        detailsList<flutterContacts.Phone>(
          details.phones,
          title: Text('Phone numbers'),
          getLabel: (v) =>
              (v.label.name != 'custom') ? v.label.name : v.customLabel,
          getValue: (v) => v.number,
        ),
      if (details.emails.isNotEmpty)
        detailsList<flutterContacts.Email>(
          details.emails,
          title: Text('E-Mail addresses'),
          getLabel: (v) =>
              (v.label.name != 'custom') ? v.label.name : v.customLabel,
          getValue: (v) => v.address,
        ),
      if (details.addresses.isNotEmpty)
        detailsList<flutterContacts.Address>(
          details.addresses,
          title: Text('Addresses'),
          getLabel: (v) =>
              (v.label.name != 'custom') ? v.label.name : v.customLabel,
          getValue: (v) => v.address,
        ),
      if (details.socialMedias.isNotEmpty)
        detailsList<flutterContacts.SocialMedia>(
          details.socialMedias,
          title: Text('Social media profiles'),
          getLabel: (v) =>
              (v.label.name != 'custom') ? v.label.name : v.customLabel,
          getValue: (v) => v.userName,
        ),
      if (details.websites.isNotEmpty)
        detailsList<flutterContacts.Website>(
          details.websites,
          title: Text('Websites'),
          getLabel: (v) =>
              (v.label.name != 'custom') ? v.label.name : v.customLabel,
          getValue: (v) => v.url,
        ),
      const Padding(
          padding: EdgeInsets.only(left: 12, right: 12, bottom: 8, top: 4),
          child: Text(
              'Once connected, they see the above information based on the '
              'circles you added them to.')),
    ];

Widget circlesCard(
        BuildContext context, String coagContactId, List<String> circleNames) =>
    Padding(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Icon(Icons.bubble_chart),
            SizedBox(width: 4),
            Text('Circle memberships', textScaler: TextScaler.linear(1.2))
          ]),
          Row(children: [
            Expanded(
              child: Padding(
                  padding: const EdgeInsets.only(
                      left: 8, right: 8, top: 12, bottom: 12),
                  child: (circleNames.isEmpty)
                      ? const Text('Add them to circles to start sharing.',
                          textScaler: TextScaler.linear(1.2))
                      : Text(circleNames.join(', '),
                          textScaler: const TextScaler.linear(1.2))),
            ),
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
                            bottom:
                                MediaQuery.of(modalContext).viewInsets.bottom),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            BlocProvider(
                                create: (context) => CirclesCubit(
                                    context.read<ContactsRepository>(),
                                    coagContactId),
                                child: BlocConsumer<CirclesCubit, CirclesState>(
                                    listener: (context, state) async {},
                                    builder: (context, state) => CirclesForm(
                                        circles: state.circles,
                                        callback: context
                                            .read<CirclesCubit>()
                                            .update)))
                          ],
                        )))),
          ]),
          const Text(
              'The selected circles determine which of your contact details '
              'and locations they can see.'),
        ]));
