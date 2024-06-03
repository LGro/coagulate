// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:io';

import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../../data/models/contact_location.dart';
import '../../data/models/profile_sharing_settings.dart';
import '../../data/repositories/contacts.dart';
import '../widgets/address_coordinates_form.dart';
import '../widgets/avatar.dart';
import '../widgets/circles/cubit.dart';
import '../widgets/circles/widget.dart';
import 'cubit.dart';

Future<void> showPickCirclesBottomSheet(
        {required BuildContext context,
        required String label,
        required String coagContactId,
        required List<(String, String, bool)> circles,
        required void Function(List<(String, String)> selectedCircles)
            callback}) async =>
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (modalContext) => Padding(
            padding: EdgeInsets.only(
                left: 16,
                top: 16,
                right: 16,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  BlocProvider(
                      create: (context) => CirclesCubit(
                          context.read<ContactsRepository>(), coagContactId),
                      child: BlocConsumer<CirclesCubit, CirclesState>(
                          listener: (context, state) async {},
                          builder: (context, state) => CirclesForm(
                              customHeader: Row(children: [
                                Padding(
                                    padding: const EdgeInsets.only(
                                        left: 4, bottom: 12),
                                    child: Text('Share "$label" with',
                                        textScaler:
                                            const TextScaler.linear(1.4)))
                              ]),
                              allowCreateNew: true,
                              circles: circles,
                              callback: (circles) async => callback(circles
                                  .where((c) => c.$3)
                                  .map((c) => (c.$1, c.$2))
                                  .asList()))))
                ])));

Card _card(List<Widget> children) => Card(
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
    child: SizedBox(
        child: Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 12),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children))));

Widget emails(List<Email> emails,
        [void Function(int index, String label)? onTap]) =>
    _card(emails
        .asMap()
        .map((i, e) => MapEntry(
            i,
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(
                  child: Column(
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
              if (onTap != null)
                IconButton(
                    key: Key('emailsCirclesMgmt${i}'),
                    onPressed: () =>
                        onTap(i, _label(e.label.name, e.customLabel).data!),
                    icon: const Icon(Icons.add_task))
            ])))
        .values
        .asList());

Widget phones(List<Phone> phones,
        [void Function(int index, String label)? onTap]) =>
    _card(phones
        .asMap()
        .map((i, e) => MapEntry(
            i,
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: _label(e.label.name, e.customLabel)),
                    Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: Text(e.number,
                            style: const TextStyle(fontSize: 19)))
                  ])),
              if (onTap != null)
                IconButton(
                    key: Key('phonesCirclesMgmt${i}'),
                    onPressed: () =>
                        onTap(i, _label(e.label.name, e.customLabel).data!),
                    icon: const Icon(Icons.add_task))
            ])))
        .values
        .asList());

Widget websites(List<Website> websites,
        [void Function(int index, String label)? onTap]) =>
    _card(websites
        .asMap()
        .map((i, e) => MapEntry(
            i,
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: _label(e.label.name, e.customLabel)),
                    Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child:
                            Text(e.url, style: const TextStyle(fontSize: 19)))
                  ])),
              if (onTap != null)
                IconButton(
                    key: Key('websitesCirclesMgmt${i}'),
                    onPressed: () =>
                        onTap(i, _label(e.label.name, e.customLabel).data!),
                    icon: const Icon(Icons.add_task))
            ])))
        .values
        .asList());

Widget socialMedias(List<SocialMedia> websites,
        [void Function(int index, String label)? onTap]) =>
    _card(websites
        .asMap()
        .map((i, e) => MapEntry(
            i,
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: _label(e.label.name, e.customLabel)),
                    Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: Text(e.userName,
                            style: const TextStyle(fontSize: 19)))
                  ])),
              if (onTap != null)
                IconButton(
                    key: Key('socialMediasCirclesMgmt${i}'),
                    onPressed: () =>
                        onTap(i, _label(e.label.name, e.customLabel).data!),
                    icon: const Icon(Icons.add_task))
            ])))
        .values
        .asList());

String _commaToNewline(String s) =>
    s.replaceAll(', ', ',').replaceAll(',', '\n');

/// Potentially custom label for fields like email, phone, website
Text _label(String name, String customLabel) =>
    Text((name != 'custom') ? name : customLabel,
        style: const TextStyle(fontSize: 16));

bool labelDoesMatch(String name, Address address) {
  if (address.label == AddressLabel.custom) {
    return name == address.customLabel;
  }
  return name == address.label.name;
}

Widget addressesWithForms(BuildContext context, List<Address> addresses,
        List<ContactAddressLocation> locations,
        [void Function(int index, String label)? onTap]) =>
    _card(addresses
        .asMap()
        .map((i, e) => MapEntry(
            i,
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 8),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      _label(e.label.name, e.customLabel),
                      Text(_commaToNewline(e.address),
                          style: const TextStyle(fontSize: 19)),
                    ])),
                if (onTap != null)
                  IconButton(
                      key: Key('addressesCirclesMgmt${i}'),
                      onPressed: () =>
                          onTap(i, _label(e.label.name, e.customLabel).data!),
                      icon: const Icon(Icons.add_task)),
              ]),
              const SizedBox(height: 8),
              // TODO: This is not updated when fetch coordinates emits new state
              AddressCoordinatesForm(
                  lng: locations
                      .where((l) => labelDoesMatch(l.name, e))
                      .firstOrNull
                      ?.longitude,
                  lat: locations
                      .where((l) => labelDoesMatch(l.name, e))
                      .firstOrNull
                      ?.latitude,
                  callback: (lng, lat) => context
                      .read<ProfileCubit>()
                      .updateCoordinates(i, lng, lat)),
              // TODO: Add small map previewing the location when coordinates are available
              TextButton(
                  child: const Text('Auto Fetch Coordinates'),
                  // TODO: Switch to address index instead of label? Can there be duplicates?
                  onPressed: () async => showDialog<void>(
                      context: context,
                      // barrierDismissible: false,
                      builder: (dialogContext) => _confirmPrivacyLeakDialog(
                          dialogContext,
                          e.address,
                          () => unawaited(context
                              .read<ProfileCubit>()
                              .fetchCoordinates(i)))))
            ])))
        .values
        .asList());

Widget addresses(List<Address> addresses) => _card(addresses
    .map((e) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _label(e.label.name, e.customLabel)),
          Text(_commaToNewline(e.address), style: const TextStyle(fontSize: 19))
        ]))
    .asList());

Widget header(Contact contact) => Card(
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
          Text('Looking up the coordinates of "$address" automatically '
              'only works by sending that address to '
              '${(Platform.isIOS) ? 'Apple' : 'Google'}. '
              'Are you ok with leaking to them that you relate to this '
              'address somehow?'),
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

Widget buildProfileScrollView(
        {required BuildContext context,
        required String coagContactId,
        required Contact contact,
        required List<ContactAddressLocation> addressLocations,
        required Map<String, String> circles,
        required ProfileSharingSettings profileSharingSettings}) =>
    RefreshIndicator(
        onRefresh: () async =>
            context.read<ProfileCubit>().setContact(contact.id),
        child: CustomScrollView(slivers: [
          SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    header(contact),
                    if (contact.phones.isNotEmpty)
                      phones(
                          contact.phones,
                          (i, label) async => showPickCirclesBottomSheet(
                              context: context,
                              label: label,
                              coagContactId: coagContactId,
                              circles: circles
                                  .map((cId, cLabel) => MapEntry(cId, (
                                        cId,
                                        cLabel,
                                        profileSharingSettings
                                                .phones['$i|$label']
                                                ?.contains(cId) ??
                                            false
                                      )))
                                  .values
                                  .toList(),
                              callback: (selectedCircles) => context
                                  .read<ProfileCubit>()
                                  .updatePhoneSharingCircles(
                                      i, label, selectedCircles))),
                    if (contact.emails.isNotEmpty)
                      emails(
                          contact.emails,
                          (i, label) async => showPickCirclesBottomSheet(
                              context: context,
                              label: label,
                              coagContactId: coagContactId,
                              circles: circles
                                  .map((cId, cLabel) => MapEntry(cId, (
                                        cId,
                                        cLabel,
                                        profileSharingSettings
                                                .emails['$i|$label']
                                                ?.contains(cId) ??
                                            false
                                      )))
                                  .values
                                  .toList(),
                              callback: (selectedCircles) => context
                                  .read<ProfileCubit>()
                                  .updateEmailSharingCircles(
                                      i, label, selectedCircles))),
                    if (contact.addresses.isNotEmpty)
                      addressesWithForms(
                          context,
                          contact.addresses,
                          addressLocations,
                          (i, label) async => showPickCirclesBottomSheet(
                              context: context,
                              label: label,
                              coagContactId: coagContactId,
                              circles: circles
                                  .map((cId, cLabel) => MapEntry(cId, (
                                        cId,
                                        cLabel,
                                        profileSharingSettings
                                                .addresses['$i|$label']
                                                ?.contains(cId) ??
                                            false
                                      )))
                                  .values
                                  .toList(),
                              callback: (selectedCircles) => context
                                  .read<ProfileCubit>()
                                  .updateAddressSharingCircles(
                                      i, label, selectedCircles))),
                    if (contact.websites.isNotEmpty)
                      websites(
                          contact.websites,
                          (i, label) async => showPickCirclesBottomSheet(
                              context: context,
                              label: label,
                              coagContactId: coagContactId,
                              circles: circles
                                  .map((cId, cLabel) => MapEntry(cId, (
                                        cId,
                                        cLabel,
                                        profileSharingSettings
                                                .websites['$i|$label']
                                                ?.contains(cId) ??
                                            false
                                      )))
                                  .values
                                  .toList(),
                              callback: (selectedCircles) => context
                                  .read<ProfileCubit>()
                                  .updateWebsiteSharingCircles(
                                      i, label, selectedCircles))),
                    if (contact.socialMedias.isNotEmpty)
                      socialMedias(
                          contact.socialMedias,
                          (i, label) async => showPickCirclesBottomSheet(
                              context: context,
                              label: label,
                              coagContactId: coagContactId,
                              circles: circles
                                  .map((cId, cLabel) => MapEntry(cId, (
                                        cId,
                                        cLabel,
                                        profileSharingSettings
                                                .socialMedias['$i|$label']
                                                ?.contains(cId) ??
                                            false
                                      )))
                                  .values
                                  .toList(),
                              callback: (selectedCircles) => context
                                  .read<ProfileCubit>()
                                  .updateSocialMediaSharingCircles(
                                      i, label, selectedCircles))),
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
            if (state.permissionsGranted) ...[
              // Re-enable for Android when fixed: https://github.com/QuisApp/flutter_contacts/issues/100
              if (Platform.isIOS)
                TextButton(
                    onPressed: context.read<ProfileCubit>().promptCreate,
                    child: const Text('Create Profile',
                        textScaler: TextScaler.linear(1.2))),
              if (Platform.isIOS)
                Container(
                    padding: const EdgeInsets.all(8),
                    child:
                        const Text('or', textScaler: TextScaler.linear(1.2))),
              TextButton(
                  onPressed: context.read<ProfileCubit>().promptPick,
                  child: const Text('Pick Contact as Profile',
                      textScaler: TextScaler.linear(1.2))),
            ],
            // TODO: Check if read access is enough / ensure
            // TODO: Check if a re-request permissions button here is possible (doesn't seem to work reliably)
            if (!state.permissionsGranted)
              Container(
                  padding:
                      const EdgeInsets.only(left: 16, right: 16, bottom: 28),
                  child: const Text(
                      'Please go to your permissions settings and grant Coagulate access to your address book.'))
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
          child: buildProfileScrollView(
              context: context,
              coagContactId: state.profileContact!.coagContactId,
              contact: state.profileContact!.systemContact!,
              addressLocations:
                  state.profileContact!.addressLocations.values.asList(),
              circles: state.circles,
              profileSharingSettings: state.sharingSettings!),
        );
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) =>
      BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {},
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
