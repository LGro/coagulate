// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'preferences.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

LockPreference _$LockPreferenceFromJson(Map<String, dynamic> json) {
  return _LockPreference.fromJson(json);
}

/// @nodoc
mixin _$LockPreference {
  int get inactivityLockSecs => throw _privateConstructorUsedError;
  bool get lockWhenSwitching => throw _privateConstructorUsedError;
  bool get lockWithSystemLock => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LockPreferenceCopyWith<LockPreference> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LockPreferenceCopyWith<$Res> {
  factory $LockPreferenceCopyWith(
          LockPreference value, $Res Function(LockPreference) then) =
      _$LockPreferenceCopyWithImpl<$Res, LockPreference>;
  @useResult
  $Res call(
      {int inactivityLockSecs,
      bool lockWhenSwitching,
      bool lockWithSystemLock});
}

/// @nodoc
class _$LockPreferenceCopyWithImpl<$Res, $Val extends LockPreference>
    implements $LockPreferenceCopyWith<$Res> {
  _$LockPreferenceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? inactivityLockSecs = null,
    Object? lockWhenSwitching = null,
    Object? lockWithSystemLock = null,
  }) {
    return _then(_value.copyWith(
      inactivityLockSecs: null == inactivityLockSecs
          ? _value.inactivityLockSecs
          : inactivityLockSecs // ignore: cast_nullable_to_non_nullable
              as int,
      lockWhenSwitching: null == lockWhenSwitching
          ? _value.lockWhenSwitching
          : lockWhenSwitching // ignore: cast_nullable_to_non_nullable
              as bool,
      lockWithSystemLock: null == lockWithSystemLock
          ? _value.lockWithSystemLock
          : lockWithSystemLock // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_LockPreferenceCopyWith<$Res>
    implements $LockPreferenceCopyWith<$Res> {
  factory _$$_LockPreferenceCopyWith(
          _$_LockPreference value, $Res Function(_$_LockPreference) then) =
      __$$_LockPreferenceCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int inactivityLockSecs,
      bool lockWhenSwitching,
      bool lockWithSystemLock});
}

/// @nodoc
class __$$_LockPreferenceCopyWithImpl<$Res>
    extends _$LockPreferenceCopyWithImpl<$Res, _$_LockPreference>
    implements _$$_LockPreferenceCopyWith<$Res> {
  __$$_LockPreferenceCopyWithImpl(
      _$_LockPreference _value, $Res Function(_$_LockPreference) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? inactivityLockSecs = null,
    Object? lockWhenSwitching = null,
    Object? lockWithSystemLock = null,
  }) {
    return _then(_$_LockPreference(
      inactivityLockSecs: null == inactivityLockSecs
          ? _value.inactivityLockSecs
          : inactivityLockSecs // ignore: cast_nullable_to_non_nullable
              as int,
      lockWhenSwitching: null == lockWhenSwitching
          ? _value.lockWhenSwitching
          : lockWhenSwitching // ignore: cast_nullable_to_non_nullable
              as bool,
      lockWithSystemLock: null == lockWithSystemLock
          ? _value.lockWithSystemLock
          : lockWithSystemLock // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_LockPreference implements _LockPreference {
  const _$_LockPreference(
      {required this.inactivityLockSecs,
      required this.lockWhenSwitching,
      required this.lockWithSystemLock});

  factory _$_LockPreference.fromJson(Map<String, dynamic> json) =>
      _$$_LockPreferenceFromJson(json);

  @override
  final int inactivityLockSecs;
  @override
  final bool lockWhenSwitching;
  @override
  final bool lockWithSystemLock;

  @override
  String toString() {
    return 'LockPreference(inactivityLockSecs: $inactivityLockSecs, lockWhenSwitching: $lockWhenSwitching, lockWithSystemLock: $lockWithSystemLock)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_LockPreference &&
            (identical(other.inactivityLockSecs, inactivityLockSecs) ||
                other.inactivityLockSecs == inactivityLockSecs) &&
            (identical(other.lockWhenSwitching, lockWhenSwitching) ||
                other.lockWhenSwitching == lockWhenSwitching) &&
            (identical(other.lockWithSystemLock, lockWithSystemLock) ||
                other.lockWithSystemLock == lockWithSystemLock));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, inactivityLockSecs, lockWhenSwitching, lockWithSystemLock);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_LockPreferenceCopyWith<_$_LockPreference> get copyWith =>
      __$$_LockPreferenceCopyWithImpl<_$_LockPreference>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_LockPreferenceToJson(
      this,
    );
  }
}

abstract class _LockPreference implements LockPreference {
  const factory _LockPreference(
      {required final int inactivityLockSecs,
      required final bool lockWhenSwitching,
      required final bool lockWithSystemLock}) = _$_LockPreference;

  factory _LockPreference.fromJson(Map<String, dynamic> json) =
      _$_LockPreference.fromJson;

  @override
  int get inactivityLockSecs;
  @override
  bool get lockWhenSwitching;
  @override
  bool get lockWithSystemLock;
  @override
  @JsonKey(ignore: true)
  _$$_LockPreferenceCopyWith<_$_LockPreference> get copyWith =>
      throw _privateConstructorUsedError;
}

Preferences _$PreferencesFromJson(Map<String, dynamic> json) {
  return _Preferences.fromJson(json);
}

/// @nodoc
mixin _$Preferences {
  DarkModePreference get darkMode => throw _privateConstructorUsedError;
  ColorPreference get themeColor => throw _privateConstructorUsedError;
  LanguagePreference get language => throw _privateConstructorUsedError;
  int get displayScale => throw _privateConstructorUsedError;
  LockPreference get locking => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PreferencesCopyWith<Preferences> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PreferencesCopyWith<$Res> {
  factory $PreferencesCopyWith(
          Preferences value, $Res Function(Preferences) then) =
      _$PreferencesCopyWithImpl<$Res, Preferences>;
  @useResult
  $Res call(
      {DarkModePreference darkMode,
      ColorPreference themeColor,
      LanguagePreference language,
      int displayScale,
      LockPreference locking});

  $LockPreferenceCopyWith<$Res> get locking;
}

/// @nodoc
class _$PreferencesCopyWithImpl<$Res, $Val extends Preferences>
    implements $PreferencesCopyWith<$Res> {
  _$PreferencesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? darkMode = null,
    Object? themeColor = null,
    Object? language = null,
    Object? displayScale = null,
    Object? locking = null,
  }) {
    return _then(_value.copyWith(
      darkMode: null == darkMode
          ? _value.darkMode
          : darkMode // ignore: cast_nullable_to_non_nullable
              as DarkModePreference,
      themeColor: null == themeColor
          ? _value.themeColor
          : themeColor // ignore: cast_nullable_to_non_nullable
              as ColorPreference,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as LanguagePreference,
      displayScale: null == displayScale
          ? _value.displayScale
          : displayScale // ignore: cast_nullable_to_non_nullable
              as int,
      locking: null == locking
          ? _value.locking
          : locking // ignore: cast_nullable_to_non_nullable
              as LockPreference,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $LockPreferenceCopyWith<$Res> get locking {
    return $LockPreferenceCopyWith<$Res>(_value.locking, (value) {
      return _then(_value.copyWith(locking: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_PreferencesCopyWith<$Res>
    implements $PreferencesCopyWith<$Res> {
  factory _$$_PreferencesCopyWith(
          _$_Preferences value, $Res Function(_$_Preferences) then) =
      __$$_PreferencesCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DarkModePreference darkMode,
      ColorPreference themeColor,
      LanguagePreference language,
      int displayScale,
      LockPreference locking});

  @override
  $LockPreferenceCopyWith<$Res> get locking;
}

/// @nodoc
class __$$_PreferencesCopyWithImpl<$Res>
    extends _$PreferencesCopyWithImpl<$Res, _$_Preferences>
    implements _$$_PreferencesCopyWith<$Res> {
  __$$_PreferencesCopyWithImpl(
      _$_Preferences _value, $Res Function(_$_Preferences) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? darkMode = null,
    Object? themeColor = null,
    Object? language = null,
    Object? displayScale = null,
    Object? locking = null,
  }) {
    return _then(_$_Preferences(
      darkMode: null == darkMode
          ? _value.darkMode
          : darkMode // ignore: cast_nullable_to_non_nullable
              as DarkModePreference,
      themeColor: null == themeColor
          ? _value.themeColor
          : themeColor // ignore: cast_nullable_to_non_nullable
              as ColorPreference,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as LanguagePreference,
      displayScale: null == displayScale
          ? _value.displayScale
          : displayScale // ignore: cast_nullable_to_non_nullable
              as int,
      locking: null == locking
          ? _value.locking
          : locking // ignore: cast_nullable_to_non_nullable
              as LockPreference,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Preferences implements _Preferences {
  const _$_Preferences(
      {required this.darkMode,
      required this.themeColor,
      required this.language,
      required this.displayScale,
      required this.locking});

  factory _$_Preferences.fromJson(Map<String, dynamic> json) =>
      _$$_PreferencesFromJson(json);

  @override
  final DarkModePreference darkMode;
  @override
  final ColorPreference themeColor;
  @override
  final LanguagePreference language;
  @override
  final int displayScale;
  @override
  final LockPreference locking;

  @override
  String toString() {
    return 'Preferences(darkMode: $darkMode, themeColor: $themeColor, language: $language, displayScale: $displayScale, locking: $locking)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Preferences &&
            (identical(other.darkMode, darkMode) ||
                other.darkMode == darkMode) &&
            (identical(other.themeColor, themeColor) ||
                other.themeColor == themeColor) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.displayScale, displayScale) ||
                other.displayScale == displayScale) &&
            (identical(other.locking, locking) || other.locking == locking));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, darkMode, themeColor, language, displayScale, locking);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_PreferencesCopyWith<_$_Preferences> get copyWith =>
      __$$_PreferencesCopyWithImpl<_$_Preferences>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_PreferencesToJson(
      this,
    );
  }
}

abstract class _Preferences implements Preferences {
  const factory _Preferences(
      {required final DarkModePreference darkMode,
      required final ColorPreference themeColor,
      required final LanguagePreference language,
      required final int displayScale,
      required final LockPreference locking}) = _$_Preferences;

  factory _Preferences.fromJson(Map<String, dynamic> json) =
      _$_Preferences.fromJson;

  @override
  DarkModePreference get darkMode;
  @override
  ColorPreference get themeColor;
  @override
  LanguagePreference get language;
  @override
  int get displayScale;
  @override
  LockPreference get locking;
  @override
  @JsonKey(ignore: true)
  _$$_PreferencesCopyWith<_$_Preferences> get copyWith =>
      throw _privateConstructorUsedError;
}
