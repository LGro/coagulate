// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'coag_contact.dart';

part 'backup.g.dart';

@JsonSerializable()
class AccountBackup extends Equatable {
  const AccountBackup(
      this.profileInfo, this.contacts, this.circles, this.circleMemberships);

  factory AccountBackup.fromJson(Map<String, dynamic> json) =>
      _$AccountBackupFromJson(json);

  // save profile info, including locations (exclude pictures?)
  final ProfileInfo profileInfo;
  // save contact dht sharing settings and names
  final List<CoagContact> contacts;
  final Map<String, String> circles;
  final Map<String, List<String>> circleMemberships;
  // TODO: app settings

  Map<String, dynamic> toJson() => _$AccountBackupToJson(this);

  @override
  List<Object?> get props =>
      [profileInfo, contacts, circles, circleMemberships];
}
