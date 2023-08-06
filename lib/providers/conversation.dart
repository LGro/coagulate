import 'dart:convert';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../entities/identity.dart';
import '../entities/proto.dart' as proto;
import '../entities/proto.dart' show Conversation;

import '../veilid_support/veilid_support.dart';
import 'account.dart';

//part 'conversation.g.dart';

Future<DHTRecordCrypto> getConversationCrypto({
  required ActiveAccountInfo activeAccountInfo,
  required TypedKey remoteIdentityPublicKey,
}) async {
  final veilid = await eventualVeilid.future;
  final identitySecret = activeAccountInfo.userLogin.identitySecret;
  final cs = await veilid.getCryptoSystem(identitySecret.kind);
  final sharedSecret =
      await cs.cachedDH(remoteIdentityPublicKey.value, identitySecret.value);
  return DHTRecordCryptoPrivate.fromSecret(identitySecret.kind, sharedSecret);
}

// Create a conversation
// If we were the initator of the conversation there may be an
// incomplete 'existingConversationRecord' that we need to fill
// in now that we have the remote identity key
Future<T> createConversation<T>(
    {required ActiveAccountInfo activeAccountInfo,
    required TypedKey remoteIdentityPublicKey,
    required FutureOr<T> Function(DHTRecord) callback,
    OwnedDHTRecordPointer? existingConversationOwned}) async {
  final pool = await DHTRecordPool.instance();
  final accountRecordKey =
      activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;

  final crypto = await getConversationCrypto(
      activeAccountInfo: activeAccountInfo,
      remoteIdentityPublicKey: remoteIdentityPublicKey);

  late final DHTRecord localConversationRecord;
  if (existingConversationOwned != null) {
    localConversationRecord = await pool.openOwned(existingConversationOwned,
        parent: accountRecordKey, crypto: crypto);
  } else {
    localConversationRecord =
        await pool.create(parent: accountRecordKey, crypto: crypto);
  }
  return localConversationRecord
      // ignore: prefer_expression_function_bodies
      .deleteScope((localConversation) async {
    // Make messages log
    return (await DHTShortArray.create(
            parent: localConversation.key, crypto: crypto))
        .deleteScope((messages) async {
      // Write local conversation key
      final conversation = Conversation()
        ..profile = activeAccountInfo.account.profile
        ..identityMasterJson =
            jsonEncode(activeAccountInfo.localAccount.identityMaster.toJson())
        ..messages = messages.record.ownedDHTRecordPointer.toProto();

      //
      final update = await localConversation.tryWriteProtobuf(
          Conversation.fromBuffer, conversation);
      if (update != null) {
        throw Exception('Failed to write local conversation');
      }
      return await callback(localConversation);
    });
  });
}

Future<Conversation?> readRemoteConversation({
  required ActiveAccountInfo activeAccountInfo,
  required TypedKey remoteIdentityPublicKey,
  required TypedKey remoteConversationKey,
}) async {
  final accountRecordKey =
      activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;
  final pool = await DHTRecordPool.instance();

  final crypto = await getConversationCrypto(
      activeAccountInfo: activeAccountInfo,
      remoteIdentityPublicKey: remoteIdentityPublicKey);
  return (await pool.openRead(remoteConversationKey,
          parent: accountRecordKey, crypto: crypto))
      .scope((remoteConversation) async {
    //
    final conversation =
        await remoteConversation.getProtobuf(Conversation.fromBuffer);
    return conversation;
  });
}

Future<Conversation?> writeLocalConversation({
  required ActiveAccountInfo activeAccountInfo,
  required OwnedDHTRecordPointer localConversationOwned,
  required TypedKey remoteIdentityPublicKey,
  required Conversation conversation,
}) async {
  final accountRecordKey =
      activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;
  final pool = await DHTRecordPool.instance();

  final crypto = await getConversationCrypto(
      activeAccountInfo: activeAccountInfo,
      remoteIdentityPublicKey: remoteIdentityPublicKey);

  return (await pool.openOwned(localConversationOwned,
          parent: accountRecordKey, crypto: crypto))
      .scope((localConversation) async {
    //
    final update = await localConversation.tryWriteProtobuf(
        Conversation.fromBuffer, conversation);
    if (update != null) {
      return update;
    }
    return null;
  });
}


/// Get most recent messages for this conversation
// @riverpod
// Future<IList<Message>?> fetchConversationMessages(FetchContactListRef ref) async {
//   // See if we've logged into this account or if it is locked
//   final activeAccountInfo = await ref.watch(fetchActiveAccountProvider.future);
//   if (activeAccountInfo == null) {
//     return null;
//   }
//   final accountRecordKey =
//       activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;

//   // Decode the contact list from the DHT
//   IList<Contact> out = const IListConst([]);
//   await (await DHTShortArray.openOwned(
//           proto.OwnedDHTRecordPointerProto.fromProto(
//               activeAccountInfo.account.contactList),
//           parent: accountRecordKey))
//       .scope((cList) async {
//     for (var i = 0; i < cList.length; i++) {
//       final cir = await cList.getItem(i);
//       if (cir == null) {
//         throw Exception('Failed to get contact');
//       }
//       out = out.add(Contact.fromBuffer(cir));
//     }
//   });

//   return out;
// }
