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
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AccountRecordInfo _$AccountRecordInfoFromJson(Map<String, dynamic> json) {
  return _AccountRecordInfo.fromJson(json);
}

/// @nodoc
mixin _$AccountRecordInfo {
// Top level account keys and secrets
  OwnedDHTRecordPointer get accountRecord => throw _privateConstructorUsedError;

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
  $Res call({OwnedDHTRecordPointer accountRecord});

  $OwnedDHTRecordPointerCopyWith<$Res> get accountRecord;
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
    Object? accountRecord = null,
  }) {
    return _then(_value.copyWith(
      accountRecord: null == accountRecord
          ? _value.accountRecord
          : accountRecord // ignore: cast_nullable_to_non_nullable
              as OwnedDHTRecordPointer,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $OwnedDHTRecordPointerCopyWith<$Res> get accountRecord {
    return $OwnedDHTRecordPointerCopyWith<$Res>(_value.accountRecord, (value) {
      return _then(_value.copyWith(accountRecord: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AccountRecordInfoImplCopyWith<$Res>
    implements $AccountRecordInfoCopyWith<$Res> {
  factory _$$AccountRecordInfoImplCopyWith(_$AccountRecordInfoImpl value,
          $Res Function(_$AccountRecordInfoImpl) then) =
      __$$AccountRecordInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({OwnedDHTRecordPointer accountRecord});

  @override
  $OwnedDHTRecordPointerCopyWith<$Res> get accountRecord;
}

/// @nodoc
class __$$AccountRecordInfoImplCopyWithImpl<$Res>
    extends _$AccountRecordInfoCopyWithImpl<$Res, _$AccountRecordInfoImpl>
    implements _$$AccountRecordInfoImplCopyWith<$Res> {
  __$$AccountRecordInfoImplCopyWithImpl(_$AccountRecordInfoImpl _value,
      $Res Function(_$AccountRecordInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accountRecord = null,
  }) {
    return _then(_$AccountRecordInfoImpl(
      accountRecord: null == accountRecord
          ? _value.accountRecord
          : accountRecord // ignore: cast_nullable_to_non_nullable
              as OwnedDHTRecordPointer,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AccountRecordInfoImpl implements _AccountRecordInfo {
  const _$AccountRecordInfoImpl({required this.accountRecord});

  factory _$AccountRecordInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$AccountRecordInfoImplFromJson(json);

// Top level account keys and secrets
  @override
  final OwnedDHTRecordPointer accountRecord;

  @override
  String toString() {
    return 'AccountRecordInfo(accountRecord: $accountRecord)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AccountRecordInfoImpl &&
            (identical(other.accountRecord, accountRecord) ||
                other.accountRecord == accountRecord));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, accountRecord);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AccountRecordInfoImplCopyWith<_$AccountRecordInfoImpl> get copyWith =>
      __$$AccountRecordInfoImplCopyWithImpl<_$AccountRecordInfoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AccountRecordInfoImplToJson(
      this,
    );
  }
}

abstract class _AccountRecordInfo implements AccountRecordInfo {
  const factory _AccountRecordInfo(
          {required final OwnedDHTRecordPointer accountRecord}) =
      _$AccountRecordInfoImpl;

  factory _AccountRecordInfo.fromJson(Map<String, dynamic> json) =
      _$AccountRecordInfoImpl.fromJson;

  @override // Top level account keys and secrets
  OwnedDHTRecordPointer get accountRecord;
  @override
  @JsonKey(ignore: true)
  _$$AccountRecordInfoImplCopyWith<_$AccountRecordInfoImpl> get copyWith =>
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
abstract class _$$IdentityImplCopyWith<$Res>
    implements $IdentityCopyWith<$Res> {
  factory _$$IdentityImplCopyWith(
          _$IdentityImpl value, $Res Function(_$IdentityImpl) then) =
      __$$IdentityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({IMap<String, ISet<AccountRecordInfo>> accountRecords});
}

/// @nodoc
class __$$IdentityImplCopyWithImpl<$Res>
    extends _$IdentityCopyWithImpl<$Res, _$IdentityImpl>
    implements _$$IdentityImplCopyWith<$Res> {
  __$$IdentityImplCopyWithImpl(
      _$IdentityImpl _value, $Res Function(_$IdentityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accountRecords = null,
  }) {
    return _then(_$IdentityImpl(
      accountRecords: null == accountRecords
          ? _value.accountRecords
          : accountRecords // ignore: cast_nullable_to_non_nullable
              as IMap<String, ISet<AccountRecordInfo>>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$IdentityImpl implements _Identity {
  const _$IdentityImpl({required this.accountRecords});

  factory _$IdentityImpl.fromJson(Map<String, dynamic> json) =>
      _$$IdentityImplFromJson(json);

// Top level account keys and secrets
  @override
  final IMap<String, ISet<AccountRecordInfo>> accountRecords;

  @override
  String toString() {
    return 'Identity(accountRecords: $accountRecords)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IdentityImpl &&
            (identical(other.accountRecords, accountRecords) ||
                other.accountRecords == accountRecords));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, accountRecords);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$IdentityImplCopyWith<_$IdentityImpl> get copyWith =>
      __$$IdentityImplCopyWithImpl<_$IdentityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IdentityImplToJson(
      this,
    );
  }
}

abstract class _Identity implements Identity {
  const factory _Identity(
      {required final IMap<String, ISet<AccountRecordInfo>>
          accountRecords}) = _$IdentityImpl;

  factory _Identity.fromJson(Map<String, dynamic> json) =
      _$IdentityImpl.fromJson;

  @override // Top level account keys and secrets
  IMap<String, ISet<AccountRecordInfo>> get accountRecords;
  @override
  @JsonKey(ignore: true)
  _$$IdentityImplCopyWith<_$IdentityImpl> get copyWith =>
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
abstract class _$$IdentityMasterImplCopyWith<$Res>
    implements $IdentityMasterCopyWith<$Res> {
  factory _$$IdentityMasterImplCopyWith(_$IdentityMasterImpl value,
          $Res Function(_$IdentityMasterImpl) then) =
      __$$IdentityMasterImplCopyWithImpl<$Res>;
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
class __$$IdentityMasterImplCopyWithImpl<$Res>
    extends _$IdentityMasterCopyWithImpl<$Res, _$IdentityMasterImpl>
    implements _$$IdentityMasterImplCopyWith<$Res> {
  __$$IdentityMasterImplCopyWithImpl(
      _$IdentityMasterImpl _value, $Res Function(_$IdentityMasterImpl) _then)
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
    return _then(_$IdentityMasterImpl(
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
class _$IdentityMasterImpl implements _IdentityMaster {
  const _$IdentityMasterImpl(
      {required this.identityRecordKey,
      required this.identityPublicKey,
      required this.masterRecordKey,
      required this.masterPublicKey,
      required this.identitySignature,
      required this.masterSignature});

  factory _$IdentityMasterImpl.fromJson(Map<String, dynamic> json) =>
      _$$IdentityMasterImplFromJson(json);

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
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IdentityMasterImpl &&
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
  _$$IdentityMasterImplCopyWith<_$IdentityMasterImpl> get copyWith =>
      __$$IdentityMasterImplCopyWithImpl<_$IdentityMasterImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IdentityMasterImplToJson(
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
          required final FixedEncodedString86 masterSignature}) =
      _$IdentityMasterImpl;

  factory _IdentityMaster.fromJson(Map<String, dynamic> json) =
      _$IdentityMasterImpl.fromJson;

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
  _$$IdentityMasterImplCopyWith<_$IdentityMasterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
