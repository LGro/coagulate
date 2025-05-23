// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../data/models/coag_contact.dart';
import '../../data/repositories/contacts.dart';
import '../contact_details/page.dart';
import '../profile/page.dart';
import '../utils.dart';
import '../widgets/searchable_list.dart';
import 'cubit.dart';

List<Widget> _card(Text title, List<Widget> children) => [
      Row(children: <Widget>[
        Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 4),
            child: title)
      ]),
      Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children))
    ];

Widget contactsListView(
        BuildContext context,
        String circleId,
        List<CoagContact> contacts,
        Map<String, List<String>> circleMemberships,
        void Function(String, bool) updateCircleMembership) =>
    SearchableList<CoagContact>(
        items: contacts,
        buildItemWidget: (contact) => CheckboxListTile(
            value:
                circleMemberships[contact.coagContactId]?.contains(circleId) ??
                    false,
            title: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async => Navigator.of(context)
                  .push(ContactPage.route(contact.coagContactId)),
              child: Row(children: [
                roundPictureOrPlaceholder(contact.details?.picture, radius: 18),
                const SizedBox(width: 8),
                Text(contact.name)
              ]),
            ),
            onChanged: (checked) => updateCircleMembership(
                contact.coagContactId, checked ?? false)),
        matchesItem: searchMatchesContact);

List<Widget> detailsList(
  BuildContext context,
  Map<String, String> details, {
  required Text title,
  required String circleId,
  required List<String>? Function(String label) getDetailSharingSettings,
  Map<String, String>? circles,
  Map<String, List<String>>? circleMemberships,
  void Function(String label, bool doShare)? editCallback,
  VoidCallback? addCallback,
  bool hideLabel = false,
}) =>
    _card(
        title,
        details
                .map((label, value) => MapEntry<String, Widget>(
                    label,
                    CheckboxListTile(
                        value: getDetailSharingSettings(label)
                                ?.contains(circleId) ??
                            false,
                        onChanged: (editCallback == null)
                            ? null
                            : (checked) =>
                                editCallback(label, checked ?? false),
                        title: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    if (!hideLabel)
                                      Text(label,
                                          textScaler:
                                              const TextScaler.linear(0.9)),
                                    Text(value,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        textScaler:
                                            const TextScaler.linear(1.1)),
                                  ])),
                            ]))))
                .values
                .asList() +
            [
              if (addCallback != null)
                Center(
                    child: IconButton.filledTonal(
                        onPressed: addCallback, icon: const Icon(Icons.add)))
            ]);

Future<void> updateSharedInformationWithCircle(
    {required CircleDetailsState state,
    required Map<String, List<String>> detailSharingSettings,
    required String label,
    required bool doShare,
    required Future<void> Function(
            Map<String, List<String>> detailSharingSettings)
        updateDetailSharingSettings}) async {
  if (state.profileInfo == null || state.circleId == null) {
    return;
  }

  final _detailSharingSettings = {...detailSharingSettings};
  _detailSharingSettings[label] = doShare
      ? [...(detailSharingSettings[label] ?? []), state.circleId!]
      : ([...(detailSharingSettings[label] ?? [])]..remove(state.circleId));

  await updateDetailSharingSettings(_detailSharingSettings);
}

// Filter out duplicates, ensure to keep picture belonging to circleId
Map<String, List<int>> filterCirclePictureDuplicates(
    String circleId, Map<String, List<int>> pictures) {
  final filtered = <String, List<int>>{};
  if (pictures.containsKey(circleId)) {
    // TODO: Is copying here safer?
    filtered[circleId] = pictures[circleId]!;
  }
  for (final p in pictures.entries) {
    if (!filtered.values.contains(p.value)) {
      filtered[p.key] = p.value;
    }
  }
  return filtered;
}

Widget _pictureSelection(BuildContext context, CircleDetailsState state) =>
    Row(children: [
      GestureDetector(
          onTap: () async => pickCirclePicture(
              context, context.read<CircleDetailsCubit>().updateCirclePicture),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: state.profileInfo!.pictures.containsKey(state.circleId)
                ? Column(children: [
                    roundPictureOrPlaceholder(
                        state.profileInfo!.pictures[state.circleId],
                        radius: 48),
                    const SizedBox(height: 4),
                    FilledButton.tonal(
                        style: const ButtonStyle(
                            visualDensity: VisualDensity.compact),
                        onPressed: () async => context
                            .read<CircleDetailsCubit>()
                            .updateCirclePicture(null),
                        child: const Text('Remove')),
                  ])
                : const CircleAvatar(radius: 48, child: Icon(Icons.add)),
          )),
      const SizedBox(width: 8),
      Expanded(
          child: Text(context.loc.profilePictureExplainer, softWrap: true)),
    ]);

Widget _sharedInformationList(BuildContext context, CircleDetailsState state) =>
    Column(children: [
      if (state.profileInfo!.details.names.isNotEmpty)
        ...detailsList(
          context,
          state.profileInfo!.details.names,
          circleId: state.circleId!,
          title: Text(context.loc.names.capitalize(),
              textScaler: const TextScaler.linear(1.4),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary)),
          hideLabel: true,
          getDetailSharingSettings: (l) =>
              state.profileInfo!.sharingSettings.names[l],
          circles: state.circles,
          circleMemberships: state.circleMemberships,
          editCallback: (label, doShare) async =>
              updateSharedInformationWithCircle(
                  state: state,
                  detailSharingSettings: {
                    ...state.profileInfo!.sharingSettings.names
                  },
                  label: label,
                  doShare: doShare,
                  updateDetailSharingSettings: (sharingSettings) async =>
                      context
                          .read<CircleDetailsCubit>()
                          .contactsRepository
                          .setProfileInfo(state.profileInfo!.copyWith(
                              sharingSettings: state
                                  .profileInfo!.sharingSettings
                                  .copyWith(names: sharingSettings)))),
        ),
      if (state.profileInfo!.details.phones.isNotEmpty)
        ...detailsList(
          context,
          state.profileInfo!.details.phones,
          circleId: state.circleId!,
          title: Text(context.loc.phones.capitalize(),
              textScaler: const TextScaler.linear(1.4),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary)),
          getDetailSharingSettings: (l) =>
              state.profileInfo!.sharingSettings.phones[l],
          circles: state.circles,
          circleMemberships: state.circleMemberships,
          editCallback: (label, doShare) async =>
              updateSharedInformationWithCircle(
                  state: state,
                  detailSharingSettings: {
                    ...state.profileInfo!.sharingSettings.phones
                  },
                  label: label,
                  doShare: doShare,
                  updateDetailSharingSettings: (sharingSettings) async =>
                      context
                          .read<CircleDetailsCubit>()
                          .contactsRepository
                          .setProfileInfo(state.profileInfo!.copyWith(
                              sharingSettings: state
                                  .profileInfo!.sharingSettings
                                  .copyWith(phones: sharingSettings)))),
        ),
      if (state.profileInfo!.details.emails.isNotEmpty)
        ...detailsList(
          context,
          state.profileInfo!.details.emails,
          circleId: state.circleId!,
          title: Text(context.loc.emails.capitalize(),
              textScaler: const TextScaler.linear(1.4),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary)),
          getDetailSharingSettings: (l) =>
              state.profileInfo!.sharingSettings.emails[l],
          circles: state.circles,
          circleMemberships: state.circleMemberships,
          editCallback: (label, doShare) async =>
              updateSharedInformationWithCircle(
                  state: state,
                  detailSharingSettings: {
                    ...state.profileInfo!.sharingSettings.emails
                  },
                  label: label,
                  doShare: doShare,
                  updateDetailSharingSettings: (sharingSettings) async =>
                      context
                          .read<CircleDetailsCubit>()
                          .contactsRepository
                          .setProfileInfo(state.profileInfo!.copyWith(
                              sharingSettings: state
                                  .profileInfo!.sharingSettings
                                  .copyWith(emails: sharingSettings)))),
        ),
      if (state.profileInfo!.addressLocations.isNotEmpty)
        ...detailsList(
          context,
          state.profileInfo!.addressLocations.map(
              (label, a) => MapEntry(label, commasToNewlines(a.address ?? ''))),
          circleId: state.circleId!,
          title: Text(context.loc.addresses.capitalize(),
              textScaler: const TextScaler.linear(1.4),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary)),
          getDetailSharingSettings: (l) =>
              state.profileInfo!.sharingSettings.addresses[l],
          circles: state.circles,
          circleMemberships: state.circleMemberships,
          editCallback: (label, doShare) async =>
              updateSharedInformationWithCircle(
                  state: state,
                  detailSharingSettings: {
                    ...state.profileInfo!.sharingSettings.addresses
                  },
                  label: label,
                  doShare: doShare,
                  updateDetailSharingSettings: (sharingSettings) async =>
                      context
                          .read<CircleDetailsCubit>()
                          .contactsRepository
                          .setProfileInfo(state.profileInfo!.copyWith(
                              sharingSettings: state
                                  .profileInfo!.sharingSettings
                                  .copyWith(addresses: sharingSettings)))),
        ),
      if (state.profileInfo!.details.socialMedias.isNotEmpty)
        ...detailsList(
          context,
          state.profileInfo!.details.socialMedias,
          circleId: state.circleId!,
          title: Text('Socials',
              textScaler: const TextScaler.linear(1.4),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary)),
          getDetailSharingSettings: (l) =>
              state.profileInfo!.sharingSettings.socialMedias[l],
          circles: state.circles,
          circleMemberships: state.circleMemberships,
          editCallback: (label, doShare) async =>
              updateSharedInformationWithCircle(
                  state: state,
                  detailSharingSettings: {
                    ...state.profileInfo!.sharingSettings.socialMedias
                  },
                  label: label,
                  doShare: doShare,
                  updateDetailSharingSettings: (sharingSettings) async =>
                      context
                          .read<CircleDetailsCubit>()
                          .contactsRepository
                          .setProfileInfo(state.profileInfo!.copyWith(
                              sharingSettings: state
                                  .profileInfo!.sharingSettings
                                  .copyWith(socialMedias: sharingSettings)))),
        ),
      if (state.profileInfo!.details.websites.isNotEmpty)
        ...detailsList(
          context,
          state.profileInfo!.details.websites,
          circleId: state.circleId!,
          title: Text(context.loc.websites.capitalize(),
              textScaler: const TextScaler.linear(1.4),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary)),
          getDetailSharingSettings: (l) =>
              state.profileInfo!.sharingSettings.websites[l],
          circles: state.circles,
          circleMemberships: state.circleMemberships,
          editCallback: (label, doShare) async =>
              updateSharedInformationWithCircle(
                  state: state,
                  detailSharingSettings: {
                    ...state.profileInfo!.sharingSettings.websites
                  },
                  label: label,
                  doShare: doShare,
                  updateDetailSharingSettings: (sharingSettings) async =>
                      context
                          .read<CircleDetailsCubit>()
                          .contactsRepository
                          .setProfileInfo(state.profileInfo!.copyWith(
                              sharingSettings: state
                                  .profileInfo!.sharingSettings
                                  .copyWith(websites: sharingSettings)))),
        ),
      if (state.profileInfo!.details.events.isNotEmpty)
        ...detailsList(
          context,
          state.profileInfo!.details.events.map((label, date) => MapEntry(
              label,
              DateFormat.yMd(Localizations.localeOf(context).languageCode)
                  .format(date))),
          circleId: state.circleId!,
          title: Text('Dates',
              textScaler: const TextScaler.linear(1.4),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary)),
          getDetailSharingSettings: (l) =>
              state.profileInfo!.sharingSettings.events[l],
          circles: state.circles,
          circleMemberships: state.circleMemberships,
          editCallback: (label, doShare) async =>
              updateSharedInformationWithCircle(
                  state: state,
                  detailSharingSettings: {
                    ...state.profileInfo!.sharingSettings.events
                  },
                  label: label,
                  doShare: doShare,
                  updateDetailSharingSettings: (sharingSettings) async =>
                      context
                          .read<CircleDetailsCubit>()
                          .contactsRepository
                          .setProfileInfo(state.profileInfo!.copyWith(
                              sharingSettings: state
                                  .profileInfo!.sharingSettings
                                  .copyWith(events: sharingSettings)))),
        ),
      if (state.profileInfo?.pictures != null)
        ..._card(
            Text('Picture',
                textScaler: const TextScaler.linear(1.4),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary)),
            [
              Padding(
                  padding: const EdgeInsets.only(
                      top: 8, left: 8, right: 8, bottom: 4),
                  child: _pictureSelection(context, state))
            ]),
      if (state.profileInfo?.temporaryLocations.isNotEmpty ?? false)
        ..._card(
            Text('Locations',
                textScaler: const TextScaler.linear(1.4),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary)),
            // TODO: Is this the right kind of filtering?
            filterTemporaryLocations(state.profileInfo!.temporaryLocations)
                .entries
                .map((l) => CheckboxListTile(
                    value: l.value.circles.contains(state.circleId),
                    title: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      // TODO: Jump to map centered on location or on edit view?
                      // onTap: () async => Navigator.of(context).push(),
                      child: Row(children: [
                        Expanded(
                            child: Text('${l.value.name}\n${l.value.details}',
                                overflow: TextOverflow.ellipsis, maxLines: 2))
                      ]),
                    ),
                    onChanged: (checked) async => context
                        .read<CircleDetailsCubit>()
                        .updateLocationSharing(l.key, checked ?? false)))
                .toList()),
    ]);

class CircleDetailsPage extends StatefulWidget {
  const CircleDetailsPage({required this.circleId, super.key});

  final String circleId;

  static Route<void> route(String circleId) => MaterialPageRoute(
      builder: (context) => CircleDetailsPage(circleId: circleId));

  @override
  _CircleDetailsPageState createState() => _CircleDetailsPageState();
}

class _CircleDetailsPageState extends State<CircleDetailsPage> {
  @override
  Widget build(BuildContext context) => MultiBlocProvider(
          providers: [
            BlocProvider(
                create: (context) => CircleDetailsCubit(
                    context.read<ContactsRepository>(), widget.circleId)),
          ],
          child: BlocConsumer<CircleDetailsCubit, CircleDetailsState>(
            listener: (context, state) async {},
            builder: (context, state) => Scaffold(
                appBar: AppBar(
                    actions: [
                      IconButton(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Confirm Delete'),
                                // TODO: Check if batch circle and hasn't expired yet, if so warn about the effects
                                content: const Text(
                                    'Are you sure you want to delete this circle?'),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Cancel')),
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text('Delete')),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await context
                                  .read<CircleDetailsCubit>()
                                  .removeCircle();
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            }
                          },
                          icon: const Icon(Icons.delete_forever,
                              color: Colors.red)),
                    ],
                    // Avoid app bar background color changing when parts of
                    // the page scroll up
                    notificationPredicate: (notification) => false,
                    title: (state.circles[state.circleId] == null)
                        ? null
                        : Text(state.circles[state.circleId]!)),
                body: ExpandableScrollViews(context, state)),
          ));
}

class ExpandableScrollViews extends StatefulWidget {
  const ExpandableScrollViews(this.context, this.state, {super.key});

  final BuildContext context;
  final CircleDetailsState state;

  @override
  _ExpandableScrollViewsState createState() => _ExpandableScrollViewsState();
}

class _ExpandableScrollViewsState extends State<ExpandableScrollViews>
    with SingleTickerProviderStateMixin {
  double _topHeight = 0;
  double _bottomHeight = 10000;

  void toggleView(bool expandTop, double maxHeight) {
    // Subtracting the toolbar heights and the size of the sized box
    // NOTE: This is just coincidence that the toolbar and navigation bar are
    //       the correct height to subtract, though, right?
    final height = maxHeight - kToolbarHeight - kBottomNavigationBarHeight - 2;
    setState(() {
      if (expandTop) {
        _topHeight = height;
        _bottomHeight = 0;
      } else {
        _topHeight = 0;
        _bottomHeight = height;
      }
    });
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => toggleView(_topHeight == 0, constraints.maxHeight),
                child: Container(
                    padding: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    child: Row(children: [
                      Expanded(
                          child: Text('Shared information',
                              textScaler: const TextScaler.linear(1.4),
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondaryContainer))),
                      IconButton(
                          onPressed: () => toggleView(
                              _topHeight == 0, constraints.maxHeight),
                          icon: Icon(
                              (_topHeight == 0)
                                  ? Icons.expand_more
                                  : Icons.expand_less,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer)),
                    ])),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                height: _topHeight,
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                    child: Padding(
                        padding:
                            const EdgeInsets.only(top: 10, left: 8, right: 8),
                        child: (widget.state.profileInfo == null)
                            ? const Center(child: CircularProgressIndicator())
                            : _sharedInformationList(
                                widget.context, widget.state))),
              ),
              const SizedBox(height: 2),
              GestureDetector(
                  onTap: () =>
                      toggleView(_topHeight == 0, constraints.maxHeight),
                  child: Container(
                      padding:
                          const EdgeInsets.only(left: 16, top: 4, bottom: 4),
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      child: Row(children: [
                        Expanded(
                            child: Text(
                                'Circle membership '
                                '(${widget.state.circleMemberships.values.where((cIds) => cIds.contains(widget.state.circleId)).length})',
                                textScaler: const TextScaler.linear(1.4),
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer))),
                        IconButton(
                            onPressed: () => toggleView(
                                _topHeight == 0, constraints.maxHeight),
                            icon: Icon(
                                (_bottomHeight == 0)
                                    ? Icons.expand_more
                                    : Icons.expand_less,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer)),
                      ]))),
              // TODO:  Check for expiration date
              // TODO: Get into the animated container so it doesn't mess up our size calculations
              // if (widget.state.circleId?.startsWith('VLD') ?? false) ...[
              //   const Text(
              //       'This circle is linked to a batch of invites. This means that as '
              //       'others use their invites, they will automatically be added '
              //       'here.'),
              //   const SizedBox(height: 8),
              // ],
              AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOut,
                  height: _bottomHeight,
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: (widget.state.circleMemberships.isEmpty &&
                            (widget.state.circleId?.startsWith('VLD') ?? false))
                        ? Container(
                            alignment: Alignment.topCenter,
                            padding: const EdgeInsets.only(
                                top: 6, left: 16, right: 16, bottom: 16),
                            child: const Text(
                                'This circle is linked to an invitation batch. '
                                'When other folks use their invites, they will '
                                'appear here as new contacts and see your '
                                'shared information.'))
                        : contactsListView(
                            context,
                            widget.state.circleId ?? '',
                            widget.state.contacts.toList(),
                            widget.state.circleMemberships,
                            context
                                .read<CircleDetailsCubit>()
                                .updateCircleMembership),
                  )),
            ],
          )));
}
