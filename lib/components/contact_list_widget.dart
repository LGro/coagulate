import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:searchable_listview/searchable_listview.dart';

import '../../entities/proto.dart' as proto;
import '../tools/tools.dart';
import 'contact_item_widget.dart';
import 'empty_contact_list_widget.dart';

class ContactListWidget extends ConsumerWidget {
  const ContactListWidget({required this.contactList, super.key});
  final IList<proto.Contact> contactList;

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
          SearchableList<proto.Contact>(
            initialList: contactList.toList(),
            builder: (contact) => ContactItemWidget(contact: contact),
            filter: (value) {
              final lowerValue = value.toLowerCase();
              return contactList
                  .where((element) =>
                      element.editedProfile.name
                          .toLowerCase()
                          .contains(lowerValue) ||
                      element.editedProfile.title
                          .toLowerCase()
                          .contains(lowerValue))
                  .toList();
            },
            emptyWidget: const EmptyContactListWidget(),
            inputDecoration: InputDecoration(
              labelText: translate('contact_list.search'),
              fillColor: Colors.white,
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.blue,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
