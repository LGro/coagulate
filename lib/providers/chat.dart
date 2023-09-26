import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../proto/proto.dart' as proto;
import '../proto/proto.dart' show Chat, ChatType;

import '../tools/tools.dart';
import '../veilid_support/veilid_support.dart';
import 'account.dart';

part 'chat.g.dart';

/// Create a new chat (singleton for single contact chats)
Future<void> getOrCreateChatSingleContact({
  required ActiveAccountInfo activeAccountInfo,
  required TypedKey remoteConversationRecordKey,
}) async {
  final accountRecordKey =
      activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;

  // Create conversation type Chat
  final chat = Chat()
    ..type = ChatType.SINGLE_CONTACT
    ..remoteConversationKey = remoteConversationRecordKey.toProto();

  // Add Chat to account's list
  // if this fails, don't keep retrying, user can try again later
  await (await DHTShortArray.openOwned(
          proto.OwnedDHTRecordPointerProto.fromProto(
              activeAccountInfo.account.chatList),
          parent: accountRecordKey))
      .scope((chatList) async {
    for (var i = 0; i < chatList.length; i++) {
      final cbuf = await chatList.getItem(i);
      if (cbuf == null) {
        throw Exception('Failed to get chat');
      }
      final c = Chat.fromBuffer(cbuf);
      if (c == chat) {
        return;
      }
    }
    if (await chatList.tryAddItem(chat.writeToBuffer()) == false) {
      throw Exception('Failed to add chat');
    }
  });
}

/// Delete a chat
Future<void> deleteChat(
    {required ActiveAccountInfo activeAccountInfo,
    required TypedKey remoteConversationRecordKey}) async {
  final accountRecordKey =
      activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;

  // Create conversation type Chat
  final remoteConversationKey = remoteConversationRecordKey.toProto();

  // Add Chat to account's list
  // if this fails, don't keep retrying, user can try again later
  await (await DHTShortArray.openOwned(
          proto.OwnedDHTRecordPointerProto.fromProto(
              activeAccountInfo.account.chatList),
          parent: accountRecordKey))
      .scope((chatList) async {
    for (var i = 0; i < chatList.length; i++) {
      final cbuf = await chatList.getItem(i);
      if (cbuf == null) {
        throw Exception('Failed to get chat');
      }
      final c = Chat.fromBuffer(cbuf);
      if (c.remoteConversationKey == remoteConversationKey) {
        await chatList.tryRemoveItem(i);

        if (activeChatState.currentState == remoteConversationRecordKey) {
          activeChatState.add(null);
        }

        return;
      }
    }
  });
}

/// Get the active account contact list
@riverpod
Future<IList<Chat>?> fetchChatList(FetchChatListRef ref) async {
  // See if we've logged into this account or if it is locked
  final activeAccountInfo = await ref.watch(fetchActiveAccountProvider.future);
  if (activeAccountInfo == null) {
    return null;
  }
  final accountRecordKey =
      activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;

  // Decode the chat list from the DHT
  IList<Chat> out = const IListConst([]);
  await (await DHTShortArray.openOwned(
          proto.OwnedDHTRecordPointerProto.fromProto(
              activeAccountInfo.account.chatList),
          parent: accountRecordKey))
      .scope((cList) async {
    for (var i = 0; i < cList.length; i++) {
      final cir = await cList.getItem(i);
      if (cir == null) {
        throw Exception('Failed to get chat');
      }
      out = out.add(Chat.fromBuffer(cir));
    }
  });

  return out;
}

// The selected chat
ExternalStreamState<TypedKey?> activeChatState =
    ExternalStreamState<TypedKey?>(null);
AutoDisposeStreamProvider<TypedKey?> activeChatStateProvider =
    activeChatState.provider();
