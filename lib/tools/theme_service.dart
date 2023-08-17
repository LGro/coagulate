// ignore_for_file: always_put_required_named_parameters_first

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../entities/preferences.dart';
import 'radix_generator.dart';

part 'theme_service.g.dart';

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

  ScaleColor copyWith(
          {Color? appBackground,
          Color? subtleBackground,
          Color? elementBackground,
          Color? hoverElementBackground,
          Color? activedElementBackground,
          Color? subtleBorder,
          Color? border,
          Color? hoverBorder,
          Color? background,
          Color? hoverBackground,
          Color? subtleText,
          Color? text}) =>
      ScaleColor(
        appBackground: appBackground ?? this.appBackground,
        subtleBackground: subtleBackground ?? this.subtleBackground,
        elementBackground: elementBackground ?? this.elementBackground,
        hoverElementBackground:
            hoverElementBackground ?? this.hoverElementBackground,
        activedElementBackground:
            activedElementBackground ?? this.activedElementBackground,
        subtleBorder: subtleBorder ?? this.subtleBorder,
        border: border ?? this.border,
        hoverBorder: hoverBorder ?? this.hoverBorder,
        background: background ?? this.background,
        hoverBackground: hoverBackground ?? this.hoverBackground,
        subtleText: subtleText ?? this.subtleText,
        text: text ?? this.text,
      );

  // ignore: prefer_constructors_over_static_methods
  static ScaleColor lerp(ScaleColor a, ScaleColor b, double t) => ScaleColor(
        appBackground: Color.lerp(a.appBackground, b.appBackground, t) ??
            const Color(0x00000000),
        subtleBackground:
            Color.lerp(a.subtleBackground, b.subtleBackground, t) ??
                const Color(0x00000000),
        elementBackground:
            Color.lerp(a.elementBackground, b.elementBackground, t) ??
                const Color(0x00000000),
        hoverElementBackground:
            Color.lerp(a.hoverElementBackground, b.hoverElementBackground, t) ??
                const Color(0x00000000),
        activedElementBackground: Color.lerp(
                a.activedElementBackground, b.activedElementBackground, t) ??
            const Color(0x00000000),
        subtleBorder: Color.lerp(a.subtleBorder, b.subtleBorder, t) ??
            const Color(0x00000000),
        border: Color.lerp(a.border, b.border, t) ?? const Color(0x00000000),
        hoverBorder: Color.lerp(a.hoverBorder, b.hoverBorder, t) ??
            const Color(0x00000000),
        background: Color.lerp(a.background, b.background, t) ??
            const Color(0x00000000),
        hoverBackground: Color.lerp(a.hoverBackground, b.hoverBackground, t) ??
            const Color(0x00000000),
        subtleText: Color.lerp(a.subtleText, b.subtleText, t) ??
            const Color(0x00000000),
        text: Color.lerp(a.text, b.text, t) ?? const Color(0x00000000),
      );
}

class ScaleScheme extends ThemeExtension<ScaleScheme> {
  ScaleScheme(
      {required this.primaryScale,
      required this.primaryAlphaScale,
      required this.secondaryScale,
      required this.tertiaryScale,
      required this.grayScale,
      required this.errorScale});

  final ScaleColor primaryScale;
  final ScaleColor primaryAlphaScale;
  final ScaleColor secondaryScale;
  final ScaleColor tertiaryScale;
  final ScaleColor grayScale;
  final ScaleColor errorScale;

  @override
  ScaleScheme copyWith(
          {ScaleColor? primaryScale,
          ScaleColor? primaryAlphaScale,
          ScaleColor? secondaryScale,
          ScaleColor? tertiaryScale,
          ScaleColor? grayScale,
          ScaleColor? errorScale}) =>
      ScaleScheme(
        primaryScale: primaryScale ?? this.primaryScale,
        primaryAlphaScale: primaryAlphaScale ?? this.primaryAlphaScale,
        secondaryScale: secondaryScale ?? this.secondaryScale,
        tertiaryScale: tertiaryScale ?? this.tertiaryScale,
        grayScale: grayScale ?? this.grayScale,
        errorScale: errorScale ?? this.errorScale,
      );

  @override
  ScaleScheme lerp(ScaleScheme? other, double t) {
    if (other is! ScaleScheme) {
      return this;
    }
    return ScaleScheme(
      primaryScale: ScaleColor.lerp(primaryScale, other.primaryScale, t),
      primaryAlphaScale:
          ScaleColor.lerp(primaryAlphaScale, other.primaryAlphaScale, t),
      secondaryScale: ScaleColor.lerp(secondaryScale, other.secondaryScale, t),
      tertiaryScale: ScaleColor.lerp(tertiaryScale, other.tertiaryScale, t),
      grayScale: ScaleColor.lerp(grayScale, other.grayScale, t),
      errorScale: ScaleColor.lerp(errorScale, other.errorScale, t),
    );
  }

  ChatTheme toChatTheme() => DefaultChatTheme(
        primaryColor: primaryScale.background,
        secondaryColor: secondaryScale.background,
        backgroundColor: grayScale.appBackground,
        inputBackgroundColor: grayScale.subtleBackground,
        inputBorderRadius: BorderRadius.zero,
        inputTextDecoration: InputDecoration(
          border: OutlineInputBorder(
              borderSide: BorderSide(color: primaryScale.subtleBorder),
              borderRadius: const BorderRadius.all(Radius.circular(16))),
        ),
        inputContainerDecoration:
            BoxDecoration(color: primaryScale.appBackground),
        inputPadding: EdgeInsets.all(5),
        inputTextStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1,
        ),
        attachmentButtonIcon: Icon(Icons.attach_file),
      );
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
    final themePreferences = load();
    return get(themePreferences);
  }

  ThemePreferences load() {
    final themePreferencesJson = prefs.getString('themePreferences');
    ThemePreferences? themePreferences;
    if (themePreferencesJson != null) {
      try {
        themePreferences = ThemePreferences.fromJson(themePreferencesJson);
        // ignore: avoid_catches_without_on_clauses
      } catch (_) {
        // ignore
      }
    }
    return themePreferences ??
        const ThemePreferences(
          colorPreference: ColorPreference.vapor,
          brightnessPreference: BrightnessPreference.system,
          displayScale: 1,
        );
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

@riverpod
Future<ThemeService> themeService() => ThemeService.instance;
