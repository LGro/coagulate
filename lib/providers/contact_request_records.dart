import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:veilid/veilid.dart';

import '../entities/entities.dart';
import '../entities/proto.dart' as proto;
import '../tools/tools.dart';
import '../veilid_support/veilid_support.dart';
import 'logins.dart';

part 'contact_request_records.g.dart';

// Contact invitation records stored in Account
class ContactRequestRecords extends DHTList<proto.ContactRequestRecord> {
  //

  Future<proto.ContactRequestRecord> newContactRequest(
    proto.EncryptionKind encryptionKind,
    String encryptionKey,
  ) async {
    //
  }
}

class ContactRequestRecordsParams {
  ContactRequestRecordsParams({required this.contactRequestsDHTListKey});
  TypedKey contactRequestsDHTListKey;
}

@riverpod
Future<ContactRequestRecords?> fetchContactRequestRecords(
    FetchContactRequestRecordsRef ref,
    {required ContactRequestRecordsParams params}) async {
  // final localAccounts = await ref.watch(localAccountsProvider.future);
  // try {
  //   return localAccounts.firstWhere(
  //       (e) => e.identityMaster.masterRecordKey == accountMasterRecordKey);
  // } on Exception catch (e) {
  //   if (e is StateError) {
  //     return null;
  //   }
  //   rethrow;
  // }
}
