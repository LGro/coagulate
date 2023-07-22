// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_login.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

UserLogin _$UserLoginFromJson(Map<String, dynamic> json) {
  return _UserLogin.fromJson(json);
}

/// @nodoc
mixin _$UserLogin {
// Master record key for the user used to index the local accounts table
  Typed<FixedEncodedString43> get accountMasterKey =>
      throw _privateConstructorUsedError; // The identity secret as unlocked from the local accounts table
  Typed<FixedEncodedString43> get secretKey =>
      throw _privateConstructorUsedError; // The time this login was most recently used
  Timestamp get lastActive => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserLoginCopyWith<UserLogin> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserLoginCopyWith<$Res> {
  factory $UserLoginCopyWith(UserLogin value, $Res Function(UserLogin) then) =
      _$UserLoginCopyWithImpl<$Res, UserLogin>;
  @useResult
  $Res call(
      {Typed<FixedEncodedString43> accountMasterKey,
      Typed<FixedEncodedString43> secretKey,
      Timestamp lastActive});
}

/// @nodoc
class _$UserLoginCopyWithImpl<$Res, $Val extends UserLogin>
    implements $UserLoginCopyWith<$Res> {
  _$UserLoginCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accountMasterKey = null,
    Object? secretKey = null,
    Object? lastActive = null,
  }) {
    return _then(_value.copyWith(
      accountMasterKey: null == accountMasterKey
          ? _value.accountMasterKey
          : accountMasterKey // ignore: cast_nullable_to_non_nullable
              as Typed<FixedEncodedString43>,
      secretKey: null == secretKey
          ? _value.secretKey
          : secretKey // ignore: cast_nullable_to_non_nullable
              as Typed<FixedEncodedString43>,
      lastActive: null == lastActive
          ? _value.lastActive
          : lastActive // ignore: cast_nullable_to_non_nullable
              as Timestamp,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_UserLoginCopyWith<$Res> implements $UserLoginCopyWith<$Res> {
  factory _$$_UserLoginCopyWith(
          _$_UserLogin value, $Res Function(_$_UserLogin) then) =
      __$$_UserLoginCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Typed<FixedEncodedString43> accountMasterKey,
      Typed<FixedEncodedString43> secretKey,
      Timestamp lastActive});
}

/// @nodoc
class __$$_UserLoginCopyWithImpl<$Res>
    extends _$UserLoginCopyWithImpl<$Res, _$_UserLogin>
    implements _$$_UserLoginCopyWith<$Res> {
  __$$_UserLoginCopyWithImpl(
      _$_UserLogin _value, $Res Function(_$_UserLogin) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accountMasterKey = null,
    Object? secretKey = null,
    Object? lastActive = null,
  }) {
    return _then(_$_UserLogin(
      accountMasterKey: null == accountMasterKey
          ? _value.accountMasterKey
          : accountMasterKey // ignore: cast_nullable_to_non_nullable
              as Typed<FixedEncodedString43>,
      secretKey: null == secretKey
          ? _value.secretKey
          : secretKey // ignore: cast_nullable_to_non_nullable
              as Typed<FixedEncodedString43>,
      lastActive: null == lastActive
          ? _value.lastActive
          : lastActive // ignore: cast_nullable_to_non_nullable
              as Timestamp,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_UserLogin implements _UserLogin {
  const _$_UserLogin(
      {required this.accountMasterKey,
      required this.secretKey,
      required this.lastActive});

  factory _$_UserLogin.fromJson(Map<String, dynamic> json) =>
      _$$_UserLoginFromJson(json);

// Master record key for the user used to index the local accounts table
  @override
  final Typed<FixedEncodedString43> accountMasterKey;
// The identity secret as unlocked from the local accounts table
  @override
  final Typed<FixedEncodedString43> secretKey;
// The time this login was most recently used
  @override
  final Timestamp lastActive;

  @override
  String toString() {
    return 'UserLogin(accountMasterKey: $accountMasterKey, secretKey: $secretKey, lastActive: $lastActive)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_UserLogin &&
            (identical(other.accountMasterKey, accountMasterKey) ||
                other.accountMasterKey == accountMasterKey) &&
            (identical(other.secretKey, secretKey) ||
                other.secretKey == secretKey) &&
            (identical(other.lastActive, lastActive) ||
                other.lastActive == lastActive));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, accountMasterKey, secretKey, lastActive);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_UserLoginCopyWith<_$_UserLogin> get copyWith =>
      __$$_UserLoginCopyWithImpl<_$_UserLogin>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_UserLoginToJson(
      this,
    );
  }
}

abstract class _UserLogin implements UserLogin {
  const factory _UserLogin(
      {required final Typed<FixedEncodedString43> accountMasterKey,
      required final Typed<FixedEncodedString43> secretKey,
      required final Timestamp lastActive}) = _$_UserLogin;

  factory _UserLogin.fromJson(Map<String, dynamic> json) =
      _$_UserLogin.fromJson;

  @override // Master record key for the user used to index the local accounts table
  Typed<FixedEncodedString43> get accountMasterKey;
  @override // The identity secret as unlocked from the local accounts table
  Typed<FixedEncodedString43> get secretKey;
  @override // The time this login was most recently used
  Timestamp get lastActive;
  @override
  @JsonKey(ignore: true)
  _$$_UserLoginCopyWith<_$_UserLogin> get copyWith =>
      throw _privateConstructorUsedError;
}

ActiveLogins _$ActiveLoginsFromJson(Map<String, dynamic> json) {
  return _ActiveLogins.fromJson(json);
}

/// @nodoc
mixin _$ActiveLogins {
// The list of current logged in accounts
  IList<UserLogin> get userLogins =>
      throw _privateConstructorUsedError; // The current selected account indexed by master record key
  Typed<FixedEncodedString43>? get activeUserLogin =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ActiveLoginsCopyWith<ActiveLogins> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActiveLoginsCopyWith<$Res> {
  factory $ActiveLoginsCopyWith(
          ActiveLogins value, $Res Function(ActiveLogins) then) =
      _$ActiveLoginsCopyWithImpl<$Res, ActiveLogins>;
  @useResult
  $Res call(
      {IList<UserLogin> userLogins,
      Typed<FixedEncodedString43>? activeUserLogin});
}

/// @nodoc
class _$ActiveLoginsCopyWithImpl<$Res, $Val extends ActiveLogins>
    implements $ActiveLoginsCopyWith<$Res> {
  _$ActiveLoginsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userLogins = null,
    Object? activeUserLogin = freezed,
  }) {
    return _then(_value.copyWith(
      userLogins: null == userLogins
          ? _value.userLogins
          : userLogins // ignore: cast_nullable_to_non_nullable
              as IList<UserLogin>,
      activeUserLogin: freezed == activeUserLogin
          ? _value.activeUserLogin
          : activeUserLogin // ignore: cast_nullable_to_non_nullable
              as Typed<FixedEncodedString43>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_ActiveLoginsCopyWith<$Res>
    implements $ActiveLoginsCopyWith<$Res> {
  factory _$$_ActiveLoginsCopyWith(
          _$_ActiveLogins value, $Res Function(_$_ActiveLogins) then) =
      __$$_ActiveLoginsCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {IList<UserLogin> userLogins,
      Typed<FixedEncodedString43>? activeUserLogin});
}

/// @nodoc
class __$$_ActiveLoginsCopyWithImpl<$Res>
    extends _$ActiveLoginsCopyWithImpl<$Res, _$_ActiveLogins>
    implements _$$_ActiveLoginsCopyWith<$Res> {
  __$$_ActiveLoginsCopyWithImpl(
      _$_ActiveLogins _value, $Res Function(_$_ActiveLogins) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userLogins = null,
    Object? activeUserLogin = freezed,
  }) {
    return _then(_$_ActiveLogins(
      userLogins: null == userLogins
          ? _value.userLogins
          : userLogins // ignore: cast_nullable_to_non_nullable
              as IList<UserLogin>,
      activeUserLogin: freezed == activeUserLogin
          ? _value.activeUserLogin
          : activeUserLogin // ignore: cast_nullable_to_non_nullable
              as Typed<FixedEncodedString43>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_ActiveLogins implements _ActiveLogins {
  const _$_ActiveLogins({required this.userLogins, this.activeUserLogin});

  factory _$_ActiveLogins.fromJson(Map<String, dynamic> json) =>
      _$$_ActiveLoginsFromJson(json);

// The list of current logged in accounts
  @override
  final IList<UserLogin> userLogins;
// The current selected account indexed by master record key
  @override
  final Typed<FixedEncodedString43>? activeUserLogin;

  @override
  String toString() {
    return 'ActiveLogins(userLogins: $userLogins, activeUserLogin: $activeUserLogin)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ActiveLogins &&
            const DeepCollectionEquality()
                .equals(other.userLogins, userLogins) &&
            (identical(other.activeUserLogin, activeUserLogin) ||
                other.activeUserLogin == activeUserLogin));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(userLogins), activeUserLogin);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ActiveLoginsCopyWith<_$_ActiveLogins> get copyWith =>
      __$$_ActiveLoginsCopyWithImpl<_$_ActiveLogins>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ActiveLoginsToJson(
      this,
    );
  }
}

abstract class _ActiveLogins implements ActiveLogins {
  const factory _ActiveLogins(
      {required final IList<UserLogin> userLogins,
      final Typed<FixedEncodedString43>? activeUserLogin}) = _$_ActiveLogins;

  factory _ActiveLogins.fromJson(Map<String, dynamic> json) =
      _$_ActiveLogins.fromJson;

  @override // The list of current logged in accounts
  IList<UserLogin> get userLogins;
  @override // The current selected account indexed by master record key
  Typed<FixedEncodedString43>? get activeUserLogin;
  @override
  @JsonKey(ignore: true)
  _$$_ActiveLoginsCopyWith<_$_ActiveLogins> get copyWith =>
      throw _privateConstructorUsedError;
}
