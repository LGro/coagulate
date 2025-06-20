// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:typed_data';

import 'package:veilid_support/veilid_support.dart';

import 'models/coag_contact.dart';

bool alreadyKnowEachOther(CoagContact? c1, CoagContact? c2) =>
    c1 != null &&
    c2 != null &&
    (c1.connectionAttestations
            .toSet()
            .intersection(c2.connectionAttestations.toSet())
            .length ==
        1);

// TODO: Allow opt-out (per contact, for contact, or globally?)
Future<List<String>> connectionAttestations(
        CoagContact contact, Iterable<CoagContact> contacts) async =>
    (contact.theirIdentity == null)
        ? []
        : await Future.wait(contacts
            .where((c) => c.coagContactId != contact.coagContactId)
            .map((c) => c.theirIdentity)
            // Remove null entries
            .whereType<PublicKey>()
            // Remove duplicates
            .toSet()
            .map((otherIdentityKey) async =>
                Veilid.instance.bestCryptoSystem().then((cs) async => cs
                    .generateHash(Uint8List.fromList([
                      ...utf8.encode(await cs
                          .generateSharedSecret(
                              otherIdentityKey,
                              contact.myIdentity.secret,
                              utf8.encode(
                                  'contact-discovery-connection-secret'))
                          .then((s) => s.toString())),
                      ...utf8.encode(contact.theirIdentity.toString())
                    ]))
                    .then((hash) => hash.toString())))
            .toList());
