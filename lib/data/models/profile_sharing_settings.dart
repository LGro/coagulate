// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'profile_sharing_settings.g.dart';

/// Lists of circle IDs that have access to the corresponding name fields
@JsonSerializable()
class NameSharingSettings extends Equatable {
  const NameSharingSettings({
    this.first = const [],
    this.last = const [],
    this.middle = const [],
    this.prefix = const [],
    this.suffix = const [],
    this.nickname = const [],
    this.firstPhonetic = const [],
    this.lastPhonetic = const [],
    this.middlePhonetic = const [],
  });

  factory NameSharingSettings.fromJson(Map<String, dynamic> json) =>
      _$NameSharingSettingsFromJson(json);

  final List<String> first;
  final List<String> last;
  final List<String> middle;
  final List<String> prefix;
  final List<String> suffix;
  final List<String> nickname;
  final List<String> firstPhonetic;
  final List<String> lastPhonetic;
  final List<String> middlePhonetic;

  NameSharingSettings copyWith(
    List<String>? first,
    List<String>? last,
    List<String>? middle,
    List<String>? prefix,
    List<String>? suffix,
    List<String>? nickname,
    List<String>? firstPhonetic,
    List<String>? lastPhonetic,
    List<String>? middlePhonetic,
  ) =>
      NameSharingSettings(
        first: first ?? this.first,
        last: last ?? this.last,
        middle: middle ?? this.middle,
        prefix: prefix ?? this.prefix,
        suffix: suffix ?? this.suffix,
        nickname: nickname ?? this.nickname,
        firstPhonetic: firstPhonetic ?? this.firstPhonetic,
        lastPhonetic: lastPhonetic ?? this.lastPhonetic,
        middlePhonetic: middlePhonetic ?? this.middlePhonetic,
      );

  @override
  List<Object?> get props => [
        first,
        last,
        middle,
        prefix,
        suffix,
        nickname,
        firstPhonetic,
        lastPhonetic,
        middlePhonetic,
      ];

  Map<String, dynamic> toJson() => _$NameSharingSettingsToJson(this);
}

@JsonSerializable()
class ProfileSharingSettings extends Equatable {
  const ProfileSharingSettings({
    this.displayName = const [],
    this.name = const NameSharingSettings(),
    this.phones = const {},
    this.emails = const {},
    this.addresses = const {},
    this.organizations = const {},
    this.websites = const {},
    this.socialMedias = const {},
    this.events = const {},
  });

  factory ProfileSharingSettings.fromJson(Map<String, dynamic> json) =>
      _$ProfileSharingSettingsFromJson(json);

  /// List of circle IDs that have access to the displayName
  final List<String> displayName;

  /// Settings for which of the name fields are shared with which circle
  final NameSharingSettings name;

  /// Map of index|label to circle IDs that have access to phones
  final Map<String, List<String>> phones;

  /// Map of index|label to circle IDs that have access to emails
  final Map<String, List<String>> emails;

  /// Map of index|label to circle IDs that have access to addresses
  final Map<String, List<String>> addresses;

  /// Map of index|label to circle IDs that have access to organizations
  final Map<String, List<String>> organizations;

  /// Map of index|label to circle IDs that have access to websites
  final Map<String, List<String>> websites;

  /// Map of index|label to circle IDs that have access to socialMedias
  final Map<String, List<String>> socialMedias;

  /// Map of index|label to circle IDs that have access to events
  final Map<String, List<String>> events;

  Map<String, dynamic> toJson() => _$ProfileSharingSettingsToJson(this);

  ProfileSharingSettings copyWith({
    List<String>? displayName,
    NameSharingSettings? name,
    Map<String, List<String>>? phones,
    Map<String, List<String>>? emails,
    Map<String, List<String>>? addresses,
    Map<String, List<String>>? organizations,
    Map<String, List<String>>? websites,
    Map<String, List<String>>? socialMedias,
    Map<String, List<String>>? events,
  }) =>
      ProfileSharingSettings(
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
