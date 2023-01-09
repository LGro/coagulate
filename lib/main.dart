import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'log/loggy.dart';
import 'log/state_logger.dart';
import 'veilid_support/veilid_log.dart';
import 'theme/theme_service.dart';
import 'app.dart';

void main() async {
  // Logs
  initLoggy();
  initVeilidLog();

  // Run the app
  WidgetsFlutterBinding.ensureInitialized();
  final themeService = await ThemeService.instance;
  var initTheme = themeService.initial;
  runApp(
    ProviderScope(
        observers: [const StateLogger()],
        child: VeilidChatApp(theme: initTheme)),
  );
}
