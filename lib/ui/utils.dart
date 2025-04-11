import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:veilid/veilid.dart';

import '../data/models/coag_contact.dart';
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

String contactUpdateSummary(CoagContact oldContact, CoagContact newContact) {
  final results = <String>[];

  final oldDetails = oldContact.details ?? const ContactDetails();
  final newDetails = newContact.details ?? const ContactDetails();

  if (!(oldDetails.picture ?? []).equals(newDetails.picture ?? [])) {
    results.add('picture');
  }

  if (oldDetails.names.values
          .toSet()
          .difference(newDetails.names.values.toSet())
          .isNotEmpty ||
      newDetails.names.values
          .toSet()
          .difference(oldDetails.names.values.toSet())
          .isNotEmpty) {
    results.add('names');
  }

  if (!oldDetails.emails.equals(newDetails.emails)) {
    results.add('emails');
  }

  if (!oldDetails.addresses.equals(newDetails.addresses)) {
    results.add('addresses');
  }

  if (!oldDetails.phones.equals(newDetails.phones)) {
    results.add('phones');
  }

  if (!oldDetails.websites.equals(newDetails.websites)) {
    results.add('websites');
  }

  if (!oldDetails.socialMedias.equals(newDetails.socialMedias)) {
    results.add('socials');
  }

  if (!oldDetails.organizations.equals(newDetails.organizations)) {
    results.add('organizations');
  }

  if (!oldDetails.events.equals(newDetails.events)) {
    results.add('events');
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
