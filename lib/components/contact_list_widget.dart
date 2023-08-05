import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final scale = theme.extension<ScaleScheme>()!;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 64,
      ),
      child: Column(children: [
        Text(
          'Contacts',
          style: textTheme.bodyLarge,
        ).paddingAll(8),
        Container(
          width: double.infinity,
          decoration: ShapeDecoration(
              color: scale.grayScale.appBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              )),
          child: (contactList.isEmpty)
              ? const EmptyContactListWidget().toCenter()
              : SearchableList<proto.Contact>(
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
        ).expanded()
      ]),
    ).paddingLTRB(8, 0, 8, 65);
  }
}
