// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import '../../models/batch_invites.dart';
import '../../models/coag_contact.dart';
import '../../models/contact_update.dart';

abstract class PersistentStorage {
  Future<Map<String, CoagContact>> getAllContacts();
  Future<void> updateContact(CoagContact contact);
  Future<void> removeContact(String coagContactId);

  Future<List<ContactUpdate>> getUpdates();
  Future<void> addUpdate(ContactUpdate update);

  Future<Map<String, String>> getCircles();
  Future<void> updateCircles(Map<String, String> circles);

  Future<Map<String, List<String>>> getCircleMemberships();
  Future<void> updateCircleMemberships(
      Map<String, List<String>> circleMemberships);

  Future<ProfileInfo?> getProfileInfo();
  Future<void> updateProfileInfo(ProfileInfo info);

  Future<void> addBatch(BatchInvite batch);
  Future<List<BatchInvite>> getBatches();

  String debugInfo();
}
