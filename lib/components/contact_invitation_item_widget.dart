import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:veilid/veilid.dart';
import '../../entities/proto.dart' as proto;

class ContactInvitationItemWidget extends ConsumerWidget {
  const ContactInvitationItemWidget(
      {required this.contactInvitationRecord, super.key});

  final proto.ContactInvitationRecord contactInvitationRecord;

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context, WidgetRef ref) {
    return Slidable(
        // Specify a key if the Slidable is dismissible.
        key: ObjectKey(contactInvitationRecord),
        // The start action pane is the one at the left or the top side.
        startActionPane: ActionPane(
          // A motion is a widget used to control how the pane animates.
          motion: const DrawerMotion(),

          // A pane can dismiss the Slidable.
          //dismissible: DismissiblePane(onDismissed: () {}),

          // All actions are defined in the children parameter.
          children: [
            // A SlidableAction can have an icon and/or a label.
            SlidableAction(
              onPressed: (context) => (),
              backgroundColor: Color(0xFFFE4A49),
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
            ),
            SlidableAction(
              onPressed: (context) => (),
              backgroundColor: Color(0xFF21B7CA),
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit',
            ),
          ],
        ),

        // The end action pane is the one at the right or the bottom side.
        // endActionPane: ActionPane(
        //   motion: const DrawerMotion(),
        //   children: [
        //     SlidableAction(
        //       // An action can be bigger than the others.
        //       flex: 2,
        //       onPressed: (context) => (),
        //       backgroundColor: Color(0xFF7BC043),
        //       foregroundColor: Colors.white,
        //       icon: Icons.archive,
        //       label: 'Archive',
        //     ),
        //     SlidableAction(
        //       onPressed: (context) => (),
        //       backgroundColor: Color(0xFF0392CF),
        //       foregroundColor: Colors.white,
        //       icon: Icons.save,
        //       label: 'Save',
        //     ),
        //   ],
        // ),

        // The child of the Slidable is what the user sees when the
        // component is not dragged.
        child: ListTile(
            title: Text(translate('contact_list.invitation')),
            subtitle: Text(contactInvitationRecord.message),
            //Text(Timestamp.fromInt64(contactInvitationRecord.expiration) / ),
            leading: Icon(Icons.person_add)));
  }
}
