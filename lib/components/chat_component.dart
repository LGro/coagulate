import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../entities/proto.dart' as proto;
import '../entities/identity.dart';
import '../providers/account.dart';
import '../providers/conversation.dart';
import '../tools/theme_service.dart';
import '../veilid_support/veilid_support.dart';

class ChatComponent extends ConsumerStatefulWidget {
  const ChatComponent(
      {required this.activeAccountInfo,
      required this.activeChat,
      required this.activeChatContact,
      super.key});

  final ActiveAccountInfo activeAccountInfo;
  final TypedKey activeChat;
  final proto.Contact activeChatContact;

  @override
  ChatComponentState createState() => ChatComponentState();
}

class ChatComponentState extends ConsumerState<ChatComponent> {
  List<types.Message> _messages = [];
  final _unfocusNode = FocusNode();
  late final types.User _localUser;
  late final types.User _remoteUser;

  @override
  void initState() {
    super.initState();

    _localUser = types.User(
      id: widget.activeAccountInfo.localAccount.identityMaster
          .identityPublicTypedKey()
          .toString(),
      firstName: widget.activeAccountInfo.account.profile.name,
    );
    _remoteUser = types.User(
        id: proto.TypedKeyProto.fromProto(
                widget.activeChatContact.identityPublicKey)
            .toString(),
        firstName: widget.activeChatContact.remoteProfile.name);

    unawaited(_loadMessages());
  }

  @override
  void dispose() {
    _unfocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    final localConversationOwned = proto.OwnedDHTRecordPointerProto.fromProto(
        widget.activeChatContact.localConversation);
    final remoteIdentityPublicKey = proto.TypedKeyProto.fromProto(
        widget.activeChatContact.identityPublicKey);
    final protoMessages = await getLocalConversationMessages(
        activeAccountInfo: widget.activeAccountInfo,
        localConversationOwned: localConversationOwned,
        remoteIdentityPublicKey: remoteIdentityPublicKey);
    if (protoMessages == null) {
      return;
    }
    setState(() {
      _messages = [];
      for (final protoMessage in protoMessages) {
        final message = protoMessageToMessage(protoMessage);
        _messages.insert(0, message);
      }
    });
  }

  types.Message protoMessageToMessage(proto.Message message) {
    final isLocal = message.author ==
        widget.activeAccountInfo.localAccount.identityMaster
            .identityPublicTypedKey()
            .toProto();

    final textMessage = types.TextMessage(
      author: isLocal ? _localUser : _remoteUser,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );
    return textMessage;
  }

  Future<void> _addMessage(proto.Message protoMessage) async {
    if (protoMessage.text.isEmpty) {
      return;
    }

    final message = protoMessageToMessage(protoMessage);

    setState(() {
      _messages.insert(0, message);
    });

    // Now add the message to the conversation messages
    final localConversationOwned = proto.OwnedDHTRecordPointerProto.fromProto(
        widget.activeChatContact.localConversation);
    final remoteIdentityPublicKey = proto.TypedKeyProto.fromProto(
        widget.activeChatContact.identityPublicKey);

    await addLocalConversationMessage(
        activeAccountInfo: widget.activeAccountInfo,
        localConversationOwned: localConversationOwned,
        remoteIdentityPublicKey: remoteIdentityPublicKey,
        message: protoMessage);
  }

  Future<void> _handleSendPressed(types.PartialText message) async {
    final protoMessage = proto.Message()
      ..author = widget.activeAccountInfo.localAccount.identityMaster
          .identityPublicTypedKey()
          .toProto()
      ..timestamp = (await eventualVeilid.future).now().toInt64()
      ..text = message.text;
    //..signature = signature;

    await _addMessage(protoMessage);
  }

  void _handleAttachmentPressed() {
    //
  }

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;
    final chatTheme = scale.toChatTheme();
    final textTheme = Theme.of(context).textTheme;
    final contactName = widget.activeChatContact.editedProfile.name;

    return DefaultTextStyle(
        style: textTheme.bodySmall!,
        child: Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: scale.primaryScale.subtleBackground,
                    ),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                        child: Text(contactName,
                            textAlign: TextAlign.start,
                            style: textTheme.titleMedium),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(),
                      child: Chat(
                        theme: chatTheme,
                        messages: _messages,
                        //onAttachmentPressed: _handleAttachmentPressed,
                        //onMessageTap: _handleMessageTap,
                        //onPreviewDataFetched: _handlePreviewDataFetched,

                        onSendPressed: (message) {
                          unawaited(_handleSendPressed(message));
                        },
                        showUserAvatars: true,
                        showUserNames: true,
                        user: _localUser,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
