import 'dart:async';
import 'dart:io';

import 'package:ansicolor/ansicolor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'providers/window_control.dart';
import 'tools/tools.dart';
import 'veilid_init.dart';

void main() async {
  // Disable all debugprints in release mode
  if (kReleaseMode) {
    debugPrint = (message, {wrapWidth}) {};
  }

  // Print our PID for debugging
  if (!kIsWeb) {
    debugPrint('VeilidChat PID: $pid');
  }

  // Ansi colors
  ansiColorDisabled = false;

  // Catch errors
  await runZonedGuarded(() async {
    // Logs
    initLoggy();

    // Prepare theme
    WidgetsFlutterBinding.ensureInitialized();
    final themeService = await ThemeService.instance;
    final initTheme = themeService.initial;

    // Manage window on desktop platforms
    await WindowControl.initialize();

    // Make localization delegate
    final delegate = await LocalizationDelegate.create(
        fallbackLocale: 'en_US', supportedLocales: ['en_US']);
    await initializeDateFormatting();

    // Start up Veilid and Veilid processor in the background
    unawaited(initializeVeilid());

    // Run the app
    // Hot reloads will only restart this part, not Veilid
    runApp(ProviderScope(
        observers: const [StateLogger()],
        child: LocalizedApp(delegate, VeilidChatApp(theme: initTheme))));
  }, (error, stackTrace) {
    log.error('Dart Runtime: {$error}\n{$stackTrace}');
  });
}
