import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
//    final logins = ref.watch(loginsProvider);

    return ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 300),
        child: Column(children: [
          Text('Profile', style: Theme.of(context).textTheme.headlineMedium),
          Text(name, style: Theme.of(context).textTheme.bodyMedium),
          if (title != null && title!.isNotEmpty)
            Text(title!, style: Theme.of(context).textTheme.bodySmall),
        ]));
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('name', name))
      ..add(StringProperty('title', title));
  }
}
