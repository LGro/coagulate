// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:veilid/veilid.dart';
import 'contact_location.dart';
import 'profile_sharing_settings.dart';
part 'coag_contact.g.dart';

@JsonSerializable()
class DhtSettings extends Equatable {
  const DhtSettings(
      {required this.myKeyPair,
      this.theirPublicKey,
      this.recordKeyMeSharing,
      this.writerMeSharing,
      this.recordKeyThemSharing,
      this.writerThemSharing,
      this.initialSecret,
      this.theyAckHandshakeComplete = false});

  factory DhtSettings.fromJson(Map<String, dynamic> json) =>
      _$DhtSettingsFromJson(json);

  final TypedKeyPair myKeyPair;
  final PublicKey? theirPublicKey;
  final Typed<FixedEncodedString43>? recordKeyMeSharing;
  final KeyPair? writerMeSharing;
  final Typed<FixedEncodedString43>? recordKeyThemSharing;
  final KeyPair? writerThemSharing;
  final FixedEncodedString43? initialSecret;
  final bool theyAckHandshakeComplete;

  Map<String, dynamic> toJson() => _$DhtSettingsToJson(this);

  DhtSettings copyWith(
          {TypedKeyPair? myKeyPair,
          PublicKey? theirPublicKey,
          Typed<FixedEncodedString43>? recordKeyMeSharing,
          KeyPair? writerMeSharing,
          Typed<FixedEncodedString43>? recordKeyThemSharing,
          KeyPair? writerThemSharing,
          FixedEncodedString43? initialSecret,
          bool? theyAckHandshakeComplete}) =>
      DhtSettings(
        myKeyPair: myKeyPair ?? this.myKeyPair,
        theirPublicKey: theirPublicKey ?? this.theirPublicKey,
        recordKeyMeSharing: recordKeyMeSharing ?? this.recordKeyMeSharing,
        writerMeSharing: writerMeSharing ?? this.writerMeSharing,
        recordKeyThemSharing: recordKeyThemSharing ?? this.recordKeyThemSharing,
        writerThemSharing: writerThemSharing ?? this.writerThemSharing,
        initialSecret: initialSecret ?? this.initialSecret,
        theyAckHandshakeComplete:
            theyAckHandshakeComplete ?? this.theyAckHandshakeComplete,
      );

  @override
  List<Object?> get props => [
        myKeyPair,
        theirPublicKey,
        recordKeyMeSharing,
        writerMeSharing,
        recordKeyThemSharing,
        writerThemSharing,
        initialSecret,
        theyAckHandshakeComplete,
      ];
}

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
    this.picture,
    this.publicKey,
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
      : picture = c.photo?.toList(),
        names = {'0': c.displayName},
        publicKey = null,
        phones = c.phones,
        emails = c.emails,
        addresses = c.addresses,
        organizations = c.organizations,
        websites = c.websites,
        socialMedias = c.socialMedias,
        events = c.events;

  Contact toSystemContact(String displayName) => Contact(
      displayName: displayName,
      photo: (picture == null) ? null : Uint8List.fromList(picture!),
      phones: phones,
      emails: emails,
      addresses: addresses,
      organizations: organizations,
      websites: websites,
      socialMedias: socialMedias,
      events: events);

  factory ContactDetails.fromJson(Map<String, dynamic> json) =>
      _$ContactDetailsFromJson(json);

  /// Binary integer representation of an image
  final List<int>? picture;

  /// Public key for encrypting data
  final String? publicKey;

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
          {List<int>? picture,
          String? publicKey,
          Map<String, String>? names,
          List<Phone>? phones,
          List<Email>? emails,
          List<Address>? addresses,
          List<Organization>? organizations,
          List<Website>? websites,
          List<SocialMedia>? socialMedias,
          List<Event>? events}) =>
      ContactDetails(
        picture:
            picture ?? ((this.picture == null) ? null : [...this.picture!]),
        publicKey: publicKey ?? this.publicKey,
        names: names ?? {...this.names},
        phones: phones ?? [...this.phones],
        emails: emails ?? [...this.emails],
        addresses: addresses ?? [...this.addresses],
        organizations: organizations ?? [...this.organizations],
        websites: websites ?? [...this.websites],
        socialMedias: socialMedias ?? [...this.socialMedias],
        events: events ?? [...this.events],
      );

  @override
  List<Object?> get props => [
        picture,
        publicKey,
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
class ProfileInfo extends Equatable {
  const ProfileInfo(
    this.id, {
    this.details = const ContactDetails(),
    this.pictures = const {},
    this.addressLocations = const {},
    this.temporaryLocations = const {},
    this.sharingSettings = const ProfileSharingSettings(),
  });

  factory ProfileInfo.fromJson(Map<String, dynamic> json) =>
      _$ProfileInfoFromJson(json);

  final String id;
  final ContactDetails details;
  final Map<String, List<int>> pictures;
  // This is a map from index to value instead of a list because only the ith
  // address could have a location
  final Map<int, ContactAddressLocation> addressLocations;
  final Map<String, ContactTemporaryLocation> temporaryLocations;
  final ProfileSharingSettings sharingSettings;
  Map<String, dynamic> toJson() => _$ProfileInfoToJson(this);
  ProfileInfo copyWith({
    ContactDetails? details,
    Map<String, List<int>>? pictures,
    Map<int, ContactAddressLocation>? addressLocations,
    Map<String, ContactTemporaryLocation>? temporaryLocations,
    ProfileSharingSettings? sharingSettings,
  }) =>
      ProfileInfo(
        id,
        details: details ?? this.details.copyWith(),
        pictures: pictures ?? {...this.pictures},
        addressLocations: addressLocations ?? {...this.addressLocations},
        temporaryLocations: temporaryLocations ?? {...this.temporaryLocations},
        sharingSettings: sharingSettings ?? this.sharingSettings.copyWith(),
      );

  @override
  List<Object?> get props => [
        id,
        details,
        pictures,
        addressLocations,
        temporaryLocations,
        sharingSettings,
      ];
}

@JsonSerializable()
class CoagContact extends Equatable {
  const CoagContact({
    required this.coagContactId,
    required this.name,
    required this.dhtSettings,
    this.details,
    this.theirPersonalUniqueId,
    this.knownPersonalContactIds = const [],
    this.systemContact,
    this.addressLocations = const {},
    this.temporaryLocations = const {},
    this.comment = '',
    this.sharedProfile,
    this.mostRecentUpdate,
    this.mostRecentChange,
  });

  final String coagContactId;

  /// A unique ID provided by the contact to identified shared connections and
  /// avoid proposing introductions for contacts that already know each other
  final String? theirPersonalUniqueId;

  /// All unique contact IDs that this contact told us they know
  final List<String> knownPersonalContactIds;

  /// Name given to the contact by the app user
  final String name;

  /// Associated system contact
  final Contact? systemContact;

  /// Details shared by the contact
  final ContactDetails? details;

  /// Comment from the app user about the contact for personal reference
  final String comment;

  // This is a map from index to value instead of a list because only the ith
  // address could have a location
  final Map<int, ContactAddressLocation> addressLocations;
  final Map<String, ContactTemporaryLocation> temporaryLocations;

  /// Cryptographic keys and DHT record info for sharing with this contact
  final DhtSettings dhtSettings;

  /// Personalized selection of profile info that is shared with this contact
  final CoagContactDHTSchema? sharedProfile;

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
    String? name,
    String? comment,
    Contact? systemContact,
    ContactDetails? details,
    String? theirPersonalUniqueId,
    List<String>? knownPersonalContactIds,
    Map<int, ContactAddressLocation>? addressLocations,
    Map<String, ContactTemporaryLocation>? temporaryLocations,
    DhtSettings? dhtSettings,
    CoagContactDHTSchema? sharedProfile,
    DateTime? mostRecentUpdate,
    DateTime? mostRecentChange,
  }) =>
      CoagContact(
        coagContactId: coagContactId ?? this.coagContactId,
        details: details ?? this.details?.copyWith(),
        systemContact: systemContact ?? this.systemContact,
        addressLocations: addressLocations ?? {...this.addressLocations},
        temporaryLocations: temporaryLocations ?? {...this.temporaryLocations},
        dhtSettings: dhtSettings ?? this.dhtSettings.copyWith(),
        sharedProfile: sharedProfile ?? this.sharedProfile?.copyWith(),
        name: name ?? this.name,
        theirPersonalUniqueId:
            theirPersonalUniqueId ?? this.theirPersonalUniqueId,
        knownPersonalContactIds:
            knownPersonalContactIds ?? [...this.knownPersonalContactIds],
        comment: comment ?? this.comment,
        mostRecentUpdate: mostRecentUpdate ?? this.mostRecentUpdate,
        mostRecentChange: mostRecentChange ?? this.mostRecentChange,
      );

  @override
  List<Object?> get props => [
        coagContactId,
        details,
        systemContact,
        dhtSettings,
        sharedProfile,
        theirPersonalUniqueId,
        knownPersonalContactIds,
        name,
        comment,
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
    this.temporaryLocations = const {},
  });

  factory CoagContactDHTSchemaV1.fromJson(Map<String, dynamic> json) =>
      _$CoagContactDHTSchemaV1FromJson(json);

  final int schemaVersion = 1;
  final String coagContactId;
  final ContactDetails details;
  final Map<int, ContactAddressLocation> addressLocations;
  final Map<String, ContactTemporaryLocation> temporaryLocations;
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
    Map<String, ContactTemporaryLocation>? temporaryLocations,
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
    this.personalUniqueId,
    this.addressLocations = const {},
    this.temporaryLocations = const {},
    this.ackHandshakeComplete = false,
    this.knownPersonalContactIds = const [],
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
  final Map<String, ContactTemporaryLocation> temporaryLocations;
  final String? personalUniqueId;
  final String? shareBackDHTKey;
  final String? shareBackDHTWriter;
  final String? shareBackPubKey;
  final bool ackHandshakeComplete;
  final List<String> knownPersonalContactIds;
  late final DateTime? mostRecentUpdate;

  Map<String, dynamic> toJson() => _$CoagContactDHTSchemaV2ToJson(this);

  String toJsonStringWithoutPicture() =>
      jsonEncode(copyWith(details: details.copyWith(picture: [])).toJson());

  CoagContactDHTSchemaV2 copyWith({
    ContactDetails? details,
    String? shareBackDHTKey,
    String? shareBackDHTWriter,
    String? shareBackPubKey,
    String? personalUniqueId,
    Map<int, ContactAddressLocation>? addressLocations,
    Map<String, ContactTemporaryLocation>? temporaryLocations,
    List<String>? knownPersonalContactIds,
    bool? ackHandshakeComplete,
  }) =>
      CoagContactDHTSchemaV2(
        details: details ?? this.details.copyWith(),
        shareBackDHTKey: shareBackDHTKey ?? this.shareBackDHTKey,
        shareBackPubKey: shareBackPubKey ?? this.shareBackPubKey,
        shareBackDHTWriter: shareBackDHTWriter ?? this.shareBackDHTWriter,
        personalUniqueId: personalUniqueId ?? this.personalUniqueId,
        addressLocations: addressLocations ?? {...this.addressLocations},
        temporaryLocations: temporaryLocations ?? {...this.temporaryLocations},
        knownPersonalContactIds:
            knownPersonalContactIds ?? [...this.knownPersonalContactIds],
        ackHandshakeComplete: ackHandshakeComplete ?? this.ackHandshakeComplete,
      );

  // Differences in mostRecentUpdate timestamp will still caus equality
  @override
  List<Object?> get props => [
        schemaVersion,
        details,
        shareBackDHTKey,
        shareBackPubKey,
        shareBackDHTWriter,
        personalUniqueId,
        addressLocations,
        temporaryLocations,
        knownPersonalContactIds,
        ackHandshakeComplete,
      ];
}

CoagContactDHTSchemaV2 schemaV1toV2(CoagContactDHTSchemaV1 old) =>
    CoagContactDHTSchemaV2(
        details: old.details,
        personalUniqueId: old.coagContactId,
        shareBackDHTKey: old.shareBackDHTKey,
        shareBackDHTWriter: old.shareBackDHTWriter,
        // NOTE: This will cause downstream errors when trying to decrypt
        shareBackPubKey: old.shareBackPsk,
        addressLocations: old.addressLocations,
        temporaryLocations: old.temporaryLocations);

typedef CoagContactDHTSchema = CoagContactDHTSchemaV2;
