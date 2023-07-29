import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../entities/proto.dart' as proto;
import 'empty_contact_list_widget.dart';

class ContactListWidget extends ConsumerWidget {
  const ContactListWidget({required this.contactList, super.key});
  final List<proto.Contact> contactList;

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context, WidgetRef ref) {
    //
    if (contactList.isEmpty) {
      return const EmptyContactListWidget();
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_add,
            color: Theme.of(context).disabledColor,
            size: 48,
          ),
          Text(
            'Contacts',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).disabledColor,
                ),
          ),
        ],
      ),
    );
  }
}
