import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../tools/tools.dart';

class ProfileWidget extends ConsumerWidget {
  const ProfileWidget({
    required this.name,
    this.title,
    super.key,
  });

  final String name;
  final String? title;

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;
    final textTheme = theme.textTheme;

    return Container(
        width: double.infinity,
        decoration: ShapeDecoration(
            color: scale.primaryScale.subtleBackground,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: scale.primaryScale.border))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(name, style: textTheme.headlineSmall).paddingAll(8),
          if (title != null && title!.isNotEmpty)
            Text(title!, style: textTheme.bodyMedium).paddingLTRB(8, 0, 8, 8),
        ])).paddingAll(8);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('name', name))
      ..add(StringProperty('title', title));
  }
}
