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

_$_Preferences _$$_PreferencesFromJson(Map<String, dynamic> json) =>
    _$_Preferences(
      darkMode: DarkModePreference.fromJson(json['dark_mode'] as String),
      themeColor: ColorPreference.fromJson(json['theme_color'] as String),
      language: LanguagePreference.fromJson(json['language'] as String),
      displayScale: json['display_scale'] as int,
      locking: LockPreference.fromJson(json['locking'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$_PreferencesToJson(_$_Preferences instance) =>
    <String, dynamic>{
      'dark_mode': instance.darkMode.toJson(),
      'theme_color': instance.themeColor.toJson(),
      'language': instance.language.toJson(),
      'display_scale': instance.displayScale,
      'locking': instance.locking.toJson(),
    };
