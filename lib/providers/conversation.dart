import 'dart:convert';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../proto/proto.dart' as proto;
import '../proto/proto.dart' show Conversation, Message;

import '../log/loggy.dart';
import '../veilid_init.dart';
import '../veilid_support/veilid_support.dart';
import 'account.dart';
import 'chat.dart';
import 'contact.dart';

part 'conversation.g.dart';

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
    required Message message}) async {
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

Future<bool> mergeLocalConversationMessages(
    {required ActiveAccountInfo activeAccountInfo,
    required TypedKey localConversationRecordKey,
    required TypedKey remoteIdentityPublicKey,
    required IList<Message> newMessages}) async {
  final conversation = await readLocalConversation(
      activeAccountInfo: activeAccountInfo,
      localConversationRecordKey: localConversationRecordKey,
      remoteIdentityPublicKey: remoteIdentityPublicKey);
  if (conversation == null) {
    return false;
  }
  var changed = false;
  final messagesRecordKey =
      proto.TypedKeyProto.fromProto(conversation.messages);
  final crypto = await getConversationCrypto(
      activeAccountInfo: activeAccountInfo,
      remoteIdentityPublicKey: remoteIdentityPublicKey);
  final writer = getConversationWriter(activeAccountInfo: activeAccountInfo);

  newMessages = newMessages.sort((a, b) => Timestamp.fromInt64(a.timestamp)
      .compareTo(Timestamp.fromInt64(b.timestamp)));

  await (await DHTShortArray.openWrite(messagesRecordKey, writer,
          parent: localConversationRecordKey, crypto: crypto))
      .scope((messages) async {
    // Ensure newMessages is sorted by timestamp
    newMessages =
        newMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Existing messages will always be sorted by timestamp so merging is easy
    var pos = 0;
    outer:
    for (final newMessage in newMessages) {
      var skip = false;
      while (pos < messages.length) {
        final m = await messages.getItemProtobuf(proto.Message.fromBuffer, pos);
        if (m == null) {
          log.error('unable to get message #$pos');
          break outer;
        }

        // If timestamp to insert is less than
        // the current position, insert it here
        final newTs = Timestamp.fromInt64(newMessage.timestamp);
        final curTs = Timestamp.fromInt64(m.timestamp);
        final cmp = newTs.compareTo(curTs);
        if (cmp < 0) {
          break;
        } else if (cmp == 0) {
          skip = true;
          break;
        }
        pos++;
      }
      // Insert at this position
      if (!skip) {
        await messages.tryInsertItem(pos, newMessage.writeToBuffer());
        changed = true;
      }
    }
  });
  return changed;
}

Future<IList<Message>?> getLocalConversationMessages({
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
    var out = IList<Message>();
    for (var i = 0; i < messages.length; i++) {
      final msg = await messages.getItemProtobuf(Message.fromBuffer, i);
      if (msg == null) {
        throw Exception('Failed to get message');
      }
      out = out.add(msg);
    }
    return out;
  });
}

Future<IList<Message>?> getRemoteConversationMessages({
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
    var out = IList<Message>();
    for (var i = 0; i < messages.length; i++) {
      final msg = await messages.getItemProtobuf(Message.fromBuffer, i);
      if (msg == null) {
        throw Exception('Failed to get message');
      }
      out = out.add(msg);
    }
    return out;
  });
}

@riverpod
class ActiveConversationMessages extends _$ActiveConversationMessages {
  /// Get message for active converation
  @override
  FutureOr<IList<Message>?> build() async {
    await eventualVeilid.future;

    final activeChat = activeChatState.currentState;
    if (activeChat == null) {
      return null;
    }

    final activeAccountInfo =
        await ref.watch(fetchActiveAccountProvider.future);
    if (activeAccountInfo == null) {
      return null;
    }

    final contactList = ref.watch(fetchContactListProvider).asData?.value ??
        const IListConst([]);

    final activeChatContactIdx = contactList.indexWhere(
      (c) =>
          proto.TypedKeyProto.fromProto(c.remoteConversationRecordKey) ==
          activeChat,
    );
    if (activeChatContactIdx == -1) {
      return null;
    }
    final activeChatContact = contactList[activeChatContactIdx];
    final remoteIdentityPublicKey =
        proto.TypedKeyProto.fromProto(activeChatContact.identityPublicKey);
    // final remoteConversationRecordKey = proto.TypedKeyProto.fromProto(
    //     activeChatContact.remoteConversationRecordKey);
    final localConversationRecordKey = proto.TypedKeyProto.fromProto(
        activeChatContact.localConversationRecordKey);

    return await getLocalConversationMessages(
      activeAccountInfo: activeAccountInfo,
      localConversationRecordKey: localConversationRecordKey,
      remoteIdentityPublicKey: remoteIdentityPublicKey,
    );
  }
}
