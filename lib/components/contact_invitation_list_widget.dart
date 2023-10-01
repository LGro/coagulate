import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../proto/proto.dart' as proto;
import '../tools/tools.dart';
import 'contact_invitation_item_widget.dart';

class ContactInvitationListWidget extends ConsumerStatefulWidget {
  const ContactInvitationListWidget({
    required this.contactInvitationRecordList,
    super.key,
  });

  final IList<proto.ContactInvitationRecord> contactInvitationRecordList;

  @override
  ContactInvitationListWidgetState createState() =>
      ContactInvitationListWidgetState();
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<proto.ContactInvitationRecord>('contactInvitationRecordList', contactInvitationRecordList));
  }
}

class ContactInvitationListWidgetState
    extends ConsumerState<ContactInvitationListWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    //final textTheme = theme.textTheme;
    final scale = theme.extension<ScaleScheme>()!;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(4, 0, 4, 4),
      decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      )),
      constraints: const BoxConstraints(maxHeight: 200),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: double.infinity,
              decoration: ShapeDecoration(
                  color: scale.primaryScale.subtleBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  )),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: widget.contactInvitationRecordList.length,
                itemBuilder: (context, index) {
                  if (index < 0 ||
                      index >= widget.contactInvitationRecordList.length) {
                    return null;
                  }
                  return ContactInvitationItemWidget(
                          contactInvitationRecord:
                              widget.contactInvitationRecordList[index],
                          key: ObjectKey(
                              widget.contactInvitationRecordList[index]))
                      .paddingAll(2);
                },
                findChildIndexCallback: (key) {
                  final index = widget.contactInvitationRecordList.indexOf(
                      (key as ObjectKey).value!
                          as proto.ContactInvitationRecord);
                  if (index == -1) {
                    return null;
                  }
                  return index;
                },
                shrinkWrap: true,
              ).paddingLTRB(0, 0, 0, 4))
        ],
      ),
    );
  }
}
