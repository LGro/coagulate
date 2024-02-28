import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:searchable_listview/searchable_listview.dart';

import '../proto/proto.dart' as proto;
import '../tools/tools.dart';
import 'chat_single_contact_item_widget.dart';
import 'empty_chat_list_widget.dart';

class ChatSingleContactListWidget extends ConsumerWidget {
  ChatSingleContactListWidget(
      {required IList<proto.Contact> contactList,
      required this.chatList,
      super.key})
      : contactMap = IMap.fromIterable(contactList,
            keyMapper: (c) => c.remoteConversationRecordKey,
            valueMapper: (c) => c);

  final IMap<proto.TypedKey, proto.Contact> contactMap;
  final IList<proto.Chat> chatList;

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    //final textTheme = theme.textTheme;
    final scale = theme.extension<ScaleScheme>()!;

    return const Text('UNAVAILABLE');
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<IMap<proto.TypedKey, proto.Contact>>(
          'contactMap', contactMap))
      ..add(IterableProperty<proto.Chat>('chatList', chatList));
  }
}
