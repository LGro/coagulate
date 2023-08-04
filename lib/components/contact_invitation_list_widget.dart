import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:searchable_listview/searchable_listview.dart';

import '../../entities/proto.dart' as proto;
import '../tools/tools.dart';
import 'contact_invitation_item_widget.dart';
import 'contact_item_widget.dart';
import 'empty_contact_list_widget.dart';

class ContactInvitationListWidget extends ConsumerWidget {
  const ContactInvitationListWidget(
      {required this.contactInvitationRecordList, super.key});
  final IList<proto.ContactInvitationRecord> contactInvitationRecordList;

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    //final scale = theme.extension<ScaleScheme>()!;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Contacts',
            style: textTheme.bodyMedium,
          ),
          ListView.builder(itemBuilder: (context, index) {
            if (index < 0 || index >= contactInvitationRecordList.length) {
              return null;
            }
            return ContactInvitationItemWidget(
                contactInvitationRecord: contactInvitationRecordList[index],
                key: ObjectKey(contactInvitationRecordList[index]));
          }, findChildIndexCallback: (key) {
            final index = contactInvitationRecordList.indexOf(
                (key as ObjectKey).value! as proto.ContactInvitationRecord);
            if (index == -1) {
              return null;
            }
            return index;
          })
        ],
      ),
    );
  }
}
