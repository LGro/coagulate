// ignore_for_file: always_put_required_named_parameters_first

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../entities/preferences.dart';
import 'radix_generator.dart';

@immutable
class ExtendedColorScheme extends ColorScheme {
  const ExtendedColorScheme({
    required this.scaleScheme,
    required super.brightness,
    required super.primary,
    required super.onPrimary,
    super.primaryContainer,
    super.onPrimaryContainer,
    required super.secondary,
    required super.onSecondary,
    super.secondaryContainer,
    super.onSecondaryContainer,
    super.tertiary,
    super.onTertiary,
    super.tertiaryContainer,
    super.onTertiaryContainer,
    required super.error,
    required super.onError,
    super.errorContainer,
    super.onErrorContainer,
    required super.background,
    required super.onBackground,
    required super.surface,
    required super.onSurface,
    super.surfaceVariant,
    super.onSurfaceVariant,
    super.outline,
    super.outlineVariant,
    super.shadow,
    super.scrim,
    super.inverseSurface,
    super.onInverseSurface,
    super.inversePrimary,
    super.surfaceTint,
  });

  final ScaleScheme scaleScheme;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ScaleScheme>('scales', scaleScheme));
  }
}

class ScaleColor {
  ScaleColor({
    required this.appBackground,
    required this.subtleBackground,
    required this.elementBackground,
    required this.hoverElementBackground,
    required this.activedElementBackground,
    required this.subtleBorder,
    required this.border,
    required this.hoverBorder,
    required this.background,
    required this.hoverBackground,
    required this.subtleText,
    required this.text,
  });

  Color appBackground;
  Color subtleBackground;
  Color elementBackground;
  Color hoverElementBackground;
  Color activedElementBackground;
  Color subtleBorder;
  Color border;
  Color hoverBorder;
  Color background;
  Color hoverBackground;
  Color subtleText;
  Color text;
}

class ScaleScheme {
  ScaleScheme(
      {required this.primaryScale,
      required this.primaryAlphaScale,
      required this.secondaryScale,
      required this.tertiaryScale,
      required this.grayScale,
      required this.errorScale});

  ScaleColor primaryScale;
  ScaleColor primaryAlphaScale;
  ScaleColor secondaryScale;
  ScaleColor tertiaryScale;
  ScaleColor grayScale;
  ScaleColor errorScale;

  static ScaleScheme of(BuildContext context) =>
      (Theme.of(context).colorScheme as ExtendedColorScheme).scaleScheme;
}

////////////////////////////////////////////////////////////////////////

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
