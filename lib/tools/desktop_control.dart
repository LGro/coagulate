import 'dart:io';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/material.dart';

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
    windowManager.waitUntilReadyToShow(windowOptions, () async {
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
