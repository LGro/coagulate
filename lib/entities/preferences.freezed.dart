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
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

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
abstract class _$$LockPreferenceImplCopyWith<$Res>
    implements $LockPreferenceCopyWith<$Res> {
  factory _$$LockPreferenceImplCopyWith(_$LockPreferenceImpl value,
          $Res Function(_$LockPreferenceImpl) then) =
      __$$LockPreferenceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int inactivityLockSecs,
      bool lockWhenSwitching,
      bool lockWithSystemLock});
}

/// @nodoc
class __$$LockPreferenceImplCopyWithImpl<$Res>
    extends _$LockPreferenceCopyWithImpl<$Res, _$LockPreferenceImpl>
    implements _$$LockPreferenceImplCopyWith<$Res> {
  __$$LockPreferenceImplCopyWithImpl(
      _$LockPreferenceImpl _value, $Res Function(_$LockPreferenceImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? inactivityLockSecs = null,
    Object? lockWhenSwitching = null,
    Object? lockWithSystemLock = null,
  }) {
    return _then(_$LockPreferenceImpl(
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
class _$LockPreferenceImpl implements _LockPreference {
  const _$LockPreferenceImpl(
      {required this.inactivityLockSecs,
      required this.lockWhenSwitching,
      required this.lockWithSystemLock});

  factory _$LockPreferenceImpl.fromJson(Map<String, dynamic> json) =>
      _$$LockPreferenceImplFromJson(json);

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
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LockPreferenceImpl &&
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
  _$$LockPreferenceImplCopyWith<_$LockPreferenceImpl> get copyWith =>
      __$$LockPreferenceImplCopyWithImpl<_$LockPreferenceImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LockPreferenceImplToJson(
      this,
    );
  }
}

abstract class _LockPreference implements LockPreference {
  const factory _LockPreference(
      {required final int inactivityLockSecs,
      required final bool lockWhenSwitching,
      required final bool lockWithSystemLock}) = _$LockPreferenceImpl;

  factory _LockPreference.fromJson(Map<String, dynamic> json) =
      _$LockPreferenceImpl.fromJson;

  @override
  int get inactivityLockSecs;
  @override
  bool get lockWhenSwitching;
  @override
  bool get lockWithSystemLock;
  @override
  @JsonKey(ignore: true)
  _$$LockPreferenceImplCopyWith<_$LockPreferenceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ThemePreferences _$ThemePreferencesFromJson(Map<String, dynamic> json) {
  return _ThemePreferences.fromJson(json);
}

/// @nodoc
mixin _$ThemePreferences {
  BrightnessPreference get brightnessPreference =>
      throw _privateConstructorUsedError;
  ColorPreference get colorPreference => throw _privateConstructorUsedError;
  double get displayScale => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ThemePreferencesCopyWith<ThemePreferences> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ThemePreferencesCopyWith<$Res> {
  factory $ThemePreferencesCopyWith(
          ThemePreferences value, $Res Function(ThemePreferences) then) =
      _$ThemePreferencesCopyWithImpl<$Res, ThemePreferences>;
  @useResult
  $Res call(
      {BrightnessPreference brightnessPreference,
      ColorPreference colorPreference,
      double displayScale});
}

/// @nodoc
class _$ThemePreferencesCopyWithImpl<$Res, $Val extends ThemePreferences>
    implements $ThemePreferencesCopyWith<$Res> {
  _$ThemePreferencesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? brightnessPreference = null,
    Object? colorPreference = null,
    Object? displayScale = null,
  }) {
    return _then(_value.copyWith(
      brightnessPreference: null == brightnessPreference
          ? _value.brightnessPreference
          : brightnessPreference // ignore: cast_nullable_to_non_nullable
              as BrightnessPreference,
      colorPreference: null == colorPreference
          ? _value.colorPreference
          : colorPreference // ignore: cast_nullable_to_non_nullable
              as ColorPreference,
      displayScale: null == displayScale
          ? _value.displayScale
          : displayScale // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ThemePreferencesImplCopyWith<$Res>
    implements $ThemePreferencesCopyWith<$Res> {
  factory _$$ThemePreferencesImplCopyWith(_$ThemePreferencesImpl value,
          $Res Function(_$ThemePreferencesImpl) then) =
      __$$ThemePreferencesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {BrightnessPreference brightnessPreference,
      ColorPreference colorPreference,
      double displayScale});
}

/// @nodoc
class __$$ThemePreferencesImplCopyWithImpl<$Res>
    extends _$ThemePreferencesCopyWithImpl<$Res, _$ThemePreferencesImpl>
    implements _$$ThemePreferencesImplCopyWith<$Res> {
  __$$ThemePreferencesImplCopyWithImpl(_$ThemePreferencesImpl _value,
      $Res Function(_$ThemePreferencesImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? brightnessPreference = null,
    Object? colorPreference = null,
    Object? displayScale = null,
  }) {
    return _then(_$ThemePreferencesImpl(
      brightnessPreference: null == brightnessPreference
          ? _value.brightnessPreference
          : brightnessPreference // ignore: cast_nullable_to_non_nullable
              as BrightnessPreference,
      colorPreference: null == colorPreference
          ? _value.colorPreference
          : colorPreference // ignore: cast_nullable_to_non_nullable
              as ColorPreference,
      displayScale: null == displayScale
          ? _value.displayScale
          : displayScale // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ThemePreferencesImpl implements _ThemePreferences {
  const _$ThemePreferencesImpl(
      {required this.brightnessPreference,
      required this.colorPreference,
      required this.displayScale});

  factory _$ThemePreferencesImpl.fromJson(Map<String, dynamic> json) =>
      _$$ThemePreferencesImplFromJson(json);

  @override
  final BrightnessPreference brightnessPreference;
  @override
  final ColorPreference colorPreference;
  @override
  final double displayScale;

  @override
  String toString() {
    return 'ThemePreferences(brightnessPreference: $brightnessPreference, colorPreference: $colorPreference, displayScale: $displayScale)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ThemePreferencesImpl &&
            (identical(other.brightnessPreference, brightnessPreference) ||
                other.brightnessPreference == brightnessPreference) &&
            (identical(other.colorPreference, colorPreference) ||
                other.colorPreference == colorPreference) &&
            (identical(other.displayScale, displayScale) ||
                other.displayScale == displayScale));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, brightnessPreference, colorPreference, displayScale);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ThemePreferencesImplCopyWith<_$ThemePreferencesImpl> get copyWith =>
      __$$ThemePreferencesImplCopyWithImpl<_$ThemePreferencesImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ThemePreferencesImplToJson(
      this,
    );
  }
}

abstract class _ThemePreferences implements ThemePreferences {
  const factory _ThemePreferences(
      {required final BrightnessPreference brightnessPreference,
      required final ColorPreference colorPreference,
      required final double displayScale}) = _$ThemePreferencesImpl;

  factory _ThemePreferences.fromJson(Map<String, dynamic> json) =
      _$ThemePreferencesImpl.fromJson;

  @override
  BrightnessPreference get brightnessPreference;
  @override
  ColorPreference get colorPreference;
  @override
  double get displayScale;
  @override
  @JsonKey(ignore: true)
  _$$ThemePreferencesImplCopyWith<_$ThemePreferencesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Preferences _$PreferencesFromJson(Map<String, dynamic> json) {
  return _Preferences.fromJson(json);
}

/// @nodoc
mixin _$Preferences {
  ThemePreferences get themePreferences => throw _privateConstructorUsedError;
  LanguagePreference get language => throw _privateConstructorUsedError;
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
      {ThemePreferences themePreferences,
      LanguagePreference language,
      LockPreference locking});

  $ThemePreferencesCopyWith<$Res> get themePreferences;
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
    Object? themePreferences = null,
    Object? language = null,
    Object? locking = null,
  }) {
    return _then(_value.copyWith(
      themePreferences: null == themePreferences
          ? _value.themePreferences
          : themePreferences // ignore: cast_nullable_to_non_nullable
              as ThemePreferences,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as LanguagePreference,
      locking: null == locking
          ? _value.locking
          : locking // ignore: cast_nullable_to_non_nullable
              as LockPreference,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ThemePreferencesCopyWith<$Res> get themePreferences {
    return $ThemePreferencesCopyWith<$Res>(_value.themePreferences, (value) {
      return _then(_value.copyWith(themePreferences: value) as $Val);
    });
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
abstract class _$$PreferencesImplCopyWith<$Res>
    implements $PreferencesCopyWith<$Res> {
  factory _$$PreferencesImplCopyWith(
          _$PreferencesImpl value, $Res Function(_$PreferencesImpl) then) =
      __$$PreferencesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {ThemePreferences themePreferences,
      LanguagePreference language,
      LockPreference locking});

  @override
  $ThemePreferencesCopyWith<$Res> get themePreferences;
  @override
  $LockPreferenceCopyWith<$Res> get locking;
}

/// @nodoc
class __$$PreferencesImplCopyWithImpl<$Res>
    extends _$PreferencesCopyWithImpl<$Res, _$PreferencesImpl>
    implements _$$PreferencesImplCopyWith<$Res> {
  __$$PreferencesImplCopyWithImpl(
      _$PreferencesImpl _value, $Res Function(_$PreferencesImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themePreferences = null,
    Object? language = null,
    Object? locking = null,
  }) {
    return _then(_$PreferencesImpl(
      themePreferences: null == themePreferences
          ? _value.themePreferences
          : themePreferences // ignore: cast_nullable_to_non_nullable
              as ThemePreferences,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as LanguagePreference,
      locking: null == locking
          ? _value.locking
          : locking // ignore: cast_nullable_to_non_nullable
              as LockPreference,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PreferencesImpl implements _Preferences {
  const _$PreferencesImpl(
      {required this.themePreferences,
      required this.language,
      required this.locking});

  factory _$PreferencesImpl.fromJson(Map<String, dynamic> json) =>
      _$$PreferencesImplFromJson(json);

  @override
  final ThemePreferences themePreferences;
  @override
  final LanguagePreference language;
  @override
  final LockPreference locking;

  @override
  String toString() {
    return 'Preferences(themePreferences: $themePreferences, language: $language, locking: $locking)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PreferencesImpl &&
            (identical(other.themePreferences, themePreferences) ||
                other.themePreferences == themePreferences) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.locking, locking) || other.locking == locking));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, themePreferences, language, locking);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PreferencesImplCopyWith<_$PreferencesImpl> get copyWith =>
      __$$PreferencesImplCopyWithImpl<_$PreferencesImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PreferencesImplToJson(
      this,
    );
  }
}

abstract class _Preferences implements Preferences {
  const factory _Preferences(
      {required final ThemePreferences themePreferences,
      required final LanguagePreference language,
      required final LockPreference locking}) = _$PreferencesImpl;

  factory _Preferences.fromJson(Map<String, dynamic> json) =
      _$PreferencesImpl.fromJson;

  @override
  ThemePreferences get themePreferences;
  @override
  LanguagePreference get language;
  @override
  LockPreference get locking;
  @override
  @JsonKey(ignore: true)
  _$$PreferencesImplCopyWith<_$PreferencesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
