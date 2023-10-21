import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:window_manager/window_manager.dart';

import '../tools/responsive.dart';

export 'package:window_manager/window_manager.dart' show TitleBarStyle;

part 'window_control.g.dart';

enum OrientationCapability {
  normal,
  portraitOnly,
  landscapeOnly,
}

// Window Control
@riverpod
class WindowControl extends _$WindowControl {
  /// Change window control
  @override
  FutureOr<bool> build() async {
    await _doWindowSetup(TitleBarStyle.hidden, OrientationCapability.normal);
    return true;
  }

  static Future<void> initialize() async {
    if (isDesktop) {
      await windowManager.ensureInitialized();

      const windowOptions = WindowOptions(
        size: Size(768, 1024),
        //minimumSize: Size(480, 480),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
      );
      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
    }
  }

  Future<void> _doWindowSetup(TitleBarStyle titleBarStyle,
      OrientationCapability orientationCapability) async {
    if (isDesktop) {
      await windowManager.setTitleBarStyle(titleBarStyle);
    } else {
      switch (orientationCapability) {
        case OrientationCapability.normal:
          await SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
        case OrientationCapability.portraitOnly:
          await SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
          ]);
        case OrientationCapability.landscapeOnly:
          await SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
      }
    }
  }

  //////////////////////////////////////////////////////////////
  /// Mutators and Selectors

  /// Reorder accounts
  Future<void> changeWindowSetup(TitleBarStyle titleBarStyle,
      OrientationCapability orientationCapability) async {
    state = const AsyncValue.loading();
    await _doWindowSetup(titleBarStyle, orientationCapability);
    state = const AsyncValue.data(true);
  }
}
