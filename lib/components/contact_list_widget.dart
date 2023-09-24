import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
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
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<proto.Contact>('contactList', contactList));
  }

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox.expand(
        child: styledTitleContainer(
            context: context,
            title: translate('contact_list.title'),
            child: SizedBox.expand(
              child: (contactList.isEmpty)
                  ? const EmptyContactListWidget()
                  : SearchableList<proto.Contact>(
                      autoFocusOnSearch: false,
                      shrinkWrap: true,
                      initialList: contactList.toList(),
                      builder: (l, i, c) => ContactItemWidget(contact: c),
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
            ))).paddingLTRB(8, 0, 8, 8);
  }
}
