// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:math';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/coag_contact.dart';
import '../../data/models/contact_location.dart';
import '../../data/repositories/contacts.dart';
import '../../ui/profile/cubit.dart';
import '../introductions/page.dart';
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

int numberContactsShared(Iterable<Iterable<String>> circleMembersips,
        Iterable<String> circles) =>
    circleMembersips
        .where((c) => c.asSet().intersectsWith(circles.asSet()))
        .length;

Widget locationTile(BuildContext context, ContactTemporaryLocation location,
        {Map<String, List<String>>? circleMembersips,
        Future<void> Function()? onTap}) =>
    ListTile(
        title: Text(location.name),
        contentPadding: EdgeInsets.zero,
        onTap: onTap,
        subtitle:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
              'From: ${DateFormat.yMd(Localizations.localeOf(context).languageCode).format(location.start)}'),
          if (location.end != location.start)
            Text(
                'Till: ${DateFormat.yMd(Localizations.localeOf(context).languageCode).format(location.end)}'),
          // Text('Lon: ${location.longitude.toStringAsFixed(4)}, '
          //     'Lat: ${location.latitude.toStringAsFixed(4)}'),
          if (circleMembersips != null)
            Text(
                'Shared with ${numberContactsShared(circleMembersips.values, location.circles)} '
                'contact${(numberContactsShared(circleMembersips.values, location.circles) == 1) ? '' : 's'}'),
          if (location.details.isNotEmpty) Text(location.details),
        ]),
        trailing:
            // TODO: Better icon to indicate checked in
            (location.checkedIn && DateTime.now().isBefore(location.end))
                ? const Icon(Icons.pin_drop_outlined)
                : null);

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
                            ? ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(
                                    content: Text([
                                if (success.$1)
                                  'Updated contact successfully.'
                                else
                                  'Updating contact failed, try again later.',
                                if (success.$2)
                                  'Updated shared information successfully.'
                                else
                                  'Updating shared information failed, try again later.'
                              ].join('\n'))))
                            : null),
                    child: _body(context, state.contact!, state.circles,
                        state.knownContacts),
                  ),
          ),
        ),
      );

  Widget _body(BuildContext context, CoagContact contact,
          Map<String, String> circles, Map<String, String> knownContacts) =>
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
            child: _sharingSettings(context, contact, circles)),

        // Introductions
        if (contact.introductionsByThem.isNotEmpty ||
            contact.introductionsForThem.isNotEmpty) ...[
          Padding(
              padding:
                  const EdgeInsets.only(left: 12, top: 8, right: 12, bottom: 4),
              child: Text('Introductions',
                  textScaler: const TextScaler.linear(1.4),
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 12, right: 12, top: 8, bottom: 8),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (contact.theirPersonalUniqueId != null)
                        Text(
                            [
                              '${contact.name} is connected with at least',
                              '${contact.knownPersonalContactIds.length} other',
                              'folks via Coagulate.',
                              if (knownContacts.isNotEmpty) ...[
                                'Including the following ones you also know:',
                                knownContacts.values.asList().join(', '),
                              ],
                            ].join(' '),
                            softWrap: true),
                      if (contact.introductionsForThem.isNotEmpty)
                        Text('You have introduced them to: '
                            '${contact.introductionsForThem.map((i) => i.otherName).join(', ')}'),
                      if (contact.introductionsByThem.isNotEmpty)
                        Text('They have introduced you to: '
                            '${contact.introductionsByThem.map((i) => i.otherName).join(', ')}'),
                      if (pendingIntroductions([contact]).isNotEmpty)
                        Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: FilledButton.tonal(
                                onPressed: () async => Navigator.of(context)
                                    .push(MaterialPageRoute<IntroductionsPage>(
                                        builder: (context) =>
                                            const IntroductionsPage())),
                                child:
                                    const Text('View pending introductions'))),
                    ]),
              ),
            ),
          )
        ],

        // Private note
        Padding(
            padding: const EdgeInsets.only(left: 12, top: 12, right: 12),
            child: Text('Private note',
                textScaler: const TextScaler.linear(1.4),
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary))),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Card(
                child: Padding(
                    padding: const EdgeInsets.only(
                        left: 12, right: 12, top: 12, bottom: 8),
                    child: TextFormField(
                      key: const Key('contactDetailsNoteInput'),

                      onTapOutside: (event) async => context
                          .read<ContactDetailsCubit>()
                          .updateComment(_contactCommentController.text),
                      controller: _contactCommentController
                        ..text = contact.comment,
                      decoration: const InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(),
                        helperText:
                            'This note is just for you and never shared with '
                            'anyone else.',
                      ),
                      textInputAction: TextInputAction.done,
                      // TODO: Does this limit the number of lines or just
                      // specify the visible ones? We need the latter not the
                      // former.
                      maxLines: 4,
                    )))),

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
        // if (!kReleaseMode)
        Column(children: [
          const SizedBox(height: 16),
          const Text('Developer debug information',
              textScaler: TextScaler.linear(1.2)),
          const SizedBox(height: 8),
          const VeilidStatusWidget(statusWidgets: {}),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
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
            ],
          ),
          // const SizedBox(height: 8),
          // Text('Updated: ${contact.mostRecentUpdate}'),
          // Text('Changed: ${contact.mostRecentChange}'),
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
                '${contact.name} shares with you shows up here.'))
      else if (contact.details!.names.isEmpty &&
          contact.details!.phones.isEmpty &&
          contact.details!.emails.isEmpty &&
          contact.addressLocations.isEmpty &&
          contact.details!.socialMedias.isEmpty &&
          contact.details!.events.isEmpty &&
          contact.details!.websites.isEmpty)
        Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child:
                Text('It looks like ${contact.name} has not shared any contact '
                    'details with you yet.')),

      // Contact details
      if (contact.details?.names.isNotEmpty ?? false)
        ...detailsList(
          context,
          contact.details!.names,
          hideLabel: true,
        ),
      if (contact.details?.phones.isNotEmpty ?? false)
        ...detailsList(
          context,
          contact.details!.phones,
          hideEditButton: true,
          editCallback: (label) async =>
              _launchUrl('tel:${contact.details!.phones[label]}'),
        ),
      if (contact.details?.emails.isNotEmpty ?? false)
        ...detailsList(
          context,
          contact.details!.emails,
          hideEditButton: true,
          editCallback: (label) async =>
              _launchUrl('mailto:${contact.details!.emails[label]}'),
        ),
      if (contact.addressLocations.isNotEmpty)
        ...detailsList(
          context,
          contact.addressLocations.map(
              (label, a) => MapEntry(label, commasToNewlines(a.address ?? ''))),
        ),
      if (contact.details?.socialMedias.isNotEmpty ?? false)
        ...detailsList(
          context,
          contact.details!.socialMedias,
        ),
      if (contact.details?.websites.isNotEmpty ?? false)
        ...detailsList(
          context,
          contact.details!.websites,
          hideEditButton: true,
          editCallback: (label) async => _launchUrl(
              (contact.details!.websites[label] ?? '').startsWith('http')
                  ? contact.details!.websites[label] ?? ''
                  : 'https://${contact.details!.websites[label]}'),
        ),
      if (contact.details?.events.isNotEmpty ?? false)
        ...detailsList(
          context,
          contact.details!.events.map((label, date) => MapEntry(
              label,
              DateFormat.yMd(Localizations.localeOf(context).languageCode)
                  .format(date))),
          hideEditButton: true,
        ),

      // Locations
      if (contact.temporaryLocations.isNotEmpty)
        _temporaryLocationsCard(
            context,
            Text('Locations',
                textScaler: const TextScaler.linear(1.4),
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary)),
            contact.temporaryLocations),
    ];

Widget _paddedDivider() => const Padding(
    padding: EdgeInsets.only(left: 16, right: 16), child: Divider());

Widget _sharingSettings(BuildContext context, CoagContact contact,
        Map<String, String> circles) =>
    Card(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _circlesCard(context, contact.coagContactId, circles.values.toList()),
      if ((contact.dhtSettings.recordKeyMeSharing == null ||
              contact.details == null) &&
          context.read<ContactDetailsCubit>().wasNotIntroduced(contact)) ...[
        _paddedDivider(),
        _connectingCard(context, contact, circles),
      ],
      if (circles.isNotEmpty && contact.sharedProfile != null) ...[
        _paddedDivider(),
        ..._displaySharedProfile(context, contact.sharedProfile!.details,
            contact.sharedProfile!.addressLocations),
      ],
      if (contact.sharedProfile?.temporaryLocations.isNotEmpty ?? false) ...[
        _paddedDivider(),
        _temporaryLocationsCard(
            context,
            const Row(children: [
              Icon(Icons.share_location),
              SizedBox(width: 8),
              Text('Shared locations', textScaler: TextScaler.linear(1.2))
            ]),
            contact.sharedProfile!.temporaryLocations),
        Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
            child: Text('These current and future locations are available to '
                '${contact.name} based on the circles you shared the '
                'locations with.')),
      ],
    ]));

Widget _temporaryLocationsCard(BuildContext context, Widget title,
        Map<String, ContactTemporaryLocation> locations) =>
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
                          child: locationTile(context, l)))
                      .asList())))
    ]);

Widget _connectingCard(BuildContext context, CoagContact contact,
        Map<String, String> circles) =>
    Padding(
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
          if (showSharingInitializing(contact) &&
              circles.keys
                  .where((cId) => cId.startsWith('VLD'))
                  .isNotEmpty) ...[
            Text('${contact.name} was added automatically via a batch that '
                'you were both invited from. You will be automatically '
                'connected in a moment. You can already go to the circle '
                'settings to decide what to share with ${contact.name} and '
                'others joining via that batch.'),
          ] else if (showSharingInitializing(contact)) ...[
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
                              contact.sharedProfile?.details.names.values
                                      .firstOrNull ??
                                  '???',
                              contact.dhtSettings.recordKeyMeSharing!,
                              contact.dhtSettings.myKeyPair.key)
                          .toString(),
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis)),
              IconButton(
                  onPressed: () async => SharePlus.instance.share(ShareParams(
                      uri: profileBasedOfferUrl(
                          contact.sharedProfile?.details.names.values
                                  .firstOrNull ??
                              '???',
                          contact.dhtSettings.recordKeyMeSharing!,
                          contact.dhtSettings.myKeyPair.key))),
                  icon: const Icon(Icons.copy)),
            ])
          ] else if (showDirectSharing(contact)) ...[
            const SizedBox(height: 4),
            // TODO: Only show share back button when receiving key and psk but not writer are set i.e. is receiving updates and has share back settings
            _qrCodeButton(context,
                buttonText: 'Show them this QR code',
                alertTitle: 'Show to ${contact.name}',
                qrCodeData: directSharingUrl(
                        contact.sharedProfile?.details.names.values
                                .firstOrNull ??
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
              child:
                  const Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                Icon(Icons.share),
                SizedBox(width: 8),
                Text('Share link via trusted channel'),
                SizedBox(width: 4),
              ]),
              // TODO: Add warning dialogue that the link contains a secret and should only be transmitted via an end to end encrypted messenger
              onPressed: () async => SharePlus.instance.share(ShareParams(
                  text: "Hi ${contact.name}, I'd like to share with you: "
                      '${directSharingUrl(contact.sharedProfile?.details.names.values.firstOrNull ?? '???', contact.dhtSettings.recordKeyMeSharing!, contact.dhtSettings.initialSecret!)}\n'
                      "Keep this link a secret, it's just for you.")),
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
        BuildContext context,
        ContactDetails details,
        Map<String, ContactAddressLocation> addressLocations) =>
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
        ...detailsList(context, details.names, hideLabel: true),
      if (details.phones.isNotEmpty) ...detailsList(context, details.phones),
      if (details.emails.isNotEmpty) ...detailsList(context, details.emails),
      if (addressLocations.isNotEmpty)
        ...detailsList(
            context,
            addressLocations.map((label, address) =>
                MapEntry(label, commasToNewlines(address.address ?? '')))),
      if (details.socialMedias.isNotEmpty)
        ...detailsList(context, details.socialMedias),
      if (details.websites.isNotEmpty)
        ...detailsList(context, details.websites),
      if (details.events.isNotEmpty)
        ...detailsList(
          context,
          details.events.map((label, date) => MapEntry(
              label,
              DateFormat.yMd(Localizations.localeOf(context).languageCode)
                  .format(date))),
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
                builder: (modalContext) => DraggableScrollableSheet(
                  expand: false,
                  maxChildSize: 0.90,
                  builder: (_, scrollController) => SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
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
                                      callback:
                                          context.read<CirclesCubit>().update)))
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ]),
          const Text(
              'The selected circles determine which of your contact details '
              'and locations they can see.'),
        ]));
