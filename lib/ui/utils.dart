// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:veilid/veilid.dart';

import '../data/models/coag_contact.dart';
import '../data/models/contact_introduction.dart';
import '../data/models/contact_location.dart';
import '../l10n/app_localizations.dart';
import 'batch_invite_management/cubit.dart';

extension LocalizationExt on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this)!;
}

extension StringExtension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}

String extractAllValuesToString(dynamic value) {
  if (value is Map) {
    return value.values.map(extractAllValuesToString).join('|');
  } else if (value is List) {
    return value.map(extractAllValuesToString).join('|');
  } else {
    return value.toString();
  }
}

// TODO: Also search temporary locations?
bool searchMatchesContact(String search, CoagContact contact) =>
    contact.name.toLowerCase().contains(search.toLowerCase()) ||
    (contact.details != null &&
        extractAllValuesToString(contact.details!.toJson())
            .toLowerCase()
            .contains(search.toLowerCase()));

Widget roundPictureOrPlaceholder(List<int>? picture,
    {double? radius, bool clipOval = true}) {
  final image = Image.memory(
    Uint8List.fromList(picture ?? []),
    gaplessPlayback: true,
    width: (radius == null) ? null : radius * 2,
    height: (radius == null) ? null : radius * 2,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) =>
        CircleAvatar(radius: radius, child: const Icon(Icons.person)),
  );
  if (clipOval) {
    return ClipOval(child: image);
  }
  return image;
}

String commasToNewlines(String s) =>
    s.split(',').map((p) => p.trim()).join('\n');

// TODO: Only detect added things, not removed things
String contactUpdateSummary(CoagContact oldContact, CoagContact newContact) {
  final results = <String>[];

  final oldDetails = oldContact.details ?? const ContactDetails();
  final newDetails = newContact.details ?? const ContactDetails();

  const equality = MapEquality<String, String>();

  if (!(oldDetails.picture ?? []).equals(newDetails.picture ?? [])) {
    results.add('picture');
  }

  if (!equality.equals(oldDetails.names, newDetails.names)) {
    results.add('names');
  }

  if (!equality.equals(oldDetails.emails, newDetails.emails)) {
    results.add('emails');
  }

  if (!equality.equals(oldDetails.phones, newDetails.phones)) {
    results.add('phones');
  }

  if (!equality.equals(oldDetails.websites, newDetails.websites)) {
    results.add('websites');
  }

  if (!equality.equals(oldDetails.socialMedias, newDetails.socialMedias)) {
    results.add('socials');
  }

  if (!const MapEquality<String, ContactAddressLocation>()
      .equals(oldContact.addressLocations, newContact.addressLocations)) {
    results.add('addresses');
  }

  if (!const MapEquality<String, DateTime>()
      .equals(oldDetails.events, newDetails.events)) {
    results.add('events');
  }

  if (!const MapEquality<String, Organization>()
      .equals(oldDetails.organizations, newDetails.organizations)) {
    results.add('organizations');
  }

  // TODO: Make this consistent with the yesterday filtering we do elsewhere?
  if (!oldContact.temporaryLocations.values
      .where((l) => l.end.isAfter(DateTime.now()))
      .toList()
      .equals(newContact.temporaryLocations.values
          .where((l) => l.end.isAfter(DateTime.now()))
          .toList())) {
    results.add('locations');
  }

  return results.join(', ');
}

Iterable<String> generateBatchInviteLinks(Batch batch) =>
    batch.subkeyWriters.toList().asMap().entries.map((w) => batchInviteUrl(
            batch.label,
            batch.dhtRecordKey,
            batch.psk,
            // Index of the writer in the list + 1 is the corresponding subkey
            w.key + 1,
            w.value)
        .toString());

// TODO: Pass dhtSettings to all the Url generators to make it easier to test that the correct keys are used?
Uri directSharingUrl(String name, Typed<FixedEncodedString43> dhtRecordKey,
        FixedEncodedString43 psk) =>
    Uri(
        scheme: 'https',
        host: 'coagulate.social',
        path: '/c',
        fragment: [name, dhtRecordKey.toString(), psk.toString()].join('~'));

Uri profileUrl(String name, PublicKey publicKey) => Uri(
    scheme: 'https',
    host: 'coagulate.social',
    path: '/p',
    fragment: [name, publicKey.toString()].join('~'));

Uri batchInviteUrl(String label, Typed<FixedEncodedString43> dhtRecordKey,
        FixedEncodedString43 psk, int subKeyIndex, KeyPair writer) =>
    Uri(
        scheme: 'https',
        host: 'coagulate.social',
        path: '/b',
        fragment: [
          label,
          dhtRecordKey.toString(),
          psk.toString(),
          // Index of the writer in the list + 1 is the corresponding subkey
          subKeyIndex.toString(),
          writer.toString()
        ].join('~'));

Uri profileBasedOfferUrl(String name, Typed<FixedEncodedString43> dhtRecordKey,
        FixedEncodedString43 publicKey) =>
    Uri(
        scheme: 'https',
        host: 'coagulate.social',
        path: '/o',
        fragment:
            [name, dhtRecordKey.toString(), publicKey.toString()].join('~'));

bool showSharingInitializing(CoagContact contact) =>
    contact.dhtSettings.recordKeyThemSharing == null ||
    contact.dhtSettings.recordKeyMeSharing == null;

bool showSharingOffer(CoagContact contact) =>
    contact.dhtSettings.recordKeyThemSharing != null &&
    contact.dhtSettings.initialSecret == null &&
    contact.details == null;

bool showDirectSharing(CoagContact contact) =>
    contact.dhtSettings.recordKeyThemSharing != null &&
    contact.dhtSettings.initialSecret != null &&
    contact.details == null;

/// Returns introducer and introduction for pending introductions
Iterable<(CoagContact, ContactIntroduction)> pendingIntroductions(
        Iterable<CoagContact> contacts) =>
    contacts
        .map((c) => c.introductionsByThem
            .where((i) => !contacts
                .map((c) => c.dhtSettings.recordKeyThemSharing)
                .whereType<Typed<FixedEncodedString43>>()
                .contains(i.dhtRecordKeyReceiving))
            .map((i) => (c, i)))
        .expand((i) => i);

Widget buildEditOrAddWidgetSkeleton(BuildContext context,
        {required String title,
        required List<Widget> children,
        required Widget onSaveWidget}) =>
    Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding:
                  const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 16),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton.filledTonal(
                        onPressed: Navigator.of(context).pop,
                        icon: const Icon(Icons.cancel_outlined)),
                    Expanded(
                        child: Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    )),
                    onSaveWidget,
                  ])),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children),
          ),
        ]);

List<(String, String)> labelValueMapToTupleList(Map<String, String> map) =>
    map.map((key, value) => MapEntry(key, (key, value))).values.toList();
