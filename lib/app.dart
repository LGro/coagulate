import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'router/router.dart';

class VeilidChatApp extends ConsumerWidget {
  const VeilidChatApp({
    Key? key,
    required this.theme,
  }) : super(key: key);

  final ThemeData theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return ThemeProvider(
      initTheme: theme,
      builder: (_, theme) {
        return MaterialApp.router(
          routerConfig: router,
          title: 'VeilidChat',
          theme: theme,
        );
      },
    );
  }
}
