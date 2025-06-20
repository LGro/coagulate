// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:veilid/veilid.dart';

import 'contact_introduction.dart';
import 'contact_location.dart';
import 'profile_sharing_settings.dart';

part 'coag_contact.g.dart';

@JsonSerializable()
class DhtSettings extends Equatable {
  const DhtSettings({
    required this.myKeyPair,
    this.myNextKeyPair,
    this.theirPublicKey,
    this.theirNextPublicKey,
    this.recordKeyMeSharing,
    this.writerMeSharing,
    this.recordKeyThemSharing,
    this.writerThemSharing,
    this.initialSecret,
    this.theyAckHandshakeComplete = false,
  });

  factory DhtSettings.fromJson(Map<String, dynamic> json) =>
      _$DhtSettingsFromJson(json);

  /// Acknowledged key pair to use for deriving symmetric key for decrypting and
  /// encrypting updates
  final TypedKeyPair myKeyPair;

  /// Replacement key pair to use for deriving symmetric key for decrypting and
  /// encrypting updates in the future as soon as acknowledged
  final TypedKeyPair? myNextKeyPair;

  /// Current public keys to derive a key for decrypting received updates
  final PublicKey? theirPublicKey;

  /// Replacement public keys to use for deriving symmetric key for decrypting
  /// and encrypting updates in the future
  final PublicKey? theirNextPublicKey;

  final Typed<FixedEncodedString43>? recordKeyMeSharing;
  final KeyPair? writerMeSharing;
  final Typed<FixedEncodedString43>? recordKeyThemSharing;
  final KeyPair? writerThemSharing;
  final FixedEncodedString43? initialSecret;
  final bool theyAckHandshakeComplete;

  Map<String, dynamic> toJson() => _$DhtSettingsToJson(this);

  DhtSettings copyWith({
    TypedKeyPair? myKeyPair,
    TypedKeyPair? myNextKeyPair,
    PublicKey? theirPublicKey,
    PublicKey? theirNextPublicKey,
    Typed<FixedEncodedString43>? recordKeyMeSharing,
    KeyPair? writerMeSharing,
    Typed<FixedEncodedString43>? recordKeyThemSharing,
    KeyPair? writerThemSharing,
    FixedEncodedString43? initialSecret,
    bool? theyAckHandshakeComplete,
  }) =>
      DhtSettings(
        myKeyPair: myKeyPair ?? this.myKeyPair,
        myNextKeyPair: myNextKeyPair ?? this.myNextKeyPair,
        theirPublicKey: theirPublicKey ?? this.theirPublicKey,
        theirNextPublicKey: theirNextPublicKey ?? this.theirNextPublicKey,
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
        myNextKeyPair,
        theirPublicKey,
        theirNextPublicKey,
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

  factory ContactDHTSettings.fromJson(Map<String, dynamic> json) =>
      _$ContactDHTSettingsFromJson(json);

  final String key;

  /// Optional writer key pair in case I shared first and offered a DHT record
  /// for my peer to share back
  final String? writer;

  /// Optional pre-shared secret in case I shared first and did not yet have
  /// their public key
  final String? psk;
  final String? pubKey;
  final DateTime? lastUpdated;

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
    this.phones = const {},
    this.emails = const {},
    this.websites = const {},
    this.socialMedias = const {},
    this.events = const {},
    this.organizations = const {},
  });

  factory ContactDetails.fromJson(Map<String, dynamic> json) =>
      _$ContactDetailsFromJson(
          migrateContactDetailsJsonFromFlutterContactsTypeToSimpleMaps(json));

  Contact toSystemContact(
          String displayName, Map<String, ContactAddressLocation> addresses) =>
      Contact(
        displayName: displayName,
        photo: (picture == null) ? null : Uint8List.fromList(picture!),
        phones: phones.entries
            .map((e) =>
                Phone(e.value, label: PhoneLabel.custom, customLabel: e.key))
            .toList(),
        emails: emails.entries
            .map((e) =>
                Email(e.value, label: EmailLabel.custom, customLabel: e.key))
            .toList(),
        addresses: addresses.entries
            .map((e) => Address(e.value.address ?? '',
                label: AddressLabel.custom, customLabel: e.key))
            .toList(),
        websites: websites.entries
            .map((e) => Website(e.value,
                label: WebsiteLabel.custom, customLabel: e.key))
            .toList(),
        socialMedias: socialMedias.entries
            .map((e) => SocialMedia(e.value,
                label: SocialMediaLabel.custom, customLabel: e.key))
            .toList(),
        events: events.entries
            .map((e) => Event(
                day: e.value.day,
                month: e.value.month,
                year: e.value.year,
                label: EventLabel.custom,
                customLabel: e.key))
            .toList(),
        organizations: [...organizations.values],
      );

  /// Binary integer representation of an image
  final List<int>? picture;

  /// Public identity key
  final String? publicKey;

  /// Names with unique key
  final Map<String, String> names;

  /// Phone numbers.
  final Map<String, String> phones;

  /// Email addresses.
  final Map<String, String> emails;

  /// Websites.
  final Map<String, String> websites;

  /// Social media / instant messaging profiles.
  final Map<String, String> socialMedias;

  /// Events / birthdays.
  final Map<String, DateTime> events;

  // Organizations like companies with role info.
  final Map<String, Organization> organizations;

  Map<String, dynamic> toJson() => _$ContactDetailsToJson(this);

  ContactDetails copyWith({
    List<int>? picture,
    String? publicKey,
    Map<String, String>? names,
    Map<String, String>? phones,
    Map<String, String>? emails,
    Map<String, String>? websites,
    Map<String, String>? socialMedias,
    Map<String, DateTime>? events,
    Map<String, Organization>? organizations,
  }) =>
      ContactDetails(
        picture:
            picture ?? ((this.picture == null) ? null : [...this.picture!]),
        publicKey: publicKey ?? this.publicKey,
        names: {...names ?? this.names},
        phones: {...phones ?? this.phones},
        emails: {...emails ?? this.emails},
        websites: {...websites ?? this.websites},
        socialMedias: {...socialMedias ?? this.socialMedias},
        events: {...events ?? this.events},
        organizations: {...organizations ?? this.organizations},
      );

  @override
  List<Object?> get props => [
        picture,
        publicKey,
        names,
        phones,
        emails,
        websites,
        socialMedias,
        events,
        organizations,
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
    this.mainKeyPair,
  });

  factory ProfileInfo.fromJson(Map<String, dynamic> json) =>
      _$ProfileInfoFromJson(
          migrateContactAddressLocationFromIntToLabelIndexing(json));

  final String id;
  final ContactDetails details;
  final Map<String, List<int>> pictures;

  /// Map from label to address location
  final Map<String, ContactAddressLocation> addressLocations;

  /// Map from label to temporary location
  final Map<String, ContactTemporaryLocation> temporaryLocations;
  final ProfileSharingSettings sharingSettings;

  /// The main public identity key pair
  final TypedKeyPair? mainKeyPair;

  Map<String, dynamic> toJson() => _$ProfileInfoToJson(this);
  ProfileInfo copyWith({
    ContactDetails? details,
    Map<String, List<int>>? pictures,
    Map<String, ContactAddressLocation>? addressLocations,
    Map<String, ContactTemporaryLocation>? temporaryLocations,
    ProfileSharingSettings? sharingSettings,
    TypedKeyPair? mainKeyPair,
  }) =>
      ProfileInfo(
        id,
        details: (details ?? this.details).copyWith(),
        pictures: {...pictures ?? this.pictures},
        addressLocations: {...addressLocations ?? this.addressLocations},
        temporaryLocations: {...temporaryLocations ?? this.temporaryLocations},
        sharingSettings: (sharingSettings ?? this.sharingSettings).copyWith(),
        mainKeyPair: mainKeyPair ?? this.mainKeyPair,
      );

  @override
  List<Object?> get props => [
        id,
        details,
        pictures,
        addressLocations,
        temporaryLocations,
        sharingSettings,
        mainKeyPair,
      ];
}

@JsonSerializable()
class CoagContact extends Equatable {
  const CoagContact({
    required this.coagContactId,
    required this.name,
    required this.dhtSettings,
    required this.myIdentity,
    this.details,
    this.theirIdentity,
    this.connectionAttestations = const [],
    this.systemContactId,
    this.addressLocations = const {},
    this.temporaryLocations = const {},
    this.comment = '',
    this.sharedProfile,
    this.introductionsForThem = const [],
    this.introductionsByThem = const [],
    this.mostRecentUpdate,
    this.mostRecentChange,
  });

  final String coagContactId;

  /// Their long lived typed identity key, used for example to derive a
  /// connection attestation for enabling others to discover shared contacts
  final Typed<PublicKey>? theirIdentity;

  /// My long lived typed identity key pair, used for example to derive a
  /// connection attestation for enabling others to discover shared contacts
  final TypedKeyPair myIdentity;

  /// All connection attestations they provide for shared contact discovery
  final List<String> connectionAttestations;

  /// Name given to the contact by the app user
  final String name;

  /// Associated system contact
  final String? systemContactId;

  /// Details shared by the contact
  final ContactDetails? details;

  /// Comment from the app user about the contact for personal reference
  final String comment;

  // This is a map from index to value instead of a list because only the ith
  // address could have a location
  final Map<String, ContactAddressLocation> addressLocations;
  final Map<String, ContactTemporaryLocation> temporaryLocations;

  /// Cryptographic keys and DHT record info for sharing with this contact
  final DhtSettings dhtSettings;

  /// Personalized selection of profile info that is shared with this contact
  final CoagContactDHTSchema? sharedProfile;

  /// Introductions the app user proposed them
  final List<ContactIntroduction> introductionsForThem;

  /// Introductions this contact proposed the app user
  final List<ContactIntroduction> introductionsByThem;

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
    return _$CoagContactFromJson(
        migrateContactAddressLocationFromIntToLabelIndexing(json));
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
    String? systemContactId,
    ContactDetails? details,
    Typed<PublicKey>? theirIdentity,
    TypedKeyPair? myIdentity,
    List<String>? connectionAttestations,
    Map<String, ContactAddressLocation>? addressLocations,
    Map<String, ContactTemporaryLocation>? temporaryLocations,
    DhtSettings? dhtSettings,
    CoagContactDHTSchema? sharedProfile,
    List<ContactIntroduction>? introductionsByThem,
    List<ContactIntroduction>? introductionsForThem,
    DateTime? mostRecentUpdate,
    DateTime? mostRecentChange,
  }) =>
      CoagContact(
        coagContactId: coagContactId ?? this.coagContactId,
        details: (details ?? this.details)?.copyWith(),
        systemContactId: systemContactId ?? this.systemContactId,
        addressLocations: {...addressLocations ?? this.addressLocations},
        temporaryLocations: {...temporaryLocations ?? this.temporaryLocations},
        dhtSettings: (dhtSettings ?? this.dhtSettings).copyWith(),
        sharedProfile: (sharedProfile ?? this.sharedProfile)?.copyWith(),
        name: name ?? this.name,
        theirIdentity: theirIdentity ?? this.theirIdentity,
        myIdentity: myIdentity ?? this.myIdentity,
        connectionAttestations: [
          ...connectionAttestations ?? this.connectionAttestations
        ],
        comment: comment ?? this.comment,
        introductionsByThem: [
          ...introductionsByThem ?? this.introductionsByThem
        ],
        introductionsForThem: [
          ...introductionsForThem ?? this.introductionsForThem
        ],
        mostRecentUpdate: mostRecentUpdate ?? this.mostRecentUpdate,
        mostRecentChange: mostRecentChange ?? this.mostRecentChange,
      );

  @override
  List<Object?> get props => [
        coagContactId,
        details,
        systemContactId,
        dhtSettings,
        sharedProfile,
        theirIdentity,
        myIdentity,
        connectionAttestations,
        name,
        comment,
        addressLocations,
        temporaryLocations,
        introductionsByThem,
        introductionsForThem,
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
    this.identityKey,
    this.addressLocations = const {},
    this.temporaryLocations = const {},
    this.connectionAttestations = const [],
    this.introductions = const [],
    this.ackHandshakeComplete = false,
    DateTime? mostRecentUpdate,
  }) {
    this.mostRecentUpdate = mostRecentUpdate ?? DateTime.now();
  }
  factory CoagContactDHTSchemaV2.fromJson(Map<String, dynamic> json) {
    final schemaVersion = json['schema_version'] as int?;
    if (schemaVersion == 2) {
      return _$CoagContactDHTSchemaV2FromJson(
          migrateContactAddressLocationFromIntToLabelIndexing(json));
    } else {
      // Legacy compatibility when we were still missing the schema version
      try {
        return _$CoagContactDHTSchemaV2FromJson(
            migrateContactAddressLocationFromIntToLabelIndexing(json));
      } on FormatException {
        return schemaV1toV2(_$CoagContactDHTSchemaV1FromJson(json));
      }
    }
  }

  /// Schema version to facilitate data migration
  @JsonKey(includeToJson: true)
  final int schemaVersion = 2;

  /// Shared contact details of author
  final ContactDetails details;

  /// Shared address locations of author
  final Map<String, ContactAddressLocation> addressLocations;

  /// Shared temporary locations of author
  final Map<String, ContactTemporaryLocation> temporaryLocations;

  /// DHT record key for recipient to share back
  final String? shareBackDHTKey;

  /// DHT record writer for recipient to share back
  final String? shareBackDHTWriter;

  /// The next author public key for the recipient to use when encrypting
  /// their shared back information and to try when decrypting the next update
  final String? shareBackPubKey;
  final bool ackHandshakeComplete;

  /// Long lived identity key, used for example to derive a connection
  /// attestation for enabling others to discover shared contacts
  final Typed<PublicKey>? identityKey;

  /// Attestations for connections between the author and their contacts
  final List<String> connectionAttestations;

  /// Introduction proposals by the author for the recipient
  final List<ContactIntroduction> introductions;
  late final DateTime? mostRecentUpdate;

  Map<String, dynamic> toJson() => _$CoagContactDHTSchemaV2ToJson(this);

  String toJsonStringWithoutPicture() =>
      jsonEncode(copyWith(details: details.copyWith(picture: [])).toJson());

  CoagContactDHTSchemaV2 copyWith({
    ContactDetails? details,
    String? shareBackDHTKey,
    String? shareBackDHTWriter,
    String? shareBackPubKey,
    Typed<PublicKey>? identityKey,
    Map<String, ContactAddressLocation>? addressLocations,
    Map<String, ContactTemporaryLocation>? temporaryLocations,
    List<String>? connectionAttestations,
    List<ContactIntroduction>? introductions,
    bool? ackHandshakeComplete,
  }) =>
      CoagContactDHTSchemaV2(
        details: (details ?? this.details).copyWith(),
        shareBackDHTKey: shareBackDHTKey ?? this.shareBackDHTKey,
        shareBackPubKey: shareBackPubKey ?? this.shareBackPubKey,
        shareBackDHTWriter: shareBackDHTWriter ?? this.shareBackDHTWriter,
        identityKey: identityKey ?? this.identityKey,
        addressLocations: {...addressLocations ?? this.addressLocations},
        temporaryLocations: {...temporaryLocations ?? this.temporaryLocations},
        connectionAttestations: [
          ...connectionAttestations ?? this.connectionAttestations
        ],
        introductions: [...introductions ?? this.introductions],
        ackHandshakeComplete: ackHandshakeComplete ?? this.ackHandshakeComplete,
      );

  // Differences in mostRecentUpdate timestamp will still cause equality
  @override
  List<Object?> get props => [
        schemaVersion,
        details,
        addressLocations,
        temporaryLocations,
        shareBackDHTKey,
        shareBackDHTWriter,
        shareBackPubKey,
        identityKey,
        connectionAttestations,
        introductions,
        ackHandshakeComplete,
      ];
}

CoagContactDHTSchemaV2 schemaV1toV2(CoagContactDHTSchemaV1 old) =>
    CoagContactDHTSchemaV2(
        details: old.details,
        shareBackDHTKey: old.shareBackDHTKey,
        shareBackDHTWriter: old.shareBackDHTWriter,
        // NOTE: This will cause downstream errors when trying to decrypt
        shareBackPubKey: old.shareBackPsk,
        addressLocations: old.addressLocations
            .map((label, address) => MapEntry(label.toString(), address)),
        temporaryLocations: old.temporaryLocations);

typedef CoagContactDHTSchema = CoagContactDHTSchemaV2;

const coagulateManagedLabelSuffix = '[coagulate]';

bool noCoagulateLabelSuffix<T>(T detail) {
  if (detail is Phone) {
    return !detail.customLabel.endsWith(coagulateManagedLabelSuffix);
  }
  if (detail is Email) {
    return !detail.customLabel.endsWith(coagulateManagedLabelSuffix);
  }
  if (detail is Address) {
    return !detail.customLabel.endsWith(coagulateManagedLabelSuffix);
  }
  if (detail is Website) {
    return !detail.customLabel.endsWith(coagulateManagedLabelSuffix);
  }
  if (detail is SocialMedia) {
    return !detail.customLabel.endsWith(coagulateManagedLabelSuffix);
  }
  if (detail is Event) {
    return !detail.customLabel.endsWith(coagulateManagedLabelSuffix);
  }
  if (detail is Note) {
    return !detail.note.endsWith(coagulateManagedLabelSuffix);
  }
  return true;
}

T updateContactDetailLabel<T>(
    T detail, String Function(String label) updateFunction) {
  if (detail is Phone) {
    return Phone(
      detail.number,
      label: PhoneLabel.custom,
      customLabel: updateFunction(detail.customLabel),
      normalizedNumber: detail.normalizedNumber,
      isPrimary: detail.isPrimary,
    ) as T;
  }
  if (detail is Email) {
    return Email(
      detail.address,
      label: EmailLabel.custom,
      customLabel: updateFunction(detail.customLabel),
      isPrimary: detail.isPrimary,
    ) as T;
  }
  if (detail is Address) {
    return Address(
      detail.address,
      label: detail.label = AddressLabel.custom,
      customLabel: updateFunction(detail.customLabel),
      street: detail.street,
      pobox: detail.pobox,
      neighborhood: detail.neighborhood,
      city: detail.city,
      state: detail.state,
      postalCode: detail.postalCode,
      country: detail.country,
      isoCountry: detail.isoCountry,
      subAdminArea: detail.subAdminArea,
      subLocality: detail.subLocality,
    ) as T;
  }
  if (detail is Website) {
    return Website(
      detail.url,
      label: WebsiteLabel.custom,
      customLabel: updateFunction(detail.customLabel),
    ) as T;
  }
  if (detail is SocialMedia) {
    return SocialMedia(
      detail.userName,
      label: SocialMediaLabel.custom,
      customLabel: updateFunction(detail.customLabel),
    ) as T;
  }
  if (detail is Event) {
    return Event(
      year: detail.year,
      month: detail.month,
      day: detail.day,
      label: EventLabel.custom,
      customLabel: updateFunction(detail.customLabel),
    ) as T;
  }
  if (detail is Note) {
    return Note(updateFunction(detail.note)) as T;
  }
  return detail;
}

String removeCountryCodePrefix(String number) {
  if (!number.startsWith('+')) {
    return number;
  }
  final parsed = PhoneNumber.parse(number);
  return number.replaceFirst(parsed.countryCode, '');
}

bool coveredByCoagulate<T>(T detail, List<T> coagDetails) {
  if (detail is Phone) {
    // TODO: Be smart about country codes
    return coagDetails.map((d) => (d as Phone).number).contains(detail.number);
  }
  if (detail is Email) {
    return coagDetails
        .map((d) => (d as Email).address)
        .contains(detail.address);
  }
  if (detail is Address) {
    return coagDetails
        .map((d) => (d as Address).address)
        .contains(detail.address);
  }
  if (detail is Website) {
    return coagDetails.map((d) => (d as Website).url).contains(detail.url);
  }
  if (detail is SocialMedia) {
    return coagDetails
        .map((d) => (d as SocialMedia).userName)
        .contains(detail.userName);
  }
  if (detail is Note) {
    return coagDetails.map((d) => (d as Note).note).contains(detail.note);
  }
  if (detail is Event) {
    // TODO: Figure out how to match these
    return false;
  }
  return false;
}

String addCoagSuffix(String value) =>
    '${removeCoagSuffix(value)} $coagulateManagedLabelSuffix';

String removeCoagSuffix(String value) =>
    value.trimRight().replaceAll(coagulateManagedLabelSuffix, '').trimRight();

String addCoagSuffixNewline(String value) =>
    '${removeCoagSuffix(value)}\n\n$coagulateManagedLabelSuffix';

// TODO: Figure out what to do about the (display) name
Contact mergeSystemContacts(Contact system, Contact coagulate) => system
  ..phones = [
    ...system.phones
        .where(noCoagulateLabelSuffix)
        .where((v) => !coveredByCoagulate(v, coagulate.phones)),
    ...coagulate.phones.map((v) => updateContactDetailLabel(v, addCoagSuffix)),
  ]
  ..emails = [
    ...system.emails
        .where(noCoagulateLabelSuffix)
        .where((v) => !coveredByCoagulate(v, coagulate.emails)),
    ...coagulate.emails.map((v) => updateContactDetailLabel(v, addCoagSuffix)),
  ]
  ..addresses = [
    ...system.addresses
        .where(noCoagulateLabelSuffix)
        .where((v) => !coveredByCoagulate(v, coagulate.addresses)),
    ...coagulate.addresses
        .map((v) => updateContactDetailLabel(v, addCoagSuffix)),
  ]
  ..websites = [
    ...system.websites
        .where(noCoagulateLabelSuffix)
        .where((v) => !coveredByCoagulate(v, coagulate.websites)),
    ...coagulate.websites
        .map((v) => updateContactDetailLabel(v, addCoagSuffix)),
  ]
  ..socialMedias = [
    ...system.socialMedias
        .where(noCoagulateLabelSuffix)
        .where((v) => !coveredByCoagulate(v, coagulate.socialMedias)),
    ...coagulate.socialMedias
        .map((v) => updateContactDetailLabel(v, addCoagSuffix)),
  ]
  ..events = [
    ...system.events
        .where(noCoagulateLabelSuffix)
        .where((v) => !coveredByCoagulate(v, coagulate.events)),
    ...coagulate.events.map((v) => updateContactDetailLabel(v, addCoagSuffix)),
  ]
  ..notes = [
    ...system.notes
        .where(noCoagulateLabelSuffix)
        .where((v) => !coveredByCoagulate(v, coagulate.notes)),
    ...coagulate.notes
        .map((v) => updateContactDetailLabel(v, addCoagSuffixNewline)),
  ];

Contact removeCoagManagedSuffixes(Contact contact) => contact
  ..phones = [
    ...contact.phones.map((v) => updateContactDetailLabel(v, removeCoagSuffix))
  ]
  ..emails = [
    ...contact.emails.map((v) => updateContactDetailLabel(v, removeCoagSuffix))
  ]
  ..addresses = [
    ...contact.addresses
        .map((v) => updateContactDetailLabel(v, removeCoagSuffix))
  ]
  ..websites = [
    ...contact.websites
        .map((v) => updateContactDetailLabel(v, removeCoagSuffix))
  ]
  ..socialMedias = [
    ...contact.socialMedias
        .map((v) => updateContactDetailLabel(v, removeCoagSuffix))
  ]
  ..events = [
    ...contact.events.map((v) => updateContactDetailLabel(v, removeCoagSuffix))
  ]
  ..notes = [
    ...contact.notes.map((v) => updateContactDetailLabel(v, removeCoagSuffix))
  ];

(String, String) simplifyFlutterContactsDetailType<T>(T detail) {
  if (T == Phone) {
    final d = detail as Phone;
    return (
      (d.label == PhoneLabel.custom) ? d.customLabel : d.label.name,
      d.number,
    );
  }
  if (T == Email) {
    final d = detail as Email;
    return (
      (d.label == EmailLabel.custom) ? d.customLabel : d.label.name,
      d.address,
    );
  }
  if (T == Address) {
    final d = detail as Address;
    return (
      (d.label == AddressLabel.custom) ? d.customLabel : d.label.name,
      d.address,
    );
  }
  if (T == Website) {
    final d = detail as Website;
    return (
      (d.label == WebsiteLabel.custom) ? d.customLabel : d.label.name,
      d.url,
    );
  }
  if (T == SocialMedia) {
    final d = detail as SocialMedia;
    return (
      (d.label == SocialMediaLabel.custom) ? d.customLabel : d.label.name,
      d.userName,
    );
  }
  throw Exception(
      'Unexpected type $T for flutter contacts detail simplification');
}

Map<String, dynamic>
    migrateContactDetailsJsonFromFlutterContactsTypeToSimpleMaps(
        Map<String, dynamic> json) {
  final migrated = <String, dynamic>{};
  for (final key in json.keys) {
    if (json[key] is List<dynamic>) {
      if (key == 'phones') {
        migrated[key] = Map.fromEntries((json[key] as List<dynamic>)
            .map((e) => Phone.fromJson(e as Map<String, dynamic>))
            .map(simplifyFlutterContactsDetailType)
            .map((v) => MapEntry(v.$1, v.$2)));
      } else if (key == 'emails') {
        migrated[key] = Map.fromEntries((json[key] as List<dynamic>)
            .map((e) => Email.fromJson(e as Map<String, dynamic>))
            .map(simplifyFlutterContactsDetailType)
            .map((v) => MapEntry(v.$1, v.$2)));
      } else if (key == 'addresses') {
        migrated[key] = Map.fromEntries((json[key] as List<dynamic>)
            .map((e) => Address.fromJson(e as Map<String, dynamic>))
            .map(simplifyFlutterContactsDetailType)
            .map((v) => MapEntry(v.$1, v.$2)));
      } else if (key == 'websites') {
        migrated[key] = Map.fromEntries((json[key] as List<dynamic>)
            .map((e) => Website.fromJson(e as Map<String, dynamic>))
            .map(simplifyFlutterContactsDetailType)
            .map((v) => MapEntry(v.$1, v.$2)));
      } else if (key == 'social_medias') {
        migrated[key] = Map.fromEntries((json[key] as List<dynamic>)
            .map((e) => SocialMedia.fromJson(e as Map<String, dynamic>))
            .map(simplifyFlutterContactsDetailType)
            .map((v) => MapEntry(v.$1, v.$2)));
      } else if (key == 'events') {
        migrated[key] = <String, dynamic>{};
      } else {
        migrated[key] = json[key];
      }
    } else {
      migrated[key] = json[key];
    }
  }
  return migrated;
}

/// Help with the switch from Map<int, ContactAddressLocation> to
/// Map<String, ContactAddressLocation>
Map<String, dynamic> migrateContactAddressLocationFromIntToLabelIndexing(
    Map<String, dynamic> json) {
  final _json = {...json};
  if (_json.containsKey('address_locations')) {
    final addressLocations = _json['address_locations'] as Map<String, dynamic>;
    _json['address_locations'] = Map<String, dynamic>.from(addressLocations
        .map((key, address) => MapEntry(address['name'] ?? key, address)));
  }
  return _json;
}
