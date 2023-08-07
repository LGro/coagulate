import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:searchable_listview/searchable_listview.dart';

import '../../entities/proto.dart' as proto;
import '../tools/tools.dart';
import 'chat_single_contact_item_widget.dart';
import 'contact_item_widget.dart';
import 'empty_chat_list_widget.dart';
import 'empty_contact_list_widget.dart';

class ChatSingleContactListWidget extends ConsumerWidget {
  ChatSingleContactListWidget(
      {required IList<proto.Contact> contactList,
      required this.chatList,
      super.key})
      : contactMap = IMap.fromIterable(contactList,
            keyMapper: (c) => c.remoteConversationKey, valueMapper: (c) => c);

  final IMap<proto.TypedKey, proto.Contact> contactMap;
  final IList<proto.Chat> chatList;

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final scale = theme.extension<ScaleScheme>()!;

    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
          color: scale.grayScale.appBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          )),
      child: (chatList.isEmpty)
          ? const EmptyChatListWidget()
          : SearchableList<proto.Chat>(
              initialList: chatList.toList(),
              builder: (c) {
                final contact = contactMap[c.remoteConversationKey];
                if (contact == null) {
                  return const Text('...');
                }
                return ChatSingleContactItemWidget(contact: contact);
              },
              filter: (value) {
                final lowerValue = value.toLowerCase();
                return chatList.where((c) {
                  final contact = contactMap[c.remoteConversationKey];
                  if (contact == null) {
                    return false;
                  }
                  return contact.editedProfile.name
                          .toLowerCase()
                          .contains(lowerValue) ||
                      contact.editedProfile.title
                          .toLowerCase()
                          .contains(lowerValue);
                }).toList();
              },
              inputDecoration: InputDecoration(
                labelText: translate('chat_list.search'),
                fillColor: Colors.white,
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.blue,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
    ).paddingLTRB(8, 8, 8, 65);
  }
}
