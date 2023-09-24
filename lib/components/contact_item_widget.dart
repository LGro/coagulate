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
import '../providers/contact.dart';
import '../tools/theme_service.dart';

class ContactItemWidget extends ConsumerWidget {
  const ContactItemWidget({required this.contact, super.key});

  final proto.Contact contact;

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final scale = theme.extension<ScaleScheme>()!;

    final remoteConversationKey =
        proto.TypedKeyProto.fromProto(contact.remoteConversationRecordKey);

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
                        await deleteContact(
                            activeAccountInfo: activeAccountInfo,
                            contact: contact);
                        ref
                          ..invalidate(fetchContactListProvider)
                          ..invalidate(fetchChatListProvider);
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
                  final activeAccountInfo =
                      await ref.read(fetchActiveAccountProvider.future);
                  if (activeAccountInfo != null) {
                    // Start a chat
                    await getOrCreateChatSingleContact(
                        activeAccountInfo: activeAccountInfo,
                        remoteConversationRecordKey: remoteConversationKey);

                    // Click over to chats
                    if (context.mounted) {
                      await MainPager.of(context)?.pageController.animateToPage(
                          1,
                          duration: 250.ms,
                          curve: Curves.easeInOut);
                    }
                  }

                  //   // ignore: use_build_context_synchronously
                  //   if (!context.mounted) {
                  //     return;
                  //   }
                  //   await showDialog<void>(
                  //       context: context,
                  //       builder: (context) => ContactInvitationDisplayDialog(
                  //             name: activeAccountInfo.localAccount.name,
                  //             message: contactInvitationRecord.message,
                  //             generator: Uint8List.fromList(
                  //                 contactInvitationRecord.invitation),
                  //           ));
                  // }
                },
                title: Text(contact.editedProfile.name),
                subtitle: (contact.editedProfile.title.isNotEmpty)
                    ? Text(contact.editedProfile.title)
                    : null,
                iconColor: scale.tertiaryScale.background,
                textColor: scale.tertiaryScale.text,
                //Text(Timestamp.fromInt64(contactInvitationRecord.expiration) / ),
                leading: const Icon(Icons.person))));
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<proto.Contact>('contact', contact));
  }
}
