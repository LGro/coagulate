// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as flutter_contacts;
import 'package:qr_flutter/qr_flutter.dart';

import '../../data/models/coag_contact.dart';
import '../../data/models/contact_location.dart';
import '../../data/repositories/contacts.dart';
import '../../ui/profile/cubit.dart';
import '../locations/page.dart';
import '../profile/page.dart';
import '../widgets/circles/cubit.dart';
import '../widgets/circles/widget.dart';
import '../widgets/dht_status/widget.dart';
import '../widgets/veilid_status/widget.dart';
import 'cubit.dart';

Uri _shareUrl({required String key, required String psk, String? name}) {
  final fragment = <String>[];
  if (name != null) {
    fragment.add(name);
  }
  fragment.addAll([key, psk]);

  return Uri(
      scheme: 'https',
      host: 'coagulate.social',
      // TODO: Make language dependent on local language setting?
      path: 'en/c',
      fragment: fragment.join(':'));
}

String _shorten(String str) => str.substring(0, min(10, str.length));

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
  ContactPage({super.key, required this.coagContactId});

  final String coagContactId;

  final TextEditingController _contactCommentController =
      TextEditingController();

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
                    title: Text(state.contact?.name ?? 'Contact Details'),
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
        if (contact.details?.picture != null)
          Center(
              child: Padding(
                  padding: const EdgeInsets.only(left: 12, top: 16, right: 12),
                  child: CircleAvatar(
                    backgroundImage: MemoryImage(
                        Uint8List.fromList(contact.details!.picture!)),
                    radius: 64,
                  ))),

        // Contact details
        ..._contactDetailsAndLocations(context, contact),

        // Sharing circle settings and shared profile
        Padding(
            padding: const EdgeInsets.only(left: 12, top: 16, right: 12),
            child: Text('Connection settings',
                textScaler: const TextScaler.linear(1.4),
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary))),
        Padding(
            padding: const EdgeInsets.only(left: 4, top: 4, right: 4),
            child: _sharingSettings(context, contact, circleNames)),

        // Private note
        Padding(
            padding: const EdgeInsets.only(left: 12, top: 12, right: 12),
            child: Text('Private note',
                textScaler: const TextScaler.linear(1.4),
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary))),
        Padding(
            padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
            child: TextFormField(
              key: const Key('contactDetailsNoteInput'),

              onTapOutside: (event) async => context
                  .read<ContactDetailsCubit>()
                  .updateComment(_contactCommentController.text),
              controller: _contactCommentController..text = contact.comment,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
                helperText:
                    'This note is just for you and never shared with anyone.',
              ),
              textInputAction: TextInputAction.done,
              // TODO: Does this limit the number of lines or just specify the visible ones?
              //       We need the latter not the former.
              maxLines: 4,
            )),

        // Delete contact
        const SizedBox(height: 16),
        Center(
            child: TextButton(
                onPressed: () async => context
                    .read<ContactDetailsCubit>()
                    .delete(contact.coagContactId)
                    .then((_) =>
                        (context.mounted) ? Navigator.of(context).pop() : null),
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                      Theme.of(context).colorScheme.error),
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
          if (contact.dhtSettings.recordKeyMeSharing != null)
            DhtStatusWidget(
              recordKey: contact.dhtSettings.recordKeyMeSharing!,
              statusWidgets: const {},
            ),
          if (contact.dhtSettings.recordKeyThemSharing != null)
            DhtStatusWidget(
              recordKey: contact.dhtSettings.recordKeyThemSharing!,
              statusWidgets: const {},
            ),
          const SizedBox(height: 8),
          Text('Updated: ${contact.mostRecentUpdate}'),
          Text('Changed: ${contact.mostRecentChange}'),
          _paddedDivider(),
          Text(
              'MyPubKey: ${_shorten(contact.dhtSettings.myKeyPair.key.toString())}...'),
          if (contact.dhtSettings.recordKeyMeSharing != null)
            Text(
                'MeDhtKey: ${_shorten(contact.dhtSettings.recordKeyMeSharing.toString())}...'),
          if (contact.dhtSettings.theirPublicKey != null)
            Text(
                'ThemPubKey: ${_shorten(contact.dhtSettings.theirPublicKey.toString())}...'),
          if (contact.dhtSettings.recordKeyThemSharing != null)
            Text(
                'ThemDhtKey: ${_shorten(contact.dhtSettings.recordKeyThemSharing.toString())}...'),
          if (contact.dhtSettings.initialSecret != null)
            Text(
                'InitSec: ${_shorten(contact.dhtSettings.initialSecret.toString())}...'),
          const SizedBox(height: 16),
        ]),
      ]));
}

List<Widget> _contactDetailsAndLocations(
        BuildContext context, CoagContact contact) =>
    [
      Padding(
          padding:
              const EdgeInsets.only(left: 12, top: 8, right: 12, bottom: 8),
          child: Text('Contact details',
              textScaler: const TextScaler.linear(1.4),
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary))),

      if (contact.details == null)
        Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Text('Once you are connected, the information '
                '${contact.name} shares with you shows up here.')),

      // Contact details
      if (contact.details?.names.isNotEmpty ?? false)
        detailsList<String>(
          contact.details!.names.values.toList(),
          title: Text('Name${(contact.details!.names.length == 1) ? '' : 's'}'),
          getValue: (v) => v,
          // This doesn't do anything when hideLabel, maybe it can be optional
          getLabel: (v) => v,
          hideLabel: true,
        ),
      if (contact.details?.phones.isNotEmpty ?? false)
        detailsList<flutter_contacts.Phone>(
          contact.details!.phones,
          title: const Text('Phones'),
          getLabel: (v) =>
              (v.label.name != 'custom') ? v.label.name : v.customLabel,
          getValue: (v) => v.number,
        ),
      if (contact.details?.emails.isNotEmpty ?? false)
        detailsList<flutter_contacts.Email>(
          contact.details!.emails,
          title: const Text('E-Mails'),
          getLabel: (v) =>
              (v.label.name != 'custom') ? v.label.name : v.customLabel,
          getValue: (v) => v.address,
        ),
      if (contact.details?.addresses.isNotEmpty ?? false)
        detailsList<flutter_contacts.Address>(
          contact.details!.addresses,
          title: const Text('Addresses'),
          getLabel: (v) =>
              (v.label.name != 'custom') ? v.label.name : v.customLabel,
          getValue: (v) => v.address,
        ),
      if (contact.details?.socialMedias.isNotEmpty ?? false)
        detailsList<flutter_contacts.SocialMedia>(
          contact.details!.socialMedias,
          title: const Text('Socials'),
          getLabel: (v) =>
              (v.label.name != 'custom') ? v.label.name : v.customLabel,
          getValue: (v) => v.userName,
        ),
      if (contact.details?.websites.isNotEmpty ?? false)
        detailsList<flutter_contacts.Website>(
          contact.details!.websites,
          title: const Text('Websites'),
          getLabel: (v) =>
              (v.label.name != 'custom') ? v.label.name : v.customLabel,
          getValue: (v) => v.url,
        ),

      // Locations
      if (contact.temporaryLocations.isNotEmpty)
        _temporaryLocationsCard(
            Text('Locations',
                textScaler: const TextScaler.linear(1.4),
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary)),
            contact.temporaryLocations),
    ];

Widget _paddedDivider() => const Padding(
    padding: EdgeInsets.only(left: 16, right: 16), child: Divider());

Widget _sharingSettings(
        BuildContext context, CoagContact contact, List<String> circleNames) =>
    Card(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _circlesCard(context, contact.coagContactId, circleNames),
      if (circleNames.isNotEmpty &&
          contact.dhtSettings.writerMeSharing != null &&
          contact.dhtSettings.initialSecret != null &&
          contact.sharedProfile != null &&
          !contact.dhtSettings.theyAckHandshakeComplete) ...[
        _paddedDivider(),
        _connectingCard(context, contact),
      ],
      if (circleNames.isNotEmpty && contact.sharedProfile != null) ...[
        _paddedDivider(),
        ..._displayDetails(contact.sharedProfile!.details),
      ],
      if (contact.sharedProfile?.temporaryLocations.isNotEmpty ?? false) ...[
        _paddedDivider(),
        _temporaryLocationsCard(
            const Row(children: [
              Icon(Icons.share_location),
              SizedBox(width: 8),
              Text('Shared locations', textScaler: TextScaler.linear(1.2))
            ]),
            contact.sharedProfile!.temporaryLocations),
        Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
            child: Text('These current and future locations are available to '
                '${contact.name}  based on the circles you shared the '
                'locations with.')),
      ],
    ]));

Widget _temporaryLocationsCard(
        Widget title, List<ContactTemporaryLocation> locations) =>
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: const EdgeInsets.only(left: 12, right: 12, top: 8),
          child: title),
      Padding(
          padding: const EdgeInsets.only(left: 4, right: 4, top: 4),
          child: Card(
              child: Column(
                  children: locations
                      .where((l) => l.end.isAfter(DateTime.now()))
                      .map((l) => Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, bottom: 4),
                          child: locationTile(l)))
                      .asList())))
    ]);

Widget _connectingCard(BuildContext context, CoagContact contact) =>
    Stack(children: [
      if (contact.dhtSettings.recordKeyMeSharing != null &&
          contact.dhtSettings.initialSecret != null)
        Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, top: 8),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.private_connectivity),
                const SizedBox(width: 4),
                Text('To connect with ${contact.name}:',
                    textScaler: const TextScaler.linear(1.2))
              ]),
              const SizedBox(height: 4),
              // TODO: Only show share back button when receiving key and psk but not writer are set i.e. is receiving updates and has share back settings
              _qrCodeButton(context,
                  buttonText: 'Show them this QR code',
                  alertTitle: 'Show to ${contact.name}',
                  qrCodeData: _shareUrl(
                    key: contact.dhtSettings.recordKeyMeSharing.toString(),
                    psk: contact.dhtSettings.initialSecret.toString(),
                    name:
                        contact.sharedProfile!.details.names.values.firstOrNull,
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
              Text('This QR code is specifically for ${contact.name}. '
                  'If you want to connect with someone else, go to their '
                  'respective contact details or create a new invite.'),
              const SizedBox(height: 8),
            ]))
    ]);

Iterable<Widget> _displayDetails(ContactDetails details) => [
      const Padding(
          padding: EdgeInsets.only(top: 8, left: 12, right: 12, bottom: 8),
          child: Row(children: [
            Icon(Icons.contact_page),
            SizedBox(width: 4),
            Text('Shared profile', textScaler: TextScaler.linear(1.2))
          ])),
      Center(
          child: Padding(
              padding: const EdgeInsets.only(left: 12, top: 4, right: 12),
              child: (details.picture == null)
                  ? const CircleAvatar(radius: 48, child: Icon(Icons.person))
                  : CircleAvatar(
                      radius: 48,
                      backgroundImage:
                          MemoryImage(Uint8List.fromList(details.picture!)),
                    ))),
      if (details.names.isNotEmpty)
        detailsList<String>(
          details.names.values.toList(),
          title: const Text('Names'),
          getValue: (v) => v,
          // This doesn't do anything when hideLabel, maybe it can be optional
          getLabel: (v) => v,
          hideLabel: true,
        ),
      if (details.phones.isNotEmpty)
        detailsList<flutter_contacts.Phone>(
          details.phones,
          title: const Text('Phones'),
          getLabel: (v) =>
              (v.label.name != 'custom') ? v.label.name : v.customLabel,
          getValue: (v) => v.number,
        ),
      if (details.emails.isNotEmpty)
        detailsList<flutter_contacts.Email>(
          details.emails,
          title: const Text('E-Mails'),
          getLabel: (v) =>
              (v.label.name != 'custom') ? v.label.name : v.customLabel,
          getValue: (v) => v.address,
        ),
      if (details.addresses.isNotEmpty)
        detailsList<flutter_contacts.Address>(
          details.addresses,
          title: const Text('Addresses'),
          getLabel: (v) =>
              (v.label.name != 'custom') ? v.label.name : v.customLabel,
          getValue: (v) => v.address,
        ),
      if (details.socialMedias.isNotEmpty)
        detailsList<flutter_contacts.SocialMedia>(
          details.socialMedias,
          title: const Text('Socials'),
          getLabel: (v) =>
              (v.label.name != 'custom') ? v.label.name : v.customLabel,
          getValue: (v) => v.userName,
        ),
      if (details.websites.isNotEmpty)
        detailsList<flutter_contacts.Website>(
          details.websites,
          title: const Text('Websites'),
          getLabel: (v) =>
              (v.label.name != 'custom') ? v.label.name : v.customLabel,
          getValue: (v) => v.url,
        ),
      const Padding(
          padding: EdgeInsets.only(left: 12, right: 12, bottom: 8, top: 4),
          child: Text(
              'Once you are connected, they see the above information based on '
              'the circles you added them to.')),
    ];

Widget _circlesCard(
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
