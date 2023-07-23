import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'router/router.dart';
import 'package:flutter_translate/flutter_translate.dart';

class VeilidChatApp extends ConsumerWidget {
  const VeilidChatApp({
    Key? key,
    required this.theme,
  }) : super(key: key);

  final ThemeData theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    var localizationDelegate = LocalizedApp.of(context).delegate;

    return ThemeProvider(
      initTheme: theme,
      builder: (_, theme) {
        return LocalizationProvider(
            state: LocalizationProvider.of(context).state,
            child: MaterialApp.router(
              debugShowCheckedModeBanner: false,
              routerConfig: router,
              title: 'VeilidChat',
              theme: theme,
              localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                localizationDelegate
              ],
              supportedLocales: localizationDelegate.supportedLocales,
              locale: localizationDelegate.currentLocale,
            ));
      },
    );
  }
}
