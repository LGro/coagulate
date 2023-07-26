import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'themes/themes.dart';

class ThemeService {
  ThemeService._();
  static late SharedPreferences prefs;
  static ThemeService? _instance;

  static Future<ThemeService> get instance async {
    if (_instance == null) {
      prefs = await SharedPreferences.getInstance();
      _instance = ThemeService._();
    }
    return _instance!;
  }

  final allThemes = <String, ThemeData>{
    'dark': darkTheme,
    'light': lightTheme,
  };

  String get previousThemeName {
    var themeName = prefs.getString('previousThemeName');
    if (themeName == null) {
      final isPlatformDark =
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark;
      themeName = isPlatformDark ? 'light' : 'dark';
    }
    return themeName;
  }

  ThemeData? get initial {
    var themeName = prefs.getString('theme');
    if (themeName == null) {
      final isPlatformDark =
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark;
      themeName = isPlatformDark ? 'dark' : 'light';
    }
    return allThemes[themeName];
  }

  save(String newThemeName) {
    final currentThemeName = prefs.getString('theme');
    if (currentThemeName != null) {
      prefs.setString('previousThemeName', currentThemeName);
    }
    prefs.setString('theme', newThemeName);
  }

  ThemeData getByName(String name) => allThemes[name]!;
}
