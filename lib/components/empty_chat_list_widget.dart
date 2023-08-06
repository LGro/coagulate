import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../tools/tools.dart';

class EmptyChatListWidget extends ConsumerWidget {
  const EmptyChatListWidget({super.key});

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
          Icons.chat,
          color: scale.primaryScale.border,
          size: 48,
        ),
        Text(
          translate('chat_list.start_a_conversation'),
          style: textTheme.bodyMedium?.copyWith(
            color: scale.primaryScale.border,
          ),
        ),
      ],
    ).expanded();
  }
}
