import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'log/log.dart';
import 'veilid_support/veilid_support.dart';
import 'theming/theming.dart';
import 'app.dart';
import 'dart:io';

void main() async {
  // Disable all debugprints in release mode
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  // Print our PID for debugging
  if (!kIsWeb) {
    debugPrint('VeilidChat PID: $pid');
  }

  // Logs
  initLoggy();

  // Prepare theme
  WidgetsFlutterBinding.ensureInitialized();
  final themeService = await ThemeService.instance;
  var initTheme = themeService.initial;

  // Start up Veilid and Veilid processor in the background
  unawaited(initializeVeilid());

  // Run the app
  // Hot reloads will only restart this part, not Veilid
  runApp(
    ProviderScope(
        observers: const [StateLogger()],
        child: VeilidChatApp(theme: initTheme)),
  );
}
