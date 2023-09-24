import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../../entities/proto.dart' as proto;
import '../pages/main_pager/main_pager.dart';
import '../providers/account.dart';
import '../providers/chat.dart';
import '../tools/theme_service.dart';

class ChatSingleContactItemWidget extends ConsumerWidget {
  const ChatSingleContactItemWidget({required this.contact, super.key});

  final proto.Contact contact;

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final scale = theme.extension<ScaleScheme>()!;

    final activeChat = ref.watch(activeChatStateProvider).asData?.value;
    final remoteConversationRecordKey =
        proto.TypedKeyProto.fromProto(contact.remoteConversationRecordKey);
    final selected = activeChat == remoteConversationRecordKey;

    return Container(
        margin: const EdgeInsets.fromLTRB(0, 4, 0, 0),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
            color: scale.tertiaryScale.subtleBorder,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            )),
        child: Slidable(
            key: ObjectKey(contact),
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              children: [
                SlidableAction(
                    onPressed: (context) async {
                      final activeAccountInfo =
                          await ref.read(fetchActiveAccountProvider.future);
                      if (activeAccountInfo != null) {
                        await deleteChat(
                            activeAccountInfo: activeAccountInfo,
                            remoteConversationRecordKey:
                                remoteConversationRecordKey);
                        ref.invalidate(fetchChatListProvider);
                      }
                    },
                    backgroundColor: scale.tertiaryScale.background,
                    foregroundColor: scale.tertiaryScale.text,
                    icon: Icons.delete,
                    label: translate('button.delete'),
                    padding: const EdgeInsets.all(2)),
                // SlidableAction(
                //   onPressed: (context) => (),
                //   backgroundColor: scale.secondaryScale.background,
                //   foregroundColor: scale.secondaryScale.text,
                //   icon: Icons.edit,
                //   label: 'Edit',
                // ),
              ],
            ),

            // The child of the Slidable is what the user sees when the
            // component is not dragged.
            child: ListTile(
                onTap: () async {
                  activeChatState.add(remoteConversationRecordKey);
                  ref.invalidate(fetchChatListProvider);
                },
                title: Text(contact.editedProfile.name),

                /// xxx show last message here
                subtitle: (contact.editedProfile.title.isNotEmpty)
                    ? Text(contact.editedProfile.title)
                    : null,
                iconColor: scale.tertiaryScale.background,
                textColor: scale.tertiaryScale.text,
                selected: selected,
                //Text(Timestamp.fromInt64(contactInvitationRecord.expiration) / ),
                leading: const Icon(Icons.chat))));
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<proto.Contact>('contact', contact));
  }
}
