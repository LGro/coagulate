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
class ContactDetails extends Equatable {
  const ContactDetails({
    required this.displayName,
    required this.name,
    this.phones = const [],
    this.emails = const [],
    this.addresses = const [],
    this.organizations = const [],
    this.websites = const [],
    this.socialMedias = const [],
    this.events = const [],
  });

  ContactDetails.fromSystemContact(Contact c)
      : displayName = c.displayName,
        name = c.name,
        phones = c.phones,
        emails = c.emails,
        addresses = c.addresses,
        organizations = c.organizations,
        websites = c.websites,
        socialMedias = c.socialMedias,
        events = c.events;

  factory ContactDetails.fromJson(Map<String, dynamic> json) =>
      _$ContactDetailsFromJson(json);

  final String displayName;

  /// Structured name.
  final Name name;

  /// Phone numbers.
  final List<Phone> phones;

  /// Email addresses.
  final List<Email> emails;

  /// Postal addresses.
  final List<Address> addresses;

  /// Organizations / jobs.
  final List<Organization> organizations;

  /// Websites.
  final List<Website> websites;

  /// Social media / instant messaging profiles.
  final List<SocialMedia> socialMedias;

  /// Events / birthdays.
  final List<Event> events;

  Map<String, dynamic> toJson() => _$ContactDetailsToJson(this);

  ContactDetails copyWith(
          {String? displayName,
          Name? name,
          List<Phone>? phones,
          List<Email>? emails,
          List<Address>? addresses,
          List<Organization>? organizations,
          List<Website>? websites,
          List<SocialMedia>? socialMedias,
          List<Event>? events}) =>
      ContactDetails(
        displayName: displayName ?? this.displayName,
        name: name ?? this.name,
        phones: phones ?? this.phones,
        emails: emails ?? this.emails,
        addresses: addresses ?? this.addresses,
        organizations: organizations ?? this.organizations,
        websites: websites ?? this.websites,
        socialMedias: socialMedias ?? this.socialMedias,
        events: events ?? this.events,
      );

  @override
  List<Object?> get props => [
        displayName,
        name,
        phones,
        emails,
        addresses,
        organizations,
        websites,
        socialMedias,
        events,
      ];
}

@JsonSerializable()
class CoagContact extends Equatable {
  CoagContact(
      {required this.coagContactId,
      this.details,
      this.systemContact,
      this.locations = const [],
      this.dhtSettingsForSharing,
      this.dhtSettingsForReceiving,
      this.sharedProfile});

  final String coagContactId;
  final Contact? systemContact;
  final ContactDetails? details;
  final List<ContactLocation> locations;
  final ContactDHTSettings? dhtSettingsForSharing;
  final ContactDHTSettings? dhtSettingsForReceiving;
  // TODO: Make this a proper type with toJson?
  final String? sharedProfile;

  factory CoagContact.fromJson(Map<String, dynamic> json) =>
      _$CoagContactFromJson(json);

  Map<String, dynamic> toJson() => _$CoagContactToJson(this);

  CoagContact copyWith(
          {Contact? systemContact,
          ContactDetails? details,
          List<ContactLocation>? locations,
          ContactDHTSettings? dhtSettingsForSharing,
          ContactDHTSettings? dhtSettingsForReceiving,
          String? sharedProfile}) =>
      CoagContact(
          coagContactId: this.coagContactId,
          details: details ?? this.details,
          systemContact: systemContact ?? this.systemContact,
          locations: locations ?? this.locations,
          dhtSettingsForSharing:
              dhtSettingsForSharing ?? this.dhtSettingsForSharing,
          dhtSettingsForReceiving:
              dhtSettingsForReceiving ?? this.dhtSettingsForReceiving,
          sharedProfile: sharedProfile ?? this.sharedProfile);

  @override
  List<Object?> get props => [
        coagContactId,
        details,
        systemContact,
        dhtSettingsForSharing,
        dhtSettingsForReceiving,
        sharedProfile,
        locations,
      ];
}

@JsonSerializable()
class CoagContactDHTSchemaV1 extends Equatable {
  const CoagContactDHTSchemaV1(
      {required this.coagContactId,
      required this.details,
      this.shareBackDHTKey,
      this.shareBackPubKey,
      this.shareBackDHTWriter,
      this.locations = const []});

  final int schemaVersion = 1;
  // TODO: Consider removing this one again if we just try all available private keys on the receiving side
  final String coagContactId;
  final ContactDetails details;
  final List<ContactLocation> locations;
  final String? shareBackDHTKey;
  final String? shareBackDHTWriter;
  final String? shareBackPubKey;

  factory CoagContactDHTSchemaV1.fromJson(Map<String, dynamic> json) =>
      _$CoagContactDHTSchemaV1FromJson(json);

  Map<String, dynamic> toJson() => _$CoagContactDHTSchemaV1ToJson(this);

  CoagContactDHTSchemaV1 copyWith({
    ContactDetails? details,
    String? shareBackDHTKey,
    String? shareBackPubKey,
    String? shareBackDHTWriter,
    List<ContactLocation>? locations,
  }) =>
      CoagContactDHTSchemaV1(
        coagContactId: this.coagContactId,
        details: details ?? this.details,
        shareBackDHTKey: shareBackDHTKey ?? this.shareBackDHTKey,
        shareBackPubKey: shareBackPubKey ?? this.shareBackPubKey,
        shareBackDHTWriter: shareBackDHTWriter ?? this.shareBackDHTWriter,
        locations: locations ?? this.locations,
      );

  @override
  List<Object?> get props => [
        schemaVersion,
        coagContactId,
        details,
        shareBackDHTKey,
        shareBackPubKey,
        shareBackDHTWriter,
        locations
      ];
}