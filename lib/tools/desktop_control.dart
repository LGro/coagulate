import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

Future<void> setupDesktopWindow() async {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      size: Size(768, 1024),
      minimumSize: Size(480, 640),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
}

Future<void> enableTitleBar(bool enabled) async {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    if (enabled) {
      await windowManager.setTitleBarStyle(TitleBarStyle.normal);
    } else {
      await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    }
  }
}

Future<void> portraitOnly() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

Future<void> landscapeOnly() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
}
