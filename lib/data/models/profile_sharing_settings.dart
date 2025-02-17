// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'profile_sharing_settings.g.dart';

@JsonSerializable()
class ProfileSharingSettings extends Equatable {
  const ProfileSharingSettings({
    this.names = const {},
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

  /// Map of name ID to circle IDs that have access to names
  final Map<String, List<String>> names;

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
    Map<String, List<String>>? names,
    Map<String, List<String>>? phones,
    Map<String, List<String>>? emails,
    Map<String, List<String>>? addresses,
    Map<String, List<String>>? organizations,
    Map<String, List<String>>? websites,
    Map<String, List<String>>? socialMedias,
    Map<String, List<String>>? events,
  }) =>
      ProfileSharingSettings(
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
