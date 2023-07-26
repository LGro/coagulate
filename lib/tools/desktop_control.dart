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

void enableTitleBar(bool enabled) {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    if (enabled) {
      windowManager.setTitleBarStyle(TitleBarStyle.normal);
    } else {
      windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    }
  }
}

void portraitOnly() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

void landscapeOnly() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
}
