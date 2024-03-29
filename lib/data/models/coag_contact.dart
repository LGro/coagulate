// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:equatable/equatable.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:json_annotation/json_annotation.dart';
import 'contact_location.dart';
part 'coag_contact.g.dart';

@JsonSerializable()
class ContactDHTSettings {
  ContactDHTSettings({required this.key, this.writer, this.psk, this.pubKey});

  final String key;
  // Optional writer keypair in case I shared first and offered a DHT record for
  // my peer to share back
  final String? writer;
  // Optional pre-shared secret in case I shared first and did not yet have
  // their public key
  final String? psk;
  // Optional peer public key in case they share it; superseeds the psk
  final String? pubKey;
  // TODO: Reconsile pubKey and writer somehow so that only one is needed?

  factory ContactDHTSettings.fromJson(Map<String, dynamic> json) =>
      _$ContactDHTSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$ContactDHTSettingsToJson(this);

  ContactDHTSettings copyWith(
          {String? key, String? writer, String? psk, String? pubKey}) =>
      ContactDHTSettings(
        key: key ?? this.key,
        writer: writer ?? this.writer,
        psk: psk ?? this.psk,
        pubKey: pubKey ?? this.pubKey,
      );
}

@JsonSerializable()
class CoagContact extends Equatable {
  CoagContact(
      {required this.coagContactId,
      this.details,
      this.locations = const [],
      this.dhtSettings,
      this.sharedProfile});

  final String coagContactId;
  final Contact? details;
  final List<ContactLocation> locations;
  final ContactDHTSettings? dhtSettings;
  // TODO: Make this a proper type with toJson? and expose as init arg
  final String? sharedProfile;

  factory CoagContact.fromJson(Map<String, dynamic> json) =>
      _$CoagContactFromJson(json);

  Map<String, dynamic> toJson() => _$CoagContactToJson(this);

  CoagContact copyWith(
          {Contact? details,
          List<ContactLocation>? locations,
          ContactDHTSettings? dhtSettings,
          String? sharedProfile}) =>
      CoagContact(
          coagContactId: this.coagContactId,
          details: details ?? this.details,
          locations: locations ?? this.locations,
          dhtSettings: dhtSettings ?? this.dhtSettings,
          sharedProfile: sharedProfile ?? this.sharedProfile);

  @override
  List<Object?> get props =>
      [coagContactId, details, dhtSettings, sharedProfile];
}
