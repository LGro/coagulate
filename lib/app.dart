import 'package:flutter/material.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';s

class VeilidChatApp extends StatelessWidget {
  const VeilidChatApp({
    Key? key,
    required this.theme,
  }) : super(key: key);

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      initTheme: theme,
      builder: (_, theme) {
        return MaterialApp(
          title: 'VeilidChat',
          theme: theme,
          home: const MyHomePage(title: 'Flutter Demo Home Page'),
        );
      },
    );
  }
}
