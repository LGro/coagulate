// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'identity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

AccountOwnerInfo _$AccountOwnerInfoFromJson(Map<String, dynamic> json) {
  return _AccountOwnerInfo.fromJson(json);
}

/// @nodoc
mixin _$AccountOwnerInfo {
// Top level account keys and secrets
  Map<String, TypedKeyPair> get accountKeyPairs =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AccountOwnerInfoCopyWith<AccountOwnerInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AccountOwnerInfoCopyWith<$Res> {
  factory $AccountOwnerInfoCopyWith(
          AccountOwnerInfo value, $Res Function(AccountOwnerInfo) then) =
      _$AccountOwnerInfoCopyWithImpl<$Res, AccountOwnerInfo>;
  @useResult
  $Res call({Map<String, TypedKeyPair> accountKeyPairs});
}

/// @nodoc
class _$AccountOwnerInfoCopyWithImpl<$Res, $Val extends AccountOwnerInfo>
    implements $AccountOwnerInfoCopyWith<$Res> {
  _$AccountOwnerInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accountKeyPairs = null,
  }) {
    return _then(_value.copyWith(
      accountKeyPairs: null == accountKeyPairs
          ? _value.accountKeyPairs
          : accountKeyPairs // ignore: cast_nullable_to_non_nullable
              as Map<String, TypedKeyPair>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_AccountOwnerInfoCopyWith<$Res>
    implements $AccountOwnerInfoCopyWith<$Res> {
  factory _$$_AccountOwnerInfoCopyWith(
          _$_AccountOwnerInfo value, $Res Function(_$_AccountOwnerInfo) then) =
      __$$_AccountOwnerInfoCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Map<String, TypedKeyPair> accountKeyPairs});
}

/// @nodoc
class __$$_AccountOwnerInfoCopyWithImpl<$Res>
    extends _$AccountOwnerInfoCopyWithImpl<$Res, _$_AccountOwnerInfo>
    implements _$$_AccountOwnerInfoCopyWith<$Res> {
  __$$_AccountOwnerInfoCopyWithImpl(
      _$_AccountOwnerInfo _value, $Res Function(_$_AccountOwnerInfo) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accountKeyPairs = null,
  }) {
    return _then(_$_AccountOwnerInfo(
      accountKeyPairs: null == accountKeyPairs
          ? _value._accountKeyPairs
          : accountKeyPairs // ignore: cast_nullable_to_non_nullable
              as Map<String, TypedKeyPair>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_AccountOwnerInfo implements _AccountOwnerInfo {
  const _$_AccountOwnerInfo(
      {required final Map<String, TypedKeyPair> accountKeyPairs})
      : _accountKeyPairs = accountKeyPairs;

  factory _$_AccountOwnerInfo.fromJson(Map<String, dynamic> json) =>
      _$$_AccountOwnerInfoFromJson(json);

// Top level account keys and secrets
  final Map<String, TypedKeyPair> _accountKeyPairs;
// Top level account keys and secrets
  @override
  Map<String, TypedKeyPair> get accountKeyPairs {
    if (_accountKeyPairs is EqualUnmodifiableMapView) return _accountKeyPairs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_accountKeyPairs);
  }

  @override
  String toString() {
    return 'AccountOwnerInfo(accountKeyPairs: $accountKeyPairs)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_AccountOwnerInfo &&
            const DeepCollectionEquality()
                .equals(other._accountKeyPairs, _accountKeyPairs));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_accountKeyPairs));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_AccountOwnerInfoCopyWith<_$_AccountOwnerInfo> get copyWith =>
      __$$_AccountOwnerInfoCopyWithImpl<_$_AccountOwnerInfo>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_AccountOwnerInfoToJson(
      this,
    );
  }
}

abstract class _AccountOwnerInfo implements AccountOwnerInfo {
  const factory _AccountOwnerInfo(
          {required final Map<String, TypedKeyPair> accountKeyPairs}) =
      _$_AccountOwnerInfo;

  factory _AccountOwnerInfo.fromJson(Map<String, dynamic> json) =
      _$_AccountOwnerInfo.fromJson;

  @override // Top level account keys and secrets
  Map<String, TypedKeyPair> get accountKeyPairs;
  @override
  @JsonKey(ignore: true)
  _$$_AccountOwnerInfoCopyWith<_$_AccountOwnerInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

Identity _$IdentityFromJson(Map<String, dynamic> json) {
  return _Identity.fromJson(json);
}

/// @nodoc
mixin _$Identity {
// Top level account keys and secrets
  Map<String, TypedKeyPair> get accountKeyPairs =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $IdentityCopyWith<Identity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IdentityCopyWith<$Res> {
  factory $IdentityCopyWith(Identity value, $Res Function(Identity) then) =
      _$IdentityCopyWithImpl<$Res, Identity>;
  @useResult
  $Res call({Map<String, TypedKeyPair> accountKeyPairs});
}

/// @nodoc
class _$IdentityCopyWithImpl<$Res, $Val extends Identity>
    implements $IdentityCopyWith<$Res> {
  _$IdentityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accountKeyPairs = null,
  }) {
    return _then(_value.copyWith(
      accountKeyPairs: null == accountKeyPairs
          ? _value.accountKeyPairs
          : accountKeyPairs // ignore: cast_nullable_to_non_nullable
              as Map<String, TypedKeyPair>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_IdentityCopyWith<$Res> implements $IdentityCopyWith<$Res> {
  factory _$$_IdentityCopyWith(
          _$_Identity value, $Res Function(_$_Identity) then) =
      __$$_IdentityCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Map<String, TypedKeyPair> accountKeyPairs});
}

/// @nodoc
class __$$_IdentityCopyWithImpl<$Res>
    extends _$IdentityCopyWithImpl<$Res, _$_Identity>
    implements _$$_IdentityCopyWith<$Res> {
  __$$_IdentityCopyWithImpl(
      _$_Identity _value, $Res Function(_$_Identity) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accountKeyPairs = null,
  }) {
    return _then(_$_Identity(
      accountKeyPairs: null == accountKeyPairs
          ? _value._accountKeyPairs
          : accountKeyPairs // ignore: cast_nullable_to_non_nullable
              as Map<String, TypedKeyPair>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Identity implements _Identity {
  const _$_Identity({required final Map<String, TypedKeyPair> accountKeyPairs})
      : _accountKeyPairs = accountKeyPairs;

  factory _$_Identity.fromJson(Map<String, dynamic> json) =>
      _$$_IdentityFromJson(json);

// Top level account keys and secrets
  final Map<String, TypedKeyPair> _accountKeyPairs;
// Top level account keys and secrets
  @override
  Map<String, TypedKeyPair> get accountKeyPairs {
    if (_accountKeyPairs is EqualUnmodifiableMapView) return _accountKeyPairs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_accountKeyPairs);
  }

  @override
  String toString() {
    return 'Identity(accountKeyPairs: $accountKeyPairs)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Identity &&
            const DeepCollectionEquality()
                .equals(other._accountKeyPairs, _accountKeyPairs));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_accountKeyPairs));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_IdentityCopyWith<_$_Identity> get copyWith =>
      __$$_IdentityCopyWithImpl<_$_Identity>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_IdentityToJson(
      this,
    );
  }
}

abstract class _Identity implements Identity {
  const factory _Identity(
      {required final Map<String, TypedKeyPair> accountKeyPairs}) = _$_Identity;

  factory _Identity.fromJson(Map<String, dynamic> json) = _$_Identity.fromJson;

  @override // Top level account keys and secrets
  Map<String, TypedKeyPair> get accountKeyPairs;
  @override
  @JsonKey(ignore: true)
  _$$_IdentityCopyWith<_$_Identity> get copyWith =>
      throw _privateConstructorUsedError;
}

IdentityMaster _$IdentityMasterFromJson(Map<String, dynamic> json) {
  return _IdentityMaster.fromJson(json);
}

/// @nodoc
mixin _$IdentityMaster {
// Private DHT record storing identity account mapping
  Typed<FixedEncodedString43> get identityRecordKey =>
      throw _privateConstructorUsedError; // Public key of identity
  FixedEncodedString43 get identityPublicKey =>
      throw _privateConstructorUsedError; // Public DHT record storing this structure for account recovery
  Typed<FixedEncodedString43> get masterRecordKey =>
      throw _privateConstructorUsedError; // Public key of master identity used to sign identity keys for recovery
  FixedEncodedString43 get masterPublicKey =>
      throw _privateConstructorUsedError; // Signature of identityRecordKey and identityPublicKey by masterPublicKey
  FixedEncodedString86 get identitySignature =>
      throw _privateConstructorUsedError; // Signature of masterRecordKey and masterPublicKey by identityPublicKey
  FixedEncodedString86 get masterSignature =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $IdentityMasterCopyWith<IdentityMaster> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IdentityMasterCopyWith<$Res> {
  factory $IdentityMasterCopyWith(
          IdentityMaster value, $Res Function(IdentityMaster) then) =
      _$IdentityMasterCopyWithImpl<$Res, IdentityMaster>;
  @useResult
  $Res call(
      {Typed<FixedEncodedString43> identityRecordKey,
      FixedEncodedString43 identityPublicKey,
      Typed<FixedEncodedString43> masterRecordKey,
      FixedEncodedString43 masterPublicKey,
      FixedEncodedString86 identitySignature,
      FixedEncodedString86 masterSignature});
}

/// @nodoc
class _$IdentityMasterCopyWithImpl<$Res, $Val extends IdentityMaster>
    implements $IdentityMasterCopyWith<$Res> {
  _$IdentityMasterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? identityRecordKey = null,
    Object? identityPublicKey = null,
    Object? masterRecordKey = null,
    Object? masterPublicKey = null,
    Object? identitySignature = null,
    Object? masterSignature = null,
  }) {
    return _then(_value.copyWith(
      identityRecordKey: null == identityRecordKey
          ? _value.identityRecordKey
          : identityRecordKey // ignore: cast_nullable_to_non_nullable
              as Typed<FixedEncodedString43>,
      identityPublicKey: null == identityPublicKey
          ? _value.identityPublicKey
          : identityPublicKey // ignore: cast_nullable_to_non_nullable
              as FixedEncodedString43,
      masterRecordKey: null == masterRecordKey
          ? _value.masterRecordKey
          : masterRecordKey // ignore: cast_nullable_to_non_nullable
              as Typed<FixedEncodedString43>,
      masterPublicKey: null == masterPublicKey
          ? _value.masterPublicKey
          : masterPublicKey // ignore: cast_nullable_to_non_nullable
              as FixedEncodedString43,
      identitySignature: null == identitySignature
          ? _value.identitySignature
          : identitySignature // ignore: cast_nullable_to_non_nullable
              as FixedEncodedString86,
      masterSignature: null == masterSignature
          ? _value.masterSignature
          : masterSignature // ignore: cast_nullable_to_non_nullable
              as FixedEncodedString86,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_IdentityMasterCopyWith<$Res>
    implements $IdentityMasterCopyWith<$Res> {
  factory _$$_IdentityMasterCopyWith(
          _$_IdentityMaster value, $Res Function(_$_IdentityMaster) then) =
      __$$_IdentityMasterCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Typed<FixedEncodedString43> identityRecordKey,
      FixedEncodedString43 identityPublicKey,
      Typed<FixedEncodedString43> masterRecordKey,
      FixedEncodedString43 masterPublicKey,
      FixedEncodedString86 identitySignature,
      FixedEncodedString86 masterSignature});
}

/// @nodoc
class __$$_IdentityMasterCopyWithImpl<$Res>
    extends _$IdentityMasterCopyWithImpl<$Res, _$_IdentityMaster>
    implements _$$_IdentityMasterCopyWith<$Res> {
  __$$_IdentityMasterCopyWithImpl(
      _$_IdentityMaster _value, $Res Function(_$_IdentityMaster) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? identityRecordKey = null,
    Object? identityPublicKey = null,
    Object? masterRecordKey = null,
    Object? masterPublicKey = null,
    Object? identitySignature = null,
    Object? masterSignature = null,
  }) {
    return _then(_$_IdentityMaster(
      identityRecordKey: null == identityRecordKey
          ? _value.identityRecordKey
          : identityRecordKey // ignore: cast_nullable_to_non_nullable
              as Typed<FixedEncodedString43>,
      identityPublicKey: null == identityPublicKey
          ? _value.identityPublicKey
          : identityPublicKey // ignore: cast_nullable_to_non_nullable
              as FixedEncodedString43,
      masterRecordKey: null == masterRecordKey
          ? _value.masterRecordKey
          : masterRecordKey // ignore: cast_nullable_to_non_nullable
              as Typed<FixedEncodedString43>,
      masterPublicKey: null == masterPublicKey
          ? _value.masterPublicKey
          : masterPublicKey // ignore: cast_nullable_to_non_nullable
              as FixedEncodedString43,
      identitySignature: null == identitySignature
          ? _value.identitySignature
          : identitySignature // ignore: cast_nullable_to_non_nullable
              as FixedEncodedString86,
      masterSignature: null == masterSignature
          ? _value.masterSignature
          : masterSignature // ignore: cast_nullable_to_non_nullable
              as FixedEncodedString86,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_IdentityMaster implements _IdentityMaster {
  const _$_IdentityMaster(
      {required this.identityRecordKey,
      required this.identityPublicKey,
      required this.masterRecordKey,
      required this.masterPublicKey,
      required this.identitySignature,
      required this.masterSignature});

  factory _$_IdentityMaster.fromJson(Map<String, dynamic> json) =>
      _$$_IdentityMasterFromJson(json);

// Private DHT record storing identity account mapping
  @override
  final Typed<FixedEncodedString43> identityRecordKey;
// Public key of identity
  @override
  final FixedEncodedString43 identityPublicKey;
// Public DHT record storing this structure for account recovery
  @override
  final Typed<FixedEncodedString43> masterRecordKey;
// Public key of master identity used to sign identity keys for recovery
  @override
  final FixedEncodedString43 masterPublicKey;
// Signature of identityRecordKey and identityPublicKey by masterPublicKey
  @override
  final FixedEncodedString86 identitySignature;
// Signature of masterRecordKey and masterPublicKey by identityPublicKey
  @override
  final FixedEncodedString86 masterSignature;

  @override
  String toString() {
    return 'IdentityMaster(identityRecordKey: $identityRecordKey, identityPublicKey: $identityPublicKey, masterRecordKey: $masterRecordKey, masterPublicKey: $masterPublicKey, identitySignature: $identitySignature, masterSignature: $masterSignature)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_IdentityMaster &&
            (identical(other.identityRecordKey, identityRecordKey) ||
                other.identityRecordKey == identityRecordKey) &&
            (identical(other.identityPublicKey, identityPublicKey) ||
                other.identityPublicKey == identityPublicKey) &&
            (identical(other.masterRecordKey, masterRecordKey) ||
                other.masterRecordKey == masterRecordKey) &&
            (identical(other.masterPublicKey, masterPublicKey) ||
                other.masterPublicKey == masterPublicKey) &&
            (identical(other.identitySignature, identitySignature) ||
                other.identitySignature == identitySignature) &&
            (identical(other.masterSignature, masterSignature) ||
                other.masterSignature == masterSignature));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      identityRecordKey,
      identityPublicKey,
      masterRecordKey,
      masterPublicKey,
      identitySignature,
      masterSignature);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_IdentityMasterCopyWith<_$_IdentityMaster> get copyWith =>
      __$$_IdentityMasterCopyWithImpl<_$_IdentityMaster>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_IdentityMasterToJson(
      this,
    );
  }
}

abstract class _IdentityMaster implements IdentityMaster {
  const factory _IdentityMaster(
      {required final Typed<FixedEncodedString43> identityRecordKey,
      required final FixedEncodedString43 identityPublicKey,
      required final Typed<FixedEncodedString43> masterRecordKey,
      required final FixedEncodedString43 masterPublicKey,
      required final FixedEncodedString86 identitySignature,
      required final FixedEncodedString86 masterSignature}) = _$_IdentityMaster;

  factory _IdentityMaster.fromJson(Map<String, dynamic> json) =
      _$_IdentityMaster.fromJson;

  @override // Private DHT record storing identity account mapping
  Typed<FixedEncodedString43> get identityRecordKey;
  @override // Public key of identity
  FixedEncodedString43 get identityPublicKey;
  @override // Public DHT record storing this structure for account recovery
  Typed<FixedEncodedString43> get masterRecordKey;
  @override // Public key of master identity used to sign identity keys for recovery
  FixedEncodedString43 get masterPublicKey;
  @override // Signature of identityRecordKey and identityPublicKey by masterPublicKey
  FixedEncodedString86 get identitySignature;
  @override // Signature of masterRecordKey and masterPublicKey by identityPublicKey
  FixedEncodedString86 get masterSignature;
  @override
  @JsonKey(ignore: true)
  _$$_IdentityMasterCopyWith<_$_IdentityMaster> get copyWith =>
      throw _privateConstructorUsedError;
}
