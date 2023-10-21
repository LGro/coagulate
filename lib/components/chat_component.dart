import 'dart:async';

import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../proto/proto.dart' as proto;
import '../providers/account.dart';
import '../providers/chat.dart';
import '../providers/conversation.dart';
import '../tools/tools.dart';
import '../veilid_init.dart';
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
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<ActiveAccountInfo>(
          'activeAccountInfo', activeAccountInfo))
      ..add(DiagnosticsProperty<TypedKey>('activeChat', activeChat))
      ..add(DiagnosticsProperty<proto.Contact>(
          'activeChatContact', activeChatContact));
  }
}

class ChatComponentState extends ConsumerState<ChatComponent> {
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
  }

  @override
  void dispose() {
    _unfocusNode.dispose();
    super.dispose();
  }

  types.Message protoMessageToMessage(proto.Message message) {
    final isLocal = message.author ==
        widget.activeAccountInfo.localAccount.identityMaster
            .identityPublicTypedKey()
            .toProto();

    final textMessage = types.TextMessage(
      author: isLocal ? _localUser : _remoteUser,
      createdAt: (message.timestamp ~/ 1000).toInt(),
      id: message.timestamp.toString(),
      text: message.text,
    );
    return textMessage;
  }

  Future<void> _addMessage(proto.Message protoMessage) async {
    if (protoMessage.text.isEmpty) {
      return;
    }

    final message = protoMessageToMessage(protoMessage);

    // setState(() {
    //   _messages.insert(0, message);
    // });

    // Now add the message to the conversation messages
    final localConversationRecordKey = proto.TypedKeyProto.fromProto(
        widget.activeChatContact.localConversationRecordKey);
    final remoteIdentityPublicKey = proto.TypedKeyProto.fromProto(
        widget.activeChatContact.identityPublicKey);

    await addLocalConversationMessage(
        activeAccountInfo: widget.activeAccountInfo,
        localConversationRecordKey: localConversationRecordKey,
        remoteIdentityPublicKey: remoteIdentityPublicKey,
        message: protoMessage);

    ref.invalidate(activeConversationMessagesProvider);
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
    final textTheme = Theme.of(context).textTheme;
    final chatTheme = makeChatTheme(scale, textTheme);
    final contactName = widget.activeChatContact.editedProfile.name;

    final protoMessages =
        ref.watch(activeConversationMessagesProvider).asData?.value;
    if (protoMessages == null) {
      return waitingPage(context);
    }
    final messages = <types.Message>[];
    for (final protoMessage in protoMessages) {
      final message = protoMessageToMessage(protoMessage);
      messages.insert(0, message);
    }

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
                      color: scale.primaryScale.subtleBorder,
                    ),
                    child: Row(children: [
                      Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16, 0, 16, 0),
                            child: Text(contactName,
                                textAlign: TextAlign.start,
                                style: textTheme.titleMedium),
                          )),
                      const Spacer(),
                      IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () async {
                            ref.read(activeChatStateProvider.notifier).state =
                                null;
                          }).paddingLTRB(16, 0, 16, 0)
                    ]),
                  ),
                  Expanded(
                    child: DecoratedBox(
                      decoration: const BoxDecoration(),
                      child: Chat(
                        theme: chatTheme,
                        messages: messages,
                        //onAttachmentPressed: _handleAttachmentPressed,
                        //onMessageTap: _handleMessageTap,
                        //onPreviewDataFetched: _handlePreviewDataFetched,

                        onSendPressed: (message) {
                          unawaited(_handleSendPressed(message));
                        },
                        //showUserAvatars: false,
                        //showUserNames: true,
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
