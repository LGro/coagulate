import 'package:change_case/change_case.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'preferences.freezed.dart';
part 'preferences.g.dart';

// Theme supports light and dark mode, optionally selected by the
// operating system
enum DarkModePreference {
  system,
  light,
  dark;

  factory DarkModePreference.fromJson(dynamic j) =>
      DarkModePreference.values.byName((j as String).toCamelCase());

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
  amber,
  blue,
  bronze,
  brown,
  crimson,
  cyan,
  gold,
  grass,
  gray,
  green,
  indigo,
  lime,
  mauve,
  mint,
  olive,
  orange,
  pink,
  plum,
  purple,
  red,
  sage,
  sand,
  sky,
  slate,
  teal,
  tomato,
  violet,
  yellow;

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

// Preferences are stored in a table locally and globally affect all
// accounts imported/added and the app in general
@freezed
class Preferences with _$Preferences {
  const factory Preferences({
    required DarkModePreference darkMode,
    required ColorPreference themeColor,
    required LanguagePreference language,
    required int displayScale,
    required LockPreference locking,
  }) = _Preferences;

  factory Preferences.fromJson(dynamic json) =>
      _$PreferencesFromJson(json as Map<String, dynamic>);
}
