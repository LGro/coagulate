import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:searchable_listview/searchable_listview.dart';

import '../proto/proto.dart' as proto;
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    //final textTheme = theme.textTheme;
    final scale = theme.extension<ScaleScheme>()!;

    return const Text('UNAVAILABLE');
  }
}
