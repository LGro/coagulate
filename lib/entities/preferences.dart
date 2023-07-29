import 'package:change_case/change_case.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'preferences.freezed.dart';
part 'preferences.g.dart';

// Theme supports light and dark mode, optionally selected by the
// operating system
enum BrightnessPreference {
  system,
  light,
  dark;

  factory BrightnessPreference.fromJson(dynamic j) =>
      BrightnessPreference.values.byName((j as String).toCamelCase());

  String toJson() => name.toPascalCase();
}

// Lock preference changes how frequently the messenger locks its
// interface and requires the identitySecretKey to be entered (pin/password/etc)
@freezed
class LockPreference with _$LockPreference {
  const factory LockPreference({
    required int inactivityLockSecs,
    required bool lockWhenSwitching,
    required bool lockWithSystemLock,
  }) = _LockPreference;

  factory LockPreference.fromJson(dynamic json) =>
      _$LockPreferenceFromJson(json as Map<String, dynamic>);
}

// Theme supports multiple color variants based on 'Radix'
enum ColorPreference {
  // Radix Colors
  scarlet,
  babydoll,
  vapor,
  gold,
  garden,
  forest,
  arctic,
  lapis,
  eggplant,
  lime,
  grim,
  // Accessible Colors
  contrast;

  factory ColorPreference.fromJson(dynamic j) =>
      ColorPreference.values.byName((j as String).toCamelCase());
  String toJson() => name.toPascalCase();
}

// Theme supports multiple translations
enum LanguagePreference {
  englishUS;

  factory LanguagePreference.fromJson(dynamic j) =>
      LanguagePreference.values.byName((j as String).toCamelCase());
  String toJson() => name.toPascalCase();
}

@freezed
class ThemePreferences with _$ThemePreferences {
  const factory ThemePreferences({
    required BrightnessPreference brightnessPreference,
    required ColorPreference colorPreference,
    required double displayScale,
  }) = _ThemePreferences;

  factory ThemePreferences.fromJson(dynamic json) =>
      _$ThemePreferencesFromJson(json as Map<String, dynamic>);
}

// Preferences are stored in a table locally and globally affect all
// accounts imported/added and the app in general
@freezed
class Preferences with _$Preferences {
  const factory Preferences({
    required ThemePreferences themePreferences,
    required LanguagePreference language,
    required LockPreference locking,
  }) = _Preferences;

  factory Preferences.fromJson(dynamic json) =>
      _$PreferencesFromJson(json as Map<String, dynamic>);
}
