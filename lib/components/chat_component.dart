import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../entities/proto.dart' as proto;
import '../providers/chat.dart';
import '../providers/contact.dart';
import '../tools/theme_service.dart';
import 'empty_chat_widget.dart';

class ChatComponent extends ConsumerStatefulWidget {
  const ChatComponent({super.key});

  @override
  ChatComponentState createState() => ChatComponentState();
}

class ChatComponentState extends ConsumerState<ChatComponent> {
  List<types.Message> _messages = [];
  final _unfocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _unfocusNode.dispose();
    super.dispose();
  }

  void _loadMessages() {
    final messages = <types.Message>[
      types.TextMessage(
          id: "abcd",
          text: "Hello!",
          author: types.User(
              id: "1234",
              firstName: "Foo",
              lastName: "Bar",
              role: types.Role.user))
    ];
    _messages = messages;
  }

  final _user = const types.User(
    id: '82091008-a484-4a89-ae75-a22bf8d6f3ac',
  );

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    _addMessage(textMessage);
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

    final contactList = ref.watch(fetchContactListProvider).asData?.value ??
        const IListConst([]);

    final activeChat = ref.watch(activeChatStateProvider).asData?.value;

    if (activeChat == null) {
      return const EmptyChatWidget();
    }

    final activeChatContactIdx = contactList.indexWhere(
      (c) =>
          proto.TypedKeyProto.fromProto(c.remoteConversationKey) == activeChat,
    );
    if (activeChatContactIdx == -1) {
      activeChatState.add(null);
      return const EmptyChatWidget();
    }
    final activeChatContact = contactList[activeChatContactIdx];

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
                        child: Text(activeChatContact.editedProfile.name,
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

                        onSendPressed: _handleSendPressed,
                        showUserAvatars: true,
                        showUserNames: true,
                        user: _user,
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
