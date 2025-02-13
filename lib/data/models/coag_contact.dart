// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:equatable/equatable.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:json_annotation/json_annotation.dart';
import 'contact_location.dart';
part 'coag_contact.g.dart';

@JsonSerializable()
class ContactDHTSettings extends Equatable {
  const ContactDHTSettings(
      {required this.key,
      this.writer,
      this.psk,
      this.pubKey,
      this.lastUpdated});

  final String key;
  // Optional writer keypair in case I shared first and offered a DHT record for
  // my peer to share back
  final String? writer;
  // Optional pre-shared secret in case I shared first and did not yet have
  // their public key
  final String? psk;
  final String? pubKey;
  final DateTime? lastUpdated;

  factory ContactDHTSettings.fromJson(Map<String, dynamic> json) =>
      _$ContactDHTSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$ContactDHTSettingsToJson(this);

  ContactDHTSettings copyWith(
          {String? key,
          String? writer,
          String? psk,
          String? pubKey,
          DateTime? lastUpdated}) =>
      ContactDHTSettings(
        key: key ?? this.key,
        writer: writer ?? this.writer,
        psk: psk ?? this.psk,
        pubKey: pubKey ?? this.pubKey,
        lastUpdated: lastUpdated ?? this.lastUpdated,
      );

  @override
  List<Object?> get props => [key, writer, psk, pubKey];
}

@JsonSerializable()
class ContactDetails extends Equatable {
  const ContactDetails({
    this.names = const {},
    this.phones = const [],
    this.emails = const [],
    this.addresses = const [],
    this.organizations = const [],
    this.websites = const [],
    this.socialMedias = const [],
    this.events = const [],
  });

  // TODO: Can it backfire if we drop all names but the display name?
  ContactDetails.fromSystemContact(Contact c)
      : names = {'0': c.displayName},
        phones = c.phones,
        emails = c.emails,
        addresses = c.addresses,
        organizations = c.organizations,
        websites = c.websites,
        socialMedias = c.socialMedias,
        events = c.events;

  Contact toSystemContact(String displayName) => Contact(
      displayName: displayName,
      phones: phones,
      emails: emails,
      addresses: addresses,
      organizations: organizations,
      websites: websites,
      socialMedias: socialMedias,
      events: events);

  factory ContactDetails.fromJson(Map<String, dynamic> json) =>
      _$ContactDetailsFromJson(json);

  /// Names with unique key
  final Map<String, String> names;

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
          {Map<String, String>? names,
          List<Phone>? phones,
          List<Email>? emails,
          List<Address>? addresses,
          List<Organization>? organizations,
          List<Website>? websites,
          List<SocialMedia>? socialMedias,
          List<Event>? events}) =>
      ContactDetails(
        names: names ?? this.names,
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
        names,
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
  const CoagContact({
    required this.coagContactId,
    this.details,
    this.systemContact,
    this.addressLocations = const {},
    this.temporaryLocations = const [],
    this.dhtSettingsForSharing,
    this.dhtSettingsForReceiving,
    this.sharedProfile,
    this.publicKey,
    this.mostRecentUpdate,
    this.mostRecentChange,
  });

  final String coagContactId;
  final Contact? systemContact;
  final ContactDetails? details;
  // This is a map from index to value instead of a list because only the ith address could have a location
  final Map<int, ContactAddressLocation> addressLocations;
  final List<ContactTemporaryLocation> temporaryLocations;
  final ContactDHTSettings? dhtSettingsForSharing;
  final ContactDHTSettings? dhtSettingsForReceiving;
  // TODO: Make this a proper type with toJson?
  final String? sharedProfile;
  final String? publicKey;
  // TODO: Move these two to contact details to also have the same for the system contact
  final DateTime? mostRecentUpdate;
  final DateTime? mostRecentChange;

  factory CoagContact.fromJson(Map<String, dynamic> json) {
    // This is just a hack because somehow the pictures list representation
    // screws with the autogenerated fromJson
    if (json['system_contact'] != null &&
        json['system_contact']['thumbnail'] != null) {
      json['system_contact']['thumbnail'] = null;
    }
    if (json['system_contact'] != null &&
        json['system_contact']['photo'] != null) {
      json['system_contact']['photo'] = null;
    }
    return _$CoagContactFromJson(json);
  }

  Map<String, dynamic> toJson() {
    final json = _$CoagContactToJson(this);
    // This is just a hack because somehow the pictures list representation
    // screws with the autogenerated fromJson
    if (json['system_contact'] != null &&
        json['system_contact']['thumbnail'] != null) {
      json['system_contact']['thumbnail'] = null;
    }
    if (json['system_contact'] != null &&
        json['system_contact']['photo'] != null) {
      json['system_contact']['photo'] = null;
    }
    return json;
  }

  CoagContact copyWith({
    String? coagContactId,
    Contact? systemContact,
    ContactDetails? details,
    Map<int, ContactAddressLocation>? addressLocations,
    List<ContactTemporaryLocation>? temporaryLocations,
    ContactDHTSettings? dhtSettingsForSharing,
    ContactDHTSettings? dhtSettingsForReceiving,
    String? sharedProfile,
    String? publicKey,
    DateTime? mostRecentUpdate,
    DateTime? mostRecentChange,
  }) =>
      CoagContact(
        coagContactId: coagContactId ?? this.coagContactId,
        details: details ?? this.details,
        systemContact: systemContact ?? this.systemContact,
        addressLocations: addressLocations ?? this.addressLocations,
        temporaryLocations: temporaryLocations ?? this.temporaryLocations,
        dhtSettingsForSharing:
            dhtSettingsForSharing ?? this.dhtSettingsForSharing,
        dhtSettingsForReceiving:
            dhtSettingsForReceiving ?? this.dhtSettingsForReceiving,
        sharedProfile: sharedProfile ?? this.sharedProfile,
        publicKey: publicKey ?? this.publicKey,
        mostRecentUpdate: mostRecentUpdate ?? this.mostRecentUpdate,
        mostRecentChange: mostRecentChange ?? this.mostRecentChange,
      );

  @override
  List<Object?> get props => [
        coagContactId,
        details,
        systemContact,
        dhtSettingsForSharing,
        dhtSettingsForReceiving,
        sharedProfile,
        publicKey,
        addressLocations,
        temporaryLocations,
        mostRecentUpdate,
        mostRecentChange,
      ];
}

@JsonSerializable()
class CoagContactDHTSchemaV1 extends Equatable {
  const CoagContactDHTSchemaV1({
    required this.coagContactId,
    required this.details,
    this.shareBackDHTKey,
    this.shareBackPsk,
    this.shareBackDHTWriter,
    this.addressLocations = const {},
    this.temporaryLocations = const [],
  });

  factory CoagContactDHTSchemaV1.fromJson(Map<String, dynamic> json) =>
      _$CoagContactDHTSchemaV1FromJson(json);

  final int schemaVersion = 1;
  final String coagContactId;
  final ContactDetails details;
  final Map<int, ContactAddressLocation> addressLocations;
  final List<ContactTemporaryLocation> temporaryLocations;
  final String? shareBackDHTKey;
  final String? shareBackDHTWriter;
  final String? shareBackPsk;

  Map<String, dynamic> toJson() => _$CoagContactDHTSchemaV1ToJson(this);

  CoagContactDHTSchemaV1 copyWith({
    ContactDetails? details,
    String? shareBackDHTKey,
    String? shareBackPsk,
    String? shareBackDHTWriter,
    Map<int, ContactAddressLocation>? addressLocations,
    List<ContactTemporaryLocation>? temporaryLocations,
  }) =>
      CoagContactDHTSchemaV1(
        coagContactId: coagContactId,
        details: details ?? this.details,
        shareBackDHTKey: shareBackDHTKey ?? this.shareBackDHTKey,
        shareBackPsk: shareBackPsk ?? this.shareBackPsk,
        shareBackDHTWriter: shareBackDHTWriter ?? this.shareBackDHTWriter,
        addressLocations: addressLocations ?? this.addressLocations,
        temporaryLocations: temporaryLocations ?? this.temporaryLocations,
      );

  @override
  List<Object?> get props => [
        schemaVersion,
        coagContactId,
        details,
        shareBackDHTKey,
        shareBackPsk,
        shareBackDHTWriter,
        addressLocations,
        temporaryLocations,
      ];
}

@JsonSerializable()
class CoagContactDHTSchemaV2 extends Equatable {
  CoagContactDHTSchemaV2({
    required this.details,
    required this.shareBackDHTKey,
    required this.shareBackPubKey,
    this.shareBackDHTWriter,
    this.addressLocations = const {},
    this.temporaryLocations = const [],
    DateTime? mostRecentUpdate,
  }) {
    this.mostRecentUpdate = mostRecentUpdate ?? DateTime.now();
  }
  factory CoagContactDHTSchemaV2.fromJson(Map<String, dynamic> json) {
    try {
      return _$CoagContactDHTSchemaV2FromJson(json);
    } on FormatException {
      return schemaV1toV2(_$CoagContactDHTSchemaV1FromJson(json));
    }
  }

  final int schemaVersion = 2;
  final ContactDetails details;
  final Map<int, ContactAddressLocation> addressLocations;
  final List<ContactTemporaryLocation> temporaryLocations;
  final String? shareBackDHTKey;
  final String? shareBackDHTWriter;
  final String? shareBackPubKey;
  late final DateTime? mostRecentUpdate;

  Map<String, dynamic> toJson() => _$CoagContactDHTSchemaV2ToJson(this);

  CoagContactDHTSchemaV2 copyWith({
    ContactDetails? details,
    String? shareBackDHTKey,
    String? shareBackDHTWriter,
    String? shareBackPubKey,
    Map<int, ContactAddressLocation>? addressLocations,
    List<ContactTemporaryLocation>? temporaryLocations,
  }) =>
      CoagContactDHTSchemaV2(
        details: details ?? this.details,
        shareBackDHTKey: shareBackDHTKey ?? this.shareBackDHTKey,
        shareBackPubKey: shareBackPubKey ?? this.shareBackPubKey,
        shareBackDHTWriter: shareBackDHTWriter ?? this.shareBackDHTWriter,
        addressLocations: addressLocations ?? this.addressLocations,
        temporaryLocations: temporaryLocations ?? this.temporaryLocations,
      );

  // Differences in mostRecentUpdate timestamp will still caus equality
  @override
  List<Object?> get props => [
        schemaVersion,
        details,
        shareBackDHTKey,
        shareBackPubKey,
        shareBackDHTWriter,
        addressLocations,
        temporaryLocations,
      ];
}

CoagContactDHTSchemaV2 schemaV1toV2(CoagContactDHTSchemaV1 old) =>
    CoagContactDHTSchemaV2(
        details: old.details,
        shareBackDHTKey: old.shareBackDHTKey,
        shareBackDHTWriter: old.shareBackDHTWriter,
        // NOTE: This will cause downstream errors when trying to decrypt
        shareBackPubKey: old.shareBackPsk,
        addressLocations: old.addressLocations,
        temporaryLocations: old.temporaryLocations);

typedef CoagContactDHTSchema = CoagContactDHTSchemaV2;
