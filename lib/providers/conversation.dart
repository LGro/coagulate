import 'dart:convert';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../entities/identity.dart';
import '../entities/proto.dart' as proto;
import '../entities/proto.dart' show Conversation, Contact;

import '../veilid_support/veilid_support.dart';
import 'account.dart';

//part 'conversation.g.dart';

Future<DHTRecordCrypto> getConversationCrypto({
  required ActiveAccountInfo activeAccountInfo,
  required Contact contact,
}) async {
  final veilid = await eventualVeilid.future;
  final identitySecret = activeAccountInfo.userLogin.identitySecret;
  final cs = await veilid.getCryptoSystem(identitySecret.kind);
  final remoteIdentityPublicKey =
      proto.TypedKeyProto.fromProto(contact.identityPublicKey);
  final sharedSecret =
      await cs.cachedDH(remoteIdentityPublicKey.value, identitySecret.value);
  return DHTRecordCryptoPrivate.fromSecret(identitySecret.kind, sharedSecret);
}

Future<Conversation?> readRemoteConversation({
  required ActiveAccountInfo activeAccountInfo,
  required TypedKey remoteConversationKey,
}) async {
  final accountRecordKey =
      activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;
  final pool = await DHTRecordPool.instance();

  return (await pool.openRead(remoteConversationKey, parent: accountRecordKey))
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
  required Conversation conversation,
}) async {
  final accountRecordKey =
      activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;
  final pool = await DHTRecordPool.instance();

  return (await pool.openOwned(localConversationOwned,
          parent: accountRecordKey))
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
//         throw StateError('Failed to get contact');
//       }
//       out = out.add(Contact.fromBuffer(cir));
//     }
//   });

//   return out;
// }
