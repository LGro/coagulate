import 'dart:convert';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../proto/proto.dart' as proto;
import '../proto/proto.dart' show Contact;

import '../veilid_support/veilid_support.dart';
import 'account.dart';
import 'chat.dart';

part 'contact.g.dart';

Future<void> createContact({
  required ActiveAccountInfo activeAccountInfo,
  required proto.Profile profile,
  required IdentityMaster remoteIdentity,
  required TypedKey remoteConversationRecordKey,
  required TypedKey localConversationRecordKey,
}) async {
  final accountRecordKey =
      activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;

  // Create Contact
  final contact = Contact()
    ..editedProfile = profile
    ..remoteProfile = profile
    ..identityMasterJson = jsonEncode(remoteIdentity.toJson())
    ..identityPublicKey = TypedKey(
            kind: remoteIdentity.identityRecordKey.kind,
            value: remoteIdentity.identityPublicKey)
        .toProto()
    ..remoteConversationRecordKey = remoteConversationRecordKey.toProto()
    ..localConversationRecordKey = localConversationRecordKey.toProto()
    ..showAvailability = false;

  // Add Contact to account's list
  // if this fails, don't keep retrying, user can try again later
  await (await DHTShortArray.openOwned(
          proto.OwnedDHTRecordPointerProto.fromProto(
              activeAccountInfo.account.contactList),
          parent: accountRecordKey))
      .scope((contactList) async {
    if (await contactList.tryAddItem(contact.writeToBuffer()) == false) {
      throw Exception('Failed to add contact');
    }
  });
}

Future<void> deleteContact(
    {required ActiveAccountInfo activeAccountInfo,
    required Contact contact}) async {
  final pool = await DHTRecordPool.instance();
  final accountRecordKey =
      activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;
  final remoteConversationKey =
      proto.TypedKeyProto.fromProto(contact.remoteConversationRecordKey);

  // Remove any chats for this contact
  await deleteChat(
      activeAccountInfo: activeAccountInfo,
      remoteConversationRecordKey: remoteConversationKey);

  // Remove Contact from account's list
  await (await DHTShortArray.openOwned(
          proto.OwnedDHTRecordPointerProto.fromProto(
              activeAccountInfo.account.contactList),
          parent: accountRecordKey))
      .scope((contactList) async {
    for (var i = 0; i < contactList.length; i++) {
      final item =
          await contactList.getItemProtobuf(proto.Contact.fromBuffer, i);
      if (item == null) {
        throw Exception('Failed to get contact');
      }
      if (item.remoteConversationRecordKey ==
          contact.remoteConversationRecordKey) {
        await contactList.tryRemoveItem(i);
        break;
      }
    }
    await (await pool.openRead(
            proto.TypedKeyProto.fromProto(contact.localConversationRecordKey),
            parent: accountRecordKey))
        .delete();
    await (await pool.openRead(remoteConversationKey, parent: accountRecordKey))
        .delete();
  });
}

/// Get the active account contact list
@riverpod
Future<IList<Contact>?> fetchContactList(FetchContactListRef ref) async {
  // See if we've logged into this account or if it is locked
  final activeAccountInfo = await ref.watch(fetchActiveAccountProvider.future);
  if (activeAccountInfo == null) {
    return null;
  }
  final accountRecordKey =
      activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;

  // Decode the contact list from the DHT
  IList<Contact> out = const IListConst([]);
  await (await DHTShortArray.openOwned(
          proto.OwnedDHTRecordPointerProto.fromProto(
              activeAccountInfo.account.contactList),
          parent: accountRecordKey))
      .scope((cList) async {
    for (var i = 0; i < cList.length; i++) {
      final cir = await cList.getItem(i);
      if (cir == null) {
        throw Exception('Failed to get contact');
      }
      out = out.add(Contact.fromBuffer(cir));
    }
  });

  return out;
}
