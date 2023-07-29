// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_LockPreference _$$_LockPreferenceFromJson(Map<String, dynamic> json) =>
    _$_LockPreference(
      inactivityLockSecs: json['inactivity_lock_secs'] as int,
      lockWhenSwitching: json['lock_when_switching'] as bool,
      lockWithSystemLock: json['lock_with_system_lock'] as bool,
    );

Map<String, dynamic> _$$_LockPreferenceToJson(_$_LockPreference instance) =>
    <String, dynamic>{
      'inactivity_lock_secs': instance.inactivityLockSecs,
      'lock_when_switching': instance.lockWhenSwitching,
      'lock_with_system_lock': instance.lockWithSystemLock,
    };

_$_ThemePreferences _$$_ThemePreferencesFromJson(Map<String, dynamic> json) =>
    _$_ThemePreferences(
      brightnessPreference:
          BrightnessPreference.fromJson(json['brightness_preference']),
      colorPreference: ColorPreference.fromJson(json['color_preference']),
      displayScale: (json['display_scale'] as num).toDouble(),
    );

Map<String, dynamic> _$$_ThemePreferencesToJson(_$_ThemePreferences instance) =>
    <String, dynamic>{
      'brightness_preference': instance.brightnessPreference.toJson(),
      'color_preference': instance.colorPreference.toJson(),
      'display_scale': instance.displayScale,
    };

_$_Preferences _$$_PreferencesFromJson(Map<String, dynamic> json) =>
    _$_Preferences(
      themePreferences: ThemePreferences.fromJson(json['theme_preferences']),
      language: LanguagePreference.fromJson(json['language']),
      locking: LockPreference.fromJson(json['locking']),
    );

Map<String, dynamic> _$$_PreferencesToJson(_$_Preferences instance) =>
    <String, dynamic>{
      'theme_preferences': instance.themePreferences.toJson(),
      'language': instance.language.toJson(),
      'locking': instance.locking.toJson(),
    };
