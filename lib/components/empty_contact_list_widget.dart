import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../tools/tools.dart';

class EmptyContactListWidget extends ConsumerWidget {
  const EmptyContactListWidget({super.key});

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final scale = theme.extension<ScaleScheme>()!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.person_add_sharp,
          color: scale.primaryScale.subtleBorder,
          size: 48,
        ),
        Text(
          translate('contact_list.invite_people'),
          style: textTheme.bodyMedium?.copyWith(
            color: scale.primaryScale.subtleBorder,
          ),
        ),
      ],
    );
  }
}
