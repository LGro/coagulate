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
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserLogin _$UserLoginFromJson(Map<String, dynamic> json) {
  return _UserLogin.fromJson(json);
}

/// @nodoc
mixin _$UserLogin {
// Master record key for the user used to index the local accounts table
  Typed<FixedEncodedString43> get accountMasterRecordKey =>
      throw _privateConstructorUsedError; // The identity secret as unlocked from the local accounts table
  Typed<FixedEncodedString43> get identitySecret =>
      throw _privateConstructorUsedError; // The account record key, owner key and secret pulled from the identity
  AccountRecordInfo get accountRecordInfo =>
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
      {Typed<FixedEncodedString43> accountMasterRecordKey,
      Typed<FixedEncodedString43> identitySecret,
      AccountRecordInfo accountRecordInfo,
      Timestamp lastActive});

  $AccountRecordInfoCopyWith<$Res> get accountRecordInfo;
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
    Object? accountMasterRecordKey = null,
    Object? identitySecret = null,
    Object? accountRecordInfo = null,
    Object? lastActive = null,
  }) {
    return _then(_value.copyWith(
      accountMasterRecordKey: null == accountMasterRecordKey
          ? _value.accountMasterRecordKey
          : accountMasterRecordKey // ignore: cast_nullable_to_non_nullable
              as Typed<FixedEncodedString43>,
      identitySecret: null == identitySecret
          ? _value.identitySecret
          : identitySecret // ignore: cast_nullable_to_non_nullable
              as Typed<FixedEncodedString43>,
      accountRecordInfo: null == accountRecordInfo
          ? _value.accountRecordInfo
          : accountRecordInfo // ignore: cast_nullable_to_non_nullable
              as AccountRecordInfo,
      lastActive: null == lastActive
          ? _value.lastActive
          : lastActive // ignore: cast_nullable_to_non_nullable
              as Timestamp,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $AccountRecordInfoCopyWith<$Res> get accountRecordInfo {
    return $AccountRecordInfoCopyWith<$Res>(_value.accountRecordInfo, (value) {
      return _then(_value.copyWith(accountRecordInfo: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserLoginImplCopyWith<$Res>
    implements $UserLoginCopyWith<$Res> {
  factory _$$UserLoginImplCopyWith(
          _$UserLoginImpl value, $Res Function(_$UserLoginImpl) then) =
      __$$UserLoginImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Typed<FixedEncodedString43> accountMasterRecordKey,
      Typed<FixedEncodedString43> identitySecret,
      AccountRecordInfo accountRecordInfo,
      Timestamp lastActive});

  @override
  $AccountRecordInfoCopyWith<$Res> get accountRecordInfo;
}

/// @nodoc
class __$$UserLoginImplCopyWithImpl<$Res>
    extends _$UserLoginCopyWithImpl<$Res, _$UserLoginImpl>
    implements _$$UserLoginImplCopyWith<$Res> {
  __$$UserLoginImplCopyWithImpl(
      _$UserLoginImpl _value, $Res Function(_$UserLoginImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accountMasterRecordKey = null,
    Object? identitySecret = null,
    Object? accountRecordInfo = null,
    Object? lastActive = null,
  }) {
    return _then(_$UserLoginImpl(
      accountMasterRecordKey: null == accountMasterRecordKey
          ? _value.accountMasterRecordKey
          : accountMasterRecordKey // ignore: cast_nullable_to_non_nullable
              as Typed<FixedEncodedString43>,
      identitySecret: null == identitySecret
          ? _value.identitySecret
          : identitySecret // ignore: cast_nullable_to_non_nullable
              as Typed<FixedEncodedString43>,
      accountRecordInfo: null == accountRecordInfo
          ? _value.accountRecordInfo
          : accountRecordInfo // ignore: cast_nullable_to_non_nullable
              as AccountRecordInfo,
      lastActive: null == lastActive
          ? _value.lastActive
          : lastActive // ignore: cast_nullable_to_non_nullable
              as Timestamp,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserLoginImpl implements _UserLogin {
  const _$UserLoginImpl(
      {required this.accountMasterRecordKey,
      required this.identitySecret,
      required this.accountRecordInfo,
      required this.lastActive});

  factory _$UserLoginImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserLoginImplFromJson(json);

// Master record key for the user used to index the local accounts table
  @override
  final Typed<FixedEncodedString43> accountMasterRecordKey;
// The identity secret as unlocked from the local accounts table
  @override
  final Typed<FixedEncodedString43> identitySecret;
// The account record key, owner key and secret pulled from the identity
  @override
  final AccountRecordInfo accountRecordInfo;
// The time this login was most recently used
  @override
  final Timestamp lastActive;

  @override
  String toString() {
    return 'UserLogin(accountMasterRecordKey: $accountMasterRecordKey, identitySecret: $identitySecret, accountRecordInfo: $accountRecordInfo, lastActive: $lastActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserLoginImpl &&
            (identical(other.accountMasterRecordKey, accountMasterRecordKey) ||
                other.accountMasterRecordKey == accountMasterRecordKey) &&
            (identical(other.identitySecret, identitySecret) ||
                other.identitySecret == identitySecret) &&
            (identical(other.accountRecordInfo, accountRecordInfo) ||
                other.accountRecordInfo == accountRecordInfo) &&
            (identical(other.lastActive, lastActive) ||
                other.lastActive == lastActive));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, accountMasterRecordKey,
      identitySecret, accountRecordInfo, lastActive);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserLoginImplCopyWith<_$UserLoginImpl> get copyWith =>
      __$$UserLoginImplCopyWithImpl<_$UserLoginImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserLoginImplToJson(
      this,
    );
  }
}

abstract class _UserLogin implements UserLogin {
  const factory _UserLogin(
      {required final Typed<FixedEncodedString43> accountMasterRecordKey,
      required final Typed<FixedEncodedString43> identitySecret,
      required final AccountRecordInfo accountRecordInfo,
      required final Timestamp lastActive}) = _$UserLoginImpl;

  factory _UserLogin.fromJson(Map<String, dynamic> json) =
      _$UserLoginImpl.fromJson;

  @override // Master record key for the user used to index the local accounts table
  Typed<FixedEncodedString43> get accountMasterRecordKey;
  @override // The identity secret as unlocked from the local accounts table
  Typed<FixedEncodedString43> get identitySecret;
  @override // The account record key, owner key and secret pulled from the identity
  AccountRecordInfo get accountRecordInfo;
  @override // The time this login was most recently used
  Timestamp get lastActive;
  @override
  @JsonKey(ignore: true)
  _$$UserLoginImplCopyWith<_$UserLoginImpl> get copyWith =>
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
abstract class _$$ActiveLoginsImplCopyWith<$Res>
    implements $ActiveLoginsCopyWith<$Res> {
  factory _$$ActiveLoginsImplCopyWith(
          _$ActiveLoginsImpl value, $Res Function(_$ActiveLoginsImpl) then) =
      __$$ActiveLoginsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {IList<UserLogin> userLogins,
      Typed<FixedEncodedString43>? activeUserLogin});
}

/// @nodoc
class __$$ActiveLoginsImplCopyWithImpl<$Res>
    extends _$ActiveLoginsCopyWithImpl<$Res, _$ActiveLoginsImpl>
    implements _$$ActiveLoginsImplCopyWith<$Res> {
  __$$ActiveLoginsImplCopyWithImpl(
      _$ActiveLoginsImpl _value, $Res Function(_$ActiveLoginsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userLogins = null,
    Object? activeUserLogin = freezed,
  }) {
    return _then(_$ActiveLoginsImpl(
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
class _$ActiveLoginsImpl implements _ActiveLogins {
  const _$ActiveLoginsImpl({required this.userLogins, this.activeUserLogin});

  factory _$ActiveLoginsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActiveLoginsImplFromJson(json);

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
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActiveLoginsImpl &&
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
  _$$ActiveLoginsImplCopyWith<_$ActiveLoginsImpl> get copyWith =>
      __$$ActiveLoginsImplCopyWithImpl<_$ActiveLoginsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ActiveLoginsImplToJson(
      this,
    );
  }
}

abstract class _ActiveLogins implements ActiveLogins {
  const factory _ActiveLogins(
      {required final IList<UserLogin> userLogins,
      final Typed<FixedEncodedString43>? activeUserLogin}) = _$ActiveLoginsImpl;

  factory _ActiveLogins.fromJson(Map<String, dynamic> json) =
      _$ActiveLoginsImpl.fromJson;

  @override // The list of current logged in accounts
  IList<UserLogin> get userLogins;
  @override // The current selected account indexed by master record key
  Typed<FixedEncodedString43>? get activeUserLogin;
  @override
  @JsonKey(ignore: true)
  _$$ActiveLoginsImplCopyWith<_$ActiveLoginsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
