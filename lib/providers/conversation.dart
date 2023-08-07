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

KeyPair getConversationWriter({
  required ActiveAccountInfo activeAccountInfo,
}) {
  final identityKey =
      activeAccountInfo.localAccount.identityMaster.identityPublicKey;
  final identitySecret = activeAccountInfo.userLogin.identitySecret;
  return KeyPair(key: identityKey, secret: identitySecret.value);
}

// Create a conversation
// If we were the initator of the conversation there may be an
// incomplete 'existingConversationRecord' that we need to fill
// in now that we have the remote identity key
Future<T> createConversation<T>(
    {required ActiveAccountInfo activeAccountInfo,
    required TypedKey remoteIdentityPublicKey,
    required FutureOr<T> Function(DHTRecord) callback,
    TypedKey? existingConversationRecordKey}) async {
  final pool = await DHTRecordPool.instance();
  final accountRecordKey =
      activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;

  final crypto = await getConversationCrypto(
      activeAccountInfo: activeAccountInfo,
      remoteIdentityPublicKey: remoteIdentityPublicKey);
  final writer = getConversationWriter(activeAccountInfo: activeAccountInfo);

  // Open with SMPL scheme for identity writer
  late final DHTRecord localConversationRecord;
  if (existingConversationRecordKey != null) {
    localConversationRecord = await pool.openWrite(
        existingConversationRecordKey, writer,
        parent: accountRecordKey, crypto: crypto);
  } else {
    final localConversationRecordCreate = await pool.create(
        parent: accountRecordKey,
        crypto: crypto,
        schema: DHTSchema.smpl(
            oCnt: 0, members: [DHTSchemaMember(mKey: writer.key, mCnt: 1)]));
    await localConversationRecordCreate.close();
    localConversationRecord = await pool.openWrite(
        localConversationRecordCreate.key, writer,
        parent: accountRecordKey, crypto: crypto);
  }
  return localConversationRecord
      // ignore: prefer_expression_function_bodies
      .deleteScope((localConversation) async {
    // Make messages log
    return (await DHTShortArray.create(
            parent: localConversation.key, crypto: crypto, smplWriter: writer))
        .deleteScope((messages) async {
      // Write local conversation key
      final conversation = Conversation()
        ..profile = activeAccountInfo.account.profile
        ..identityMasterJson =
            jsonEncode(activeAccountInfo.localAccount.identityMaster.toJson())
        ..messages = messages.record.key.toProto();

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
  required TypedKey remoteConversationRecordKey,
  required TypedKey remoteIdentityPublicKey,
}) async {
  final accountRecordKey =
      activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;
  final pool = await DHTRecordPool.instance();

  final crypto = await getConversationCrypto(
      activeAccountInfo: activeAccountInfo,
      remoteIdentityPublicKey: remoteIdentityPublicKey);
  return (await pool.openRead(remoteConversationRecordKey,
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
  required TypedKey localConversationRecordKey,
  required TypedKey remoteIdentityPublicKey,
  required Conversation conversation,
}) async {
  final accountRecordKey =
      activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;
  final pool = await DHTRecordPool.instance();

  final crypto = await getConversationCrypto(
      activeAccountInfo: activeAccountInfo,
      remoteIdentityPublicKey: remoteIdentityPublicKey);
  final writer = getConversationWriter(activeAccountInfo: activeAccountInfo);

  return (await pool.openWrite(localConversationRecordKey, writer,
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
  required TypedKey localConversationRecordKey,
  required TypedKey remoteIdentityPublicKey,
}) async {
  final accountRecordKey =
      activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;
  final pool = await DHTRecordPool.instance();

  final crypto = await getConversationCrypto(
      activeAccountInfo: activeAccountInfo,
      remoteIdentityPublicKey: remoteIdentityPublicKey);

  return (await pool.openRead(localConversationRecordKey,
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
    required TypedKey localConversationRecordKey,
    required TypedKey remoteIdentityPublicKey,
    required proto.Message message}) async {
  final conversation = await readLocalConversation(
      activeAccountInfo: activeAccountInfo,
      localConversationRecordKey: localConversationRecordKey,
      remoteIdentityPublicKey: remoteIdentityPublicKey);
  if (conversation == null) {
    return;
  }
  final messagesRecordKey =
      proto.TypedKeyProto.fromProto(conversation.messages);
  final crypto = await getConversationCrypto(
      activeAccountInfo: activeAccountInfo,
      remoteIdentityPublicKey: remoteIdentityPublicKey);
  final writer = getConversationWriter(activeAccountInfo: activeAccountInfo);

  await (await DHTShortArray.openWrite(messagesRecordKey, writer,
          parent: localConversationRecordKey, crypto: crypto))
      .scope((messages) async {
    await messages.tryAddItem(message.writeToBuffer());
  });
}

Future<IList<proto.Message>?> getLocalConversationMessages({
  required ActiveAccountInfo activeAccountInfo,
  required TypedKey localConversationRecordKey,
  required TypedKey remoteIdentityPublicKey,
}) async {
  final conversation = await readLocalConversation(
      activeAccountInfo: activeAccountInfo,
      localConversationRecordKey: localConversationRecordKey,
      remoteIdentityPublicKey: remoteIdentityPublicKey);
  if (conversation == null) {
    return null;
  }
  final messagesRecordKey =
      proto.TypedKeyProto.fromProto(conversation.messages);
  final crypto = await getConversationCrypto(
      activeAccountInfo: activeAccountInfo,
      remoteIdentityPublicKey: remoteIdentityPublicKey);

  return (await DHTShortArray.openRead(messagesRecordKey,
          parent: localConversationRecordKey, crypto: crypto))
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
  required TypedKey remoteConversationRecordKey,
  required TypedKey remoteIdentityPublicKey,
}) async {
  final conversation = await readRemoteConversation(
      activeAccountInfo: activeAccountInfo,
      remoteConversationRecordKey: remoteConversationRecordKey,
      remoteIdentityPublicKey: remoteIdentityPublicKey);
  if (conversation == null) {
    return null;
  }
  final messagesRecordKey =
      proto.TypedKeyProto.fromProto(conversation.messages);
  final crypto = await getConversationCrypto(
      activeAccountInfo: activeAccountInfo,
      remoteIdentityPublicKey: remoteIdentityPublicKey);

  return (await DHTShortArray.openRead(messagesRecordKey,
          parent: remoteConversationRecordKey, crypto: crypto))
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
