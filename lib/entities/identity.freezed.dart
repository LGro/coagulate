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
  Typed<FixedEncodedString43> get identityPublicKey =>
      throw _privateConstructorUsedError;
  Typed<FixedEncodedString43> get masterPublicKey =>
      throw _privateConstructorUsedError;
  FixedEncodedString86 get identitySignature =>
      throw _privateConstructorUsedError;
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
      {Typed<FixedEncodedString43> identityPublicKey,
      Typed<FixedEncodedString43> masterPublicKey,
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
    Object? identityPublicKey = null,
    Object? masterPublicKey = null,
    Object? identitySignature = null,
    Object? masterSignature = null,
  }) {
    return _then(_value.copyWith(
      identityPublicKey: null == identityPublicKey
          ? _value.identityPublicKey
          : identityPublicKey // ignore: cast_nullable_to_non_nullable
              as Typed<FixedEncodedString43>,
      masterPublicKey: null == masterPublicKey
          ? _value.masterPublicKey
          : masterPublicKey // ignore: cast_nullable_to_non_nullable
              as Typed<FixedEncodedString43>,
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
      {Typed<FixedEncodedString43> identityPublicKey,
      Typed<FixedEncodedString43> masterPublicKey,
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
    Object? identityPublicKey = null,
    Object? masterPublicKey = null,
    Object? identitySignature = null,
    Object? masterSignature = null,
  }) {
    return _then(_$_IdentityMaster(
      identityPublicKey: null == identityPublicKey
          ? _value.identityPublicKey
          : identityPublicKey // ignore: cast_nullable_to_non_nullable
              as Typed<FixedEncodedString43>,
      masterPublicKey: null == masterPublicKey
          ? _value.masterPublicKey
          : masterPublicKey // ignore: cast_nullable_to_non_nullable
              as Typed<FixedEncodedString43>,
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
      {required this.identityPublicKey,
      required this.masterPublicKey,
      required this.identitySignature,
      required this.masterSignature});

  factory _$_IdentityMaster.fromJson(Map<String, dynamic> json) =>
      _$$_IdentityMasterFromJson(json);

  @override
  final Typed<FixedEncodedString43> identityPublicKey;
  @override
  final Typed<FixedEncodedString43> masterPublicKey;
  @override
  final FixedEncodedString86 identitySignature;
  @override
  final FixedEncodedString86 masterSignature;

  @override
  String toString() {
    return 'IdentityMaster(identityPublicKey: $identityPublicKey, masterPublicKey: $masterPublicKey, identitySignature: $identitySignature, masterSignature: $masterSignature)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_IdentityMaster &&
            (identical(other.identityPublicKey, identityPublicKey) ||
                other.identityPublicKey == identityPublicKey) &&
            (identical(other.masterPublicKey, masterPublicKey) ||
                other.masterPublicKey == masterPublicKey) &&
            (identical(other.identitySignature, identitySignature) ||
                other.identitySignature == identitySignature) &&
            (identical(other.masterSignature, masterSignature) ||
                other.masterSignature == masterSignature));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, identityPublicKey,
      masterPublicKey, identitySignature, masterSignature);

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
      {required final Typed<FixedEncodedString43> identityPublicKey,
      required final Typed<FixedEncodedString43> masterPublicKey,
      required final FixedEncodedString86 identitySignature,
      required final FixedEncodedString86 masterSignature}) = _$_IdentityMaster;

  factory _IdentityMaster.fromJson(Map<String, dynamic> json) =
      _$_IdentityMaster.fromJson;

  @override
  Typed<FixedEncodedString43> get identityPublicKey;
  @override
  Typed<FixedEncodedString43> get masterPublicKey;
  @override
  FixedEncodedString86 get identitySignature;
  @override
  FixedEncodedString86 get masterSignature;
  @override
  @JsonKey(ignore: true)
  _$$_IdentityMasterCopyWith<_$_IdentityMaster> get copyWith =>
      throw _privateConstructorUsedError;
}
