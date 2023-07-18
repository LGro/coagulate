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

AccountRecordInfo _$AccountRecordInfoFromJson(Map<String, dynamic> json) {
  return _AccountRecordInfo.fromJson(json);
}

/// @nodoc
mixin _$AccountRecordInfo {
// Top level account keys and secrets
  Typed<FixedEncodedString43> get key => throw _privateConstructorUsedError;
  KeyPair get owner => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AccountRecordInfoCopyWith<AccountRecordInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AccountRecordInfoCopyWith<$Res> {
  factory $AccountRecordInfoCopyWith(
          AccountRecordInfo value, $Res Function(AccountRecordInfo) then) =
      _$AccountRecordInfoCopyWithImpl<$Res, AccountRecordInfo>;
  @useResult
  $Res call({Typed<FixedEncodedString43> key, KeyPair owner});
}

/// @nodoc
class _$AccountRecordInfoCopyWithImpl<$Res, $Val extends AccountRecordInfo>
    implements $AccountRecordInfoCopyWith<$Res> {
  _$AccountRecordInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? owner = null,
  }) {
    return _then(_value.copyWith(
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as Typed<FixedEncodedString43>,
      owner: null == owner
          ? _value.owner
          : owner // ignore: cast_nullable_to_non_nullable
              as KeyPair,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_AccountRecordInfoCopyWith<$Res>
    implements $AccountRecordInfoCopyWith<$Res> {
  factory _$$_AccountRecordInfoCopyWith(_$_AccountRecordInfo value,
          $Res Function(_$_AccountRecordInfo) then) =
      __$$_AccountRecordInfoCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Typed<FixedEncodedString43> key, KeyPair owner});
}

/// @nodoc
class __$$_AccountRecordInfoCopyWithImpl<$Res>
    extends _$AccountRecordInfoCopyWithImpl<$Res, _$_AccountRecordInfo>
    implements _$$_AccountRecordInfoCopyWith<$Res> {
  __$$_AccountRecordInfoCopyWithImpl(
      _$_AccountRecordInfo _value, $Res Function(_$_AccountRecordInfo) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? owner = null,
  }) {
    return _then(_$_AccountRecordInfo(
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as Typed<FixedEncodedString43>,
      owner: null == owner
          ? _value.owner
          : owner // ignore: cast_nullable_to_non_nullable
              as KeyPair,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_AccountRecordInfo implements _AccountRecordInfo {
  const _$_AccountRecordInfo({required this.key, required this.owner});

  factory _$_AccountRecordInfo.fromJson(Map<String, dynamic> json) =>
      _$$_AccountRecordInfoFromJson(json);

// Top level account keys and secrets
  @override
  final Typed<FixedEncodedString43> key;
  @override
  final KeyPair owner;

  @override
  String toString() {
    return 'AccountRecordInfo(key: $key, owner: $owner)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_AccountRecordInfo &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.owner, owner) || other.owner == owner));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, key, owner);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_AccountRecordInfoCopyWith<_$_AccountRecordInfo> get copyWith =>
      __$$_AccountRecordInfoCopyWithImpl<_$_AccountRecordInfo>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_AccountRecordInfoToJson(
      this,
    );
  }
}

abstract class _AccountRecordInfo implements AccountRecordInfo {
  const factory _AccountRecordInfo(
      {required final Typed<FixedEncodedString43> key,
      required final KeyPair owner}) = _$_AccountRecordInfo;

  factory _AccountRecordInfo.fromJson(Map<String, dynamic> json) =
      _$_AccountRecordInfo.fromJson;

  @override // Top level account keys and secrets
  Typed<FixedEncodedString43> get key;
  @override
  KeyPair get owner;
  @override
  @JsonKey(ignore: true)
  _$$_AccountRecordInfoCopyWith<_$_AccountRecordInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

Identity _$IdentityFromJson(Map<String, dynamic> json) {
  return _Identity.fromJson(json);
}

/// @nodoc
mixin _$Identity {
// Top level account keys and secrets
  IMap<String, ISet<AccountRecordInfo>> get accountRecords =>
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
  $Res call({IMap<String, ISet<AccountRecordInfo>> accountRecords});
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
    Object? accountRecords = null,
  }) {
    return _then(_value.copyWith(
      accountRecords: null == accountRecords
          ? _value.accountRecords
          : accountRecords // ignore: cast_nullable_to_non_nullable
              as IMap<String, ISet<AccountRecordInfo>>,
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
  $Res call({IMap<String, ISet<AccountRecordInfo>> accountRecords});
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
    Object? accountRecords = null,
  }) {
    return _then(_$_Identity(
      accountRecords: null == accountRecords
          ? _value.accountRecords
          : accountRecords // ignore: cast_nullable_to_non_nullable
              as IMap<String, ISet<AccountRecordInfo>>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Identity implements _Identity {
  const _$_Identity({required this.accountRecords});

  factory _$_Identity.fromJson(Map<String, dynamic> json) =>
      _$$_IdentityFromJson(json);

// Top level account keys and secrets
  @override
  final IMap<String, ISet<AccountRecordInfo>> accountRecords;

  @override
  String toString() {
    return 'Identity(accountRecords: $accountRecords)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Identity &&
            (identical(other.accountRecords, accountRecords) ||
                other.accountRecords == accountRecords));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, accountRecords);

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
      {required final IMap<String, ISet<AccountRecordInfo>>
          accountRecords}) = _$_Identity;

  factory _Identity.fromJson(Map<String, dynamic> json) = _$_Identity.fromJson;

  @override // Top level account keys and secrets
  IMap<String, ISet<AccountRecordInfo>> get accountRecords;
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
