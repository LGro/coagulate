import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import 'router/router.dart';
import 'tick.dart';

class VeilidChatApp extends ConsumerWidget {
  const VeilidChatApp({
    required this.theme,
    super.key,
  });

  final ThemeData theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    final localizationDelegate = LocalizedApp.of(context).delegate;

    return ThemeProvider(
        initTheme: theme,
        builder: (_, theme) => LocalizationProvider(
              state: LocalizationProvider.of(context).state,
              child: BackgroundTicker(
                  builder: (context) => MaterialApp.router(
                        debugShowCheckedModeBanner: false,
                        routerConfig: router,
                        title: translate('app.title'),
                        theme: theme,
                        localizationsDelegates: [
                          GlobalMaterialLocalizations.delegate,
                          GlobalWidgetsLocalizations.delegate,
                          FormBuilderLocalizations.delegate,
                          localizationDelegate
                        ],
                        supportedLocales: localizationDelegate.supportedLocales,
                        locale: localizationDelegate.currentLocale,
                      )),
            ));
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ThemeData>('theme', theme));
  }
}
