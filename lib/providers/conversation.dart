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

Future<Conversation?> readLocalConversation({
  required ActiveAccountInfo activeAccountInfo,
  required OwnedDHTRecordPointer localConversationOwned,
  required TypedKey remoteIdentityPublicKey,
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
    final update = await localConversation.getProtobuf(Conversation.fromBuffer);
    if (update != null) {
      return update;
    }
    return null;
  });
}

Future<void> addLocalConversationMessage(
    {required ActiveAccountInfo activeAccountInfo,
    required OwnedDHTRecordPointer localConversationOwned,
    required TypedKey remoteIdentityPublicKey,
    required proto.Message message}) async {
  final conversation = await readLocalConversation(
      activeAccountInfo: activeAccountInfo,
      localConversationOwned: localConversationOwned,
      remoteIdentityPublicKey: remoteIdentityPublicKey);
  if (conversation == null) {
    return;
  }
  final messagesOwned =
      proto.OwnedDHTRecordPointerProto.fromProto(conversation.messages);
  final crypto = await getConversationCrypto(
      activeAccountInfo: activeAccountInfo,
      remoteIdentityPublicKey: remoteIdentityPublicKey);

  await (await DHTShortArray.openOwned(messagesOwned,
          parent: localConversationOwned.recordKey, crypto: crypto))
      .scope((messages) async {
    await messages.tryAddItem(message.writeToBuffer());
  });
}

Future<IList<proto.Message>?> getLocalConversationMessages({
  required ActiveAccountInfo activeAccountInfo,
  required OwnedDHTRecordPointer localConversationOwned,
  required TypedKey remoteIdentityPublicKey,
}) async {
  final conversation = await readLocalConversation(
      activeAccountInfo: activeAccountInfo,
      localConversationOwned: localConversationOwned,
      remoteIdentityPublicKey: remoteIdentityPublicKey);
  if (conversation == null) {
    return null;
  }
  final messagesOwned =
      proto.OwnedDHTRecordPointerProto.fromProto(conversation.messages);
  final crypto = await getConversationCrypto(
      activeAccountInfo: activeAccountInfo,
      remoteIdentityPublicKey: remoteIdentityPublicKey);

  return (await DHTShortArray.openOwned(messagesOwned,
          parent: localConversationOwned.recordKey, crypto: crypto))
      .scope((messages) async {
    var out = IList<proto.Message>();
    for (var i = 0; i < messages.length; i++) {
      final msg = await messages.getItemProtobuf(proto.Message.fromBuffer, i);
      if (msg == null) {
        throw Exception('Failed to get message');
      }
      out = out.add(msg);
    }
    return out;
  });
}

Future<IList<proto.Message>?> getRemoteConversationMessages({
  required ActiveAccountInfo activeAccountInfo,
  required TypedKey remoteConversationKey,
  required TypedKey remoteIdentityPublicKey,
}) async {
  final conversation = await readRemoteConversation(
      activeAccountInfo: activeAccountInfo,
      remoteConversationKey: remoteConversationKey,
      remoteIdentityPublicKey: remoteIdentityPublicKey);
  if (conversation == null) {
    return null;
  }
  final messagesOwned =
      proto.OwnedDHTRecordPointerProto.fromProto(conversation.messages);
  final crypto = await getConversationCrypto(
      activeAccountInfo: activeAccountInfo,
      remoteIdentityPublicKey: remoteIdentityPublicKey);

  return (await DHTShortArray.openOwned(messagesOwned,
          parent: localConversationOwned.recordKey, crypto: crypto))
      .scope((messages) async {
    var out = IList<proto.Message>();
    for (var i = 0; i < messages.length; i++) {
      final msg = await messages.getItemProtobuf(proto.Message.fromBuffer, i);
      if (msg == null) {
        throw Exception('Failed to get message');
      }
      out = out.add(msg);
    }
    return out;
  });
}
