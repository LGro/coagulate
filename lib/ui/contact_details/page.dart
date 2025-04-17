// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:math';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as flutter_contacts;
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/coag_contact.dart';
import '../../data/models/contact_location.dart';
import '../../data/repositories/contacts.dart';
import '../../ui/profile/cubit.dart';
import '../locations/page.dart';
import '../profile/page.dart';
import '../utils.dart';
import '../widgets/circles/cubit.dart';
import '../widgets/circles/widget.dart';
import '../widgets/dht_status/widget.dart';
import '../widgets/veilid_status/widget.dart';
import 'cubit.dart';
import 'link_to_system_contact/page.dart';

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

class ContactPage extends StatefulWidget {
  const ContactPage({required this.coagContactId, super.key});

  final String coagContactId;

  static Route<void> route(String coagContactId) => MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => ContactPage(coagContactId: coagContactId));

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactCommentController =
      TextEditingController();

  var _isEditingName = false;
  var _dummyToTriggerRebuild = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Trigger a rebuild to make sure that when we edited the name of a contact
    // it shows up in the list up-to-date
    setState(() {
      _dummyToTriggerRebuild = _dummyToTriggerRebuild + 1;
    });
  }

  Future<void> _showDeleteContactDialog(
      CoagContact contact, Future<bool> Function(String) deleteCallback) async {
    var isLoading = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, void Function(void Function()) setState) =>
            AlertDialog(
          titlePadding: const EdgeInsets.only(left: 16, right: 16, top: 16),
          title: Text('Delete ${contact.name}',
              maxLines: 1, overflow: TextOverflow.ellipsis),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(
                [
                  // ignore: no_adjacent_strings_in_list
                  'Deleting this contact from Coagulate can not guarantee '
                      'that all information that you shared with them is '
                      'removed on their side, because they might have '
                      'taken a screenshot or retain your info otherwise. '
                      'It will only ensure that none of your future '
                      'updates will be shared with them. ',
                  if (contact.systemContactId != null)
                    // ignore: no_adjacent_strings_in_list
                    'The linked contact in your local address book will '
                        'remain, but it will no longer be updated by '
                        'Coagulate.',
                ].join(),
                softWrap: true),
            const SizedBox(height: 16),
          ]),
          actions: isLoading
              ? <Widget>[const Center(child: CircularProgressIndicator())]
              : <Widget>[
                  FilledButton.tonal(
                    onPressed: Navigator.of(dialogContext).pop,
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () async {
                      setState(() => isLoading = true);
                      final dhtSuccess =
                          await deleteCallback(contact.coagContactId);
                      if (context.mounted && !dhtSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Could not clear shared '
                                  'information. Make sure you '
                                  'are online and try again.')),
                        );
                        setState(() => isLoading = false);
                        return;
                      }
                      if (dialogContext.mounted) {
                        dialogContext.pop();
                      }
                      if (context.mounted) {
                        context.goNamed('contacts');
                      }
                    },
                    child: const Text('Delete'),
                  ),
                ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) => ContactDetailsCubit(
                  context.read<ContactsRepository>(), widget.coagContactId)),
          BlocProvider(
              create: (context) =>
                  ProfileCubit(context.read<ContactsRepository>())),
        ],
        child: BlocConsumer<ContactDetailsCubit, ContactDetailsState>(
          listener: (context, state) async {},
          builder: (context, state) => Scaffold(
            appBar: AppBar(
              title: _isEditingName
                  ? TextField(
                      autofocus: true,
                      autocorrect: false,
                      controller: _nameController
                        ..text = state.contact?.name ?? '',
                      decoration: const InputDecoration(isDense: true),
                    )
                  : Text(state.contact?.name ?? 'Contact Details'),
              actions: [
                IconButton(
                    onPressed: () async {
                      if (_isEditingName) {
                        await context
                            .read<ContactDetailsCubit>()
                            .updateName(_nameController.text);
                      }
                      setState(() {
                        _isEditingName = !_isEditingName;
                      });
                    },
                    icon: Icon(_isEditingName ? Icons.save : Icons.edit))
              ],
            ),
            body: (state.contact == null)
                ? const SingleChildScrollView(child: Text('Contact not found.'))
                : RefreshIndicator(
                    onRefresh: () async => context
                        .read<ContactDetailsCubit>()
                        .refresh()
                        .then((success) => context.mounted
                            ? (success
                                ? ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Successfully refreshed!')))
                                : ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                    content: Text(
                                        'Refreshing failed, try again later!'),
                                  )))
                            : null),
                    child: _body(context, state.contact!, state.circleNames,
                        state.knownContacts),
                  ),
          ),
        ),
      );

  Widget _body(BuildContext context, CoagContact contact,
          List<String> circleNames, Map<String, String> knownContacts) =>
      SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (contact.details?.picture != null)
          Center(
              child: Padding(
            padding: const EdgeInsets.only(left: 12, top: 16, right: 12),
            child:
                roundPictureOrPlaceholder(contact.details?.picture, radius: 64),
          )),

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

        // TODO: Display note about which contact is linked?
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 12, right: 16),
          child: (contact.systemContactId == null)
              ? FilledButton.tonal(
                  onPressed: () async => Navigator.of(context).push(
                      MaterialPageRoute<LinkToSystemContactPage>(
                          builder: (_) => LinkToSystemContactPage(
                              coagContactId: contact.coagContactId))),
                  child: const Text('Link to address book contact'))
              : FilledButton.tonal(
                  onPressed: () async => context
                      .read<ContactDetailsCubit>()
                      .unlinkFromSystemContact(),
                  child: const Text('Unlink from address book contact')),
        ),

        if (contact.theirPersonalUniqueId != null &&
            contact.knownPersonalContactIds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
                'They are connected with around '
                '${contact.knownPersonalContactIds.length}'
                'other folks via Coagulate, including the following ones you '
                'also know: ${knownContacts.values.asList().join(', ')}',
                softWrap: true),
          ),

        if (contact.introductionsByThem.isNotEmpty)
          Padding(
              padding: const EdgeInsets.all(16),
              child: Text(contact.introductionsByThem
                  .map((i) => i.otherName)
                  .join(', '))),

        if (contact.introductionsForThem.isNotEmpty)
          Padding(
              padding: const EdgeInsets.all(16),
              child: Text(contact.introductionsForThem
                  .map((i) => i.otherName)
                  .join(', '))),

        // Delete contact
        Center(
            child: TextButton(
                onPressed: () async => _showDeleteContactDialog(
                    contact, context.read<ContactDetailsCubit>().delete),
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                      Theme.of(context).colorScheme.error),
                ),
                child: Text(
                  'Delete from Coagulate',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onError),
                ))),

        // Debug output about update timestamps and receive / share DHT records
        if (!kReleaseMode)
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

Future<void> _launchUrl(String url) async {
  final uri = Uri.parse(url);
  try {
    final success = await launchUrl(uri);
  } on PlatformException {
    // TODO: Give feedback?
  }
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
        ...detailsList<String>(
          context,
          contact.details!.names.values.toList(),
          getValue: (v) => v,
          // This doesn't do anything when hideLabel, maybe it can be optional
          getLabel: (v) => v,
          hideLabel: true,
        ),
      if (contact.details?.phones.isNotEmpty ?? false)
        ...detailsList<flutter_contacts.Phone>(
          context,
          contact.details!.phones,
          getLabel: (v) =>
              (v.label.name != 'custom') ? v.label.name : v.customLabel,
          getValue: (v) => v.number,
          hideEditButton: true,
          editCallback: (i) async =>
              _launchUrl('tel:${contact.details!.phones[i].number}'),
        ),
      if (contact.details?.emails.isNotEmpty ?? false)
        ...detailsList<flutter_contacts.Email>(
          context,
          contact.details!.emails,
          getLabel: (v) =>
              (v.label.name != 'custom') ? v.label.name : v.customLabel,
          getValue: (v) => v.address,
          hideEditButton: true,
          editCallback: (i) async =>
              _launchUrl('mailto:${contact.details!.emails[i].address}'),
        ),
      if (contact.details?.addresses.isNotEmpty ?? false)
        ...detailsList<flutter_contacts.Address>(
          context,
          contact.details!.addresses,
          getLabel: (v) =>
              (v.label.name != 'custom') ? v.label.name : v.customLabel,
          getValue: (v) => v.address,
        ),
      if (contact.details?.socialMedias.isNotEmpty ?? false)
        ...detailsList<flutter_contacts.SocialMedia>(
          context,
          contact.details!.socialMedias,
          getLabel: (v) =>
              (v.label.name != 'custom') ? v.label.name : v.customLabel,
          getValue: (v) => v.userName,
        ),
      if (contact.details?.websites.isNotEmpty ?? false)
        ...detailsList<flutter_contacts.Website>(
          context,
          contact.details!.websites,
          getLabel: (v) =>
              (v.label.name != 'custom') ? v.label.name : v.customLabel,
          getValue: (v) => v.url,
          hideEditButton: true,
          editCallback: (i) async => _launchUrl(
              contact.details!.websites[i].url.startsWith('http')
                  ? contact.details!.websites[i].url
                  : 'https://${contact.details!.websites[i].url}'),
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
      if (contact.dhtSettings.recordKeyMeSharing == null ||
          contact.details == null) ...[
        _paddedDivider(),
        _connectingCard(context, contact),
      ],
      if (circleNames.isNotEmpty && contact.sharedProfile != null) ...[
        _paddedDivider(),
        ..._displaySharedProfile(context, contact.sharedProfile!.details),
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
        Widget title, Map<String, ContactTemporaryLocation> locations) =>
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: const EdgeInsets.only(left: 12, right: 12, top: 8),
          child: title),
      Padding(
          padding: const EdgeInsets.only(left: 4, right: 4, top: 4),
          child: Card(
              child: Column(
                  children: locations.values
                      .where((l) => l.end.isAfter(DateTime.now()))
                      .map((l) => Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, bottom: 4),
                          child: locationTile(l)))
                      .asList())))
    ]);

Widget _connectingCard(BuildContext context, CoagContact contact) => Padding(
    padding: const EdgeInsets.only(left: 12, right: 12, top: 8),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.private_connectivity),
        const SizedBox(width: 4),
        Expanded(
            child: Text('To connect with ${contact.name}:',
                textScaler: const TextScaler.linear(1.2), softWrap: true))
      ]),
      const SizedBox(height: 4),
      if (showSharingInitializing(contact)) ...[
        const Text(
            'Please wait a moment until sharing options are initialized.'),
        const SizedBox(height: 4),
        const Center(child: CircularProgressIndicator())
      ] else if (showSharingOffer(contact)) ...[
        const Text('You added them from their profile link. To finish '
            'connecting, send them this link via your favorite messenger:'),
        Row(children: [
          Expanded(
              child: Text(
                  profileBasedOfferUrl(
                          contact.sharedProfile!.details.names.values
                                  .firstOrNull ??
                              '???',
                          contact.dhtSettings.recordKeyMeSharing!,
                          contact.dhtSettings.myKeyPair.key)
                      .toString(),
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis)),
          IconButton(
              onPressed: () async => Share.share(profileBasedOfferUrl(
                      contact.sharedProfile!.details.names.values.firstOrNull ??
                          '???',
                      contact.dhtSettings.recordKeyMeSharing!,
                      contact.dhtSettings.myKeyPair.key)
                  .toString()),
              icon: const Icon(Icons.copy)),
        ])
      ] else if (showDirectSharing(contact)) ...[
        const SizedBox(height: 4),
        // TODO: Only show share back button when receiving key and psk but not writer are set i.e. is receiving updates and has share back settings
        _qrCodeButton(context,
            buttonText: 'Show them this QR code',
            alertTitle: 'Show to ${contact.name}',
            qrCodeData: directSharingUrl(
                    contact.sharedProfile!.details.names.values.firstOrNull ??
                        '???',
                    contact.dhtSettings.recordKeyMeSharing!,
                    contact.dhtSettings.initialSecret!)
                .toString()),
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
        TextButton(
          child: const Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Icon(Icons.share),
            SizedBox(width: 8),
            Text('Share link via trusted channel'),
            SizedBox(width: 4),
          ]),
          // TODO: Add warning dialogue that the link contains a secret and should only be transmitted via an end to end encrypted messenger
          onPressed: () async => Share.share(
              "Hi ${contact.name}, I'd like to share with you: "
              '${directSharingUrl(contact.sharedProfile!.details.names.values.firstOrNull ?? '???', contact.dhtSettings.recordKeyMeSharing!, contact.dhtSettings.initialSecret!)}\n'
              "Keep this link a secret, it's just for you."),
        ),
        const SizedBox(height: 4),
        // TODO: Link "create an invite" to the corresponding page, and maybe also "contact page" to contacts list?
        Text('This QR code and link are specifically for ${contact.name}. '
            'If you want to connect with someone else, go to their '
            'respective contact details or create a new invite.'),
      ] else
        const Text(
            'Something unexpected happened, please reach out to the Coagulate '
            'team with information about how you got here.'),
      const SizedBox(height: 8),
    ]));

Iterable<Widget> _displaySharedProfile(
        BuildContext context, ContactDetails details) =>
    [
      const Padding(
          padding: EdgeInsets.only(top: 8, left: 12, right: 12, bottom: 8),
          child: Row(children: [
            Icon(Icons.contact_page),
            SizedBox(width: 4),
            Text('Shared profile', textScaler: TextScaler.linear(1.2))
          ])),
      if (details.picture != null)
        Center(
            child: Padding(
                padding: const EdgeInsets.only(left: 12, top: 4, right: 12),
                child: roundPictureOrPlaceholder(details.picture, radius: 48))),
      if (details.names.isNotEmpty)
        ...detailsList<String>(
          context,
          details.names.values.toList(),
          getValue: (v) => v,
          // This doesn't do anything when hideLabel, maybe it can be optional
          getLabel: (v) => v,
          hideLabel: true,
        ),
      if (details.phones.isNotEmpty)
        ...detailsList<flutter_contacts.Phone>(
          context,
          details.phones,
          getLabel: (v) =>
              (v.label.name != 'custom') ? v.label.name : v.customLabel,
          getValue: (v) => v.number,
        ),
      if (details.emails.isNotEmpty)
        ...detailsList<flutter_contacts.Email>(
          context,
          details.emails,
          getLabel: (v) =>
              (v.label.name != 'custom') ? v.label.name : v.customLabel,
          getValue: (v) => v.address,
        ),
      if (details.addresses.isNotEmpty)
        ...detailsList<flutter_contacts.Address>(
          context,
          details.addresses,
          getLabel: (v) =>
              (v.label.name != 'custom') ? v.label.name : v.customLabel,
          getValue: (v) => v.address,
        ),
      if (details.socialMedias.isNotEmpty)
        ...detailsList<flutter_contacts.SocialMedia>(
          context,
          details.socialMedias,
          getLabel: (v) =>
              (v.label.name != 'custom') ? v.label.name : v.customLabel,
          getValue: (v) => v.userName,
        ),
      if (details.websites.isNotEmpty)
        ...detailsList<flutter_contacts.Website>(
          context,
          details.websites,
          getLabel: (v) =>
              (v.label.name != 'custom') ? v.label.name : v.customLabel,
          getValue: (v) => v.url,
        ),
      // TODO: Check if opted out
      const Padding(
          padding: EdgeInsets.only(left: 12, right: 12, bottom: 8, top: 4),
          child: Text(
              'They also see how many contacts you are connected with, but can '
              'only find out who an individual contact is if they are '
              'connected with them as well and only see the information that '
              'contact shared with them.')),
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
            Icon(Icons.bubble_chart_outlined),
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
