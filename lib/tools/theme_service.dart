import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../entities/preferences.dart';
import 'radix_generator.dart';

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

  static bool get isPlatformDark =>
      WidgetsBinding.instance.platformDispatcher.platformBrightness ==
      Brightness.dark;

  ThemeData get initial {
    final themePreferencesJson = prefs.getString('themePreferences');
    final themePreferences = themePreferencesJson != null
        ? ThemePreferences.fromJson(themePreferencesJson)
        : const ThemePreferences(
            colorPreference: ColorPreference.vapor,
            brightnessPreference: BrightnessPreference.system,
            displayScale: 1,
          );
    return get(themePreferences);
  }

  Future<void> save(ThemePreferences themePreferences) async {
    await prefs.setString(
        'themePreferences', jsonEncode(themePreferences.toJson()));
  }

  ThemeData get(ThemePreferences themePreferences) {
    late final Brightness brightness;
    switch (themePreferences.brightnessPreference) {
      case BrightnessPreference.system:
        if (isPlatformDark) {
          brightness = Brightness.dark;
        } else {
          brightness = Brightness.light;
        }
      case BrightnessPreference.light:
        brightness = Brightness.light;
      case BrightnessPreference.dark:
        brightness = Brightness.dark;
    }

    late final ThemeData themeData;
    switch (themePreferences.colorPreference) {
      // Special cases
      case ColorPreference.contrast:
        // xxx do contrastGenerator
        themeData = radixGenerator(brightness, RadixThemeColor.grim);
      // Generate from Radix
      case ColorPreference.scarlet:
        themeData = radixGenerator(brightness, RadixThemeColor.scarlet);
      case ColorPreference.babydoll:
        themeData = radixGenerator(brightness, RadixThemeColor.babydoll);
      case ColorPreference.vapor:
        themeData = radixGenerator(brightness, RadixThemeColor.vapor);
      case ColorPreference.gold:
        themeData = radixGenerator(brightness, RadixThemeColor.gold);
      case ColorPreference.garden:
        themeData = radixGenerator(brightness, RadixThemeColor.garden);
      case ColorPreference.forest:
        themeData = radixGenerator(brightness, RadixThemeColor.forest);
      case ColorPreference.arctic:
        themeData = radixGenerator(brightness, RadixThemeColor.arctic);
      case ColorPreference.lapis:
        themeData = radixGenerator(brightness, RadixThemeColor.lapis);
      case ColorPreference.eggplant:
        themeData = radixGenerator(brightness, RadixThemeColor.eggplant);
      case ColorPreference.lime:
        themeData = radixGenerator(brightness, RadixThemeColor.lime);
      case ColorPreference.grim:
        themeData = radixGenerator(brightness, RadixThemeColor.grim);
    }

    return themeData;
  }
}
