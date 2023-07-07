// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'local_account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

LocalAccount _$LocalAccountFromJson(Map<String, dynamic> json) {
  return _LocalAccount.fromJson(json);
}

/// @nodoc
mixin _$LocalAccount {
// The master key record for the account, containing the identityPublicKey
  IdentityMaster get identityMaster =>
      throw _privateConstructorUsedError; // The encrypted identity secret that goes with the identityPublicKey
  @Uint8ListJsonConverter()
  Uint8List get identitySecretKeyBytes =>
      throw _privateConstructorUsedError; // The kind of encryption input used on the account
  EncryptionKeyType get encryptionKeyType =>
      throw _privateConstructorUsedError; // If account is not hidden, password can be retrieved via
  bool get biometricsEnabled =>
      throw _privateConstructorUsedError; // Keep account hidden unless account password is entered
// (tries all hidden accounts with auth method (no biometrics))
  bool get hiddenAccount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LocalAccountCopyWith<LocalAccount> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocalAccountCopyWith<$Res> {
  factory $LocalAccountCopyWith(
          LocalAccount value, $Res Function(LocalAccount) then) =
      _$LocalAccountCopyWithImpl<$Res, LocalAccount>;
  @useResult
  $Res call(
      {IdentityMaster identityMaster,
      @Uint8ListJsonConverter() Uint8List identitySecretKeyBytes,
      EncryptionKeyType encryptionKeyType,
      bool biometricsEnabled,
      bool hiddenAccount});

  $IdentityMasterCopyWith<$Res> get identityMaster;
}

/// @nodoc
class _$LocalAccountCopyWithImpl<$Res, $Val extends LocalAccount>
    implements $LocalAccountCopyWith<$Res> {
  _$LocalAccountCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? identityMaster = null,
    Object? identitySecretKeyBytes = null,
    Object? encryptionKeyType = null,
    Object? biometricsEnabled = null,
    Object? hiddenAccount = null,
  }) {
    return _then(_value.copyWith(
      identityMaster: null == identityMaster
          ? _value.identityMaster
          : identityMaster // ignore: cast_nullable_to_non_nullable
              as IdentityMaster,
      identitySecretKeyBytes: null == identitySecretKeyBytes
          ? _value.identitySecretKeyBytes
          : identitySecretKeyBytes // ignore: cast_nullable_to_non_nullable
              as Uint8List,
      encryptionKeyType: null == encryptionKeyType
          ? _value.encryptionKeyType
          : encryptionKeyType // ignore: cast_nullable_to_non_nullable
              as EncryptionKeyType,
      biometricsEnabled: null == biometricsEnabled
          ? _value.biometricsEnabled
          : biometricsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      hiddenAccount: null == hiddenAccount
          ? _value.hiddenAccount
          : hiddenAccount // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $IdentityMasterCopyWith<$Res> get identityMaster {
    return $IdentityMasterCopyWith<$Res>(_value.identityMaster, (value) {
      return _then(_value.copyWith(identityMaster: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_LocalAccountCopyWith<$Res>
    implements $LocalAccountCopyWith<$Res> {
  factory _$$_LocalAccountCopyWith(
          _$_LocalAccount value, $Res Function(_$_LocalAccount) then) =
      __$$_LocalAccountCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {IdentityMaster identityMaster,
      @Uint8ListJsonConverter() Uint8List identitySecretKeyBytes,
      EncryptionKeyType encryptionKeyType,
      bool biometricsEnabled,
      bool hiddenAccount});

  @override
  $IdentityMasterCopyWith<$Res> get identityMaster;
}

/// @nodoc
class __$$_LocalAccountCopyWithImpl<$Res>
    extends _$LocalAccountCopyWithImpl<$Res, _$_LocalAccount>
    implements _$$_LocalAccountCopyWith<$Res> {
  __$$_LocalAccountCopyWithImpl(
      _$_LocalAccount _value, $Res Function(_$_LocalAccount) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? identityMaster = null,
    Object? identitySecretKeyBytes = null,
    Object? encryptionKeyType = null,
    Object? biometricsEnabled = null,
    Object? hiddenAccount = null,
  }) {
    return _then(_$_LocalAccount(
      identityMaster: null == identityMaster
          ? _value.identityMaster
          : identityMaster // ignore: cast_nullable_to_non_nullable
              as IdentityMaster,
      identitySecretKeyBytes: null == identitySecretKeyBytes
          ? _value.identitySecretKeyBytes
          : identitySecretKeyBytes // ignore: cast_nullable_to_non_nullable
              as Uint8List,
      encryptionKeyType: null == encryptionKeyType
          ? _value.encryptionKeyType
          : encryptionKeyType // ignore: cast_nullable_to_non_nullable
              as EncryptionKeyType,
      biometricsEnabled: null == biometricsEnabled
          ? _value.biometricsEnabled
          : biometricsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      hiddenAccount: null == hiddenAccount
          ? _value.hiddenAccount
          : hiddenAccount // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_LocalAccount implements _LocalAccount {
  const _$_LocalAccount(
      {required this.identityMaster,
      @Uint8ListJsonConverter() required this.identitySecretKeyBytes,
      required this.encryptionKeyType,
      required this.biometricsEnabled,
      required this.hiddenAccount});

  factory _$_LocalAccount.fromJson(Map<String, dynamic> json) =>
      _$$_LocalAccountFromJson(json);

// The master key record for the account, containing the identityPublicKey
  @override
  final IdentityMaster identityMaster;
// The encrypted identity secret that goes with the identityPublicKey
  @override
  @Uint8ListJsonConverter()
  final Uint8List identitySecretKeyBytes;
// The kind of encryption input used on the account
  @override
  final EncryptionKeyType encryptionKeyType;
// If account is not hidden, password can be retrieved via
  @override
  final bool biometricsEnabled;
// Keep account hidden unless account password is entered
// (tries all hidden accounts with auth method (no biometrics))
  @override
  final bool hiddenAccount;

  @override
  String toString() {
    return 'LocalAccount(identityMaster: $identityMaster, identitySecretKeyBytes: $identitySecretKeyBytes, encryptionKeyType: $encryptionKeyType, biometricsEnabled: $biometricsEnabled, hiddenAccount: $hiddenAccount)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_LocalAccount &&
            (identical(other.identityMaster, identityMaster) ||
                other.identityMaster == identityMaster) &&
            const DeepCollectionEquality()
                .equals(other.identitySecretKeyBytes, identitySecretKeyBytes) &&
            (identical(other.encryptionKeyType, encryptionKeyType) ||
                other.encryptionKeyType == encryptionKeyType) &&
            (identical(other.biometricsEnabled, biometricsEnabled) ||
                other.biometricsEnabled == biometricsEnabled) &&
            (identical(other.hiddenAccount, hiddenAccount) ||
                other.hiddenAccount == hiddenAccount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      identityMaster,
      const DeepCollectionEquality().hash(identitySecretKeyBytes),
      encryptionKeyType,
      biometricsEnabled,
      hiddenAccount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_LocalAccountCopyWith<_$_LocalAccount> get copyWith =>
      __$$_LocalAccountCopyWithImpl<_$_LocalAccount>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_LocalAccountToJson(
      this,
    );
  }
}

abstract class _LocalAccount implements LocalAccount {
  const factory _LocalAccount(
      {required final IdentityMaster identityMaster,
      @Uint8ListJsonConverter() required final Uint8List identitySecretKeyBytes,
      required final EncryptionKeyType encryptionKeyType,
      required final bool biometricsEnabled,
      required final bool hiddenAccount}) = _$_LocalAccount;

  factory _LocalAccount.fromJson(Map<String, dynamic> json) =
      _$_LocalAccount.fromJson;

  @override // The master key record for the account, containing the identityPublicKey
  IdentityMaster get identityMaster;
  @override // The encrypted identity secret that goes with the identityPublicKey
  @Uint8ListJsonConverter()
  Uint8List get identitySecretKeyBytes;
  @override // The kind of encryption input used on the account
  EncryptionKeyType get encryptionKeyType;
  @override // If account is not hidden, password can be retrieved via
  bool get biometricsEnabled;
  @override // Keep account hidden unless account password is entered
// (tries all hidden accounts with auth method (no biometrics))
  bool get hiddenAccount;
  @override
  @JsonKey(ignore: true)
  _$$_LocalAccountCopyWith<_$_LocalAccount> get copyWith =>
      throw _privateConstructorUsedError;
}
