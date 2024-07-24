// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'identity_instance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

IdentityInstance _$IdentityInstanceFromJson(Map<String, dynamic> json) {
  return _IdentityInstance.fromJson(json);
}

/// @nodoc
mixin _$IdentityInstance {
// Private DHT record storing identity account mapping
  Typed<FixedEncodedString43> get recordKey =>
      throw _privateConstructorUsedError; // Public key of identity instance
  FixedEncodedString43 get publicKey =>
      throw _privateConstructorUsedError; // Secret key of identity instance
// Encrypted with DH(publicKey, SuperIdentity.secret) with appended salt
// Used to recover accounts without generating a new instance
  @Uint8ListJsonConverter()
  Uint8List get encryptedSecretKey =>
      throw _privateConstructorUsedError; // Signature of SuperInstance recordKey and SuperInstance publicKey
// by publicKey
  FixedEncodedString86 get superSignature =>
      throw _privateConstructorUsedError; // Signature of recordKey, publicKey, encryptedSecretKey, and superSignature
// by SuperIdentity publicKey
  FixedEncodedString86 get signature => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $IdentityInstanceCopyWith<IdentityInstance> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IdentityInstanceCopyWith<$Res> {
  factory $IdentityInstanceCopyWith(
          IdentityInstance value, $Res Function(IdentityInstance) then) =
      _$IdentityInstanceCopyWithImpl<$Res, IdentityInstance>;
  @useResult
  $Res call(
      {Typed<FixedEncodedString43> recordKey,
      FixedEncodedString43 publicKey,
      @Uint8ListJsonConverter() Uint8List encryptedSecretKey,
      FixedEncodedString86 superSignature,
      FixedEncodedString86 signature});
}

/// @nodoc
class _$IdentityInstanceCopyWithImpl<$Res, $Val extends IdentityInstance>
    implements $IdentityInstanceCopyWith<$Res> {
  _$IdentityInstanceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recordKey = null,
    Object? publicKey = null,
    Object? encryptedSecretKey = null,
    Object? superSignature = null,
    Object? signature = null,
  }) {
    return _then(_value.copyWith(
      recordKey: null == recordKey
          ? _value.recordKey
          : recordKey // ignore: cast_nullable_to_non_nullable
              as Typed<FixedEncodedString43>,
      publicKey: null == publicKey
          ? _value.publicKey
          : publicKey // ignore: cast_nullable_to_non_nullable
              as FixedEncodedString43,
      encryptedSecretKey: null == encryptedSecretKey
          ? _value.encryptedSecretKey
          : encryptedSecretKey // ignore: cast_nullable_to_non_nullable
              as Uint8List,
      superSignature: null == superSignature
          ? _value.superSignature
          : superSignature // ignore: cast_nullable_to_non_nullable
              as FixedEncodedString86,
      signature: null == signature
          ? _value.signature
          : signature // ignore: cast_nullable_to_non_nullable
              as FixedEncodedString86,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$IdentityInstanceImplCopyWith<$Res>
    implements $IdentityInstanceCopyWith<$Res> {
  factory _$$IdentityInstanceImplCopyWith(_$IdentityInstanceImpl value,
          $Res Function(_$IdentityInstanceImpl) then) =
      __$$IdentityInstanceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Typed<FixedEncodedString43> recordKey,
      FixedEncodedString43 publicKey,
      @Uint8ListJsonConverter() Uint8List encryptedSecretKey,
      FixedEncodedString86 superSignature,
      FixedEncodedString86 signature});
}

/// @nodoc
class __$$IdentityInstanceImplCopyWithImpl<$Res>
    extends _$IdentityInstanceCopyWithImpl<$Res, _$IdentityInstanceImpl>
    implements _$$IdentityInstanceImplCopyWith<$Res> {
  __$$IdentityInstanceImplCopyWithImpl(_$IdentityInstanceImpl _value,
      $Res Function(_$IdentityInstanceImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recordKey = null,
    Object? publicKey = null,
    Object? encryptedSecretKey = null,
    Object? superSignature = null,
    Object? signature = null,
  }) {
    return _then(_$IdentityInstanceImpl(
      recordKey: null == recordKey
          ? _value.recordKey
          : recordKey // ignore: cast_nullable_to_non_nullable
              as Typed<FixedEncodedString43>,
      publicKey: null == publicKey
          ? _value.publicKey
          : publicKey // ignore: cast_nullable_to_non_nullable
              as FixedEncodedString43,
      encryptedSecretKey: null == encryptedSecretKey
          ? _value.encryptedSecretKey
          : encryptedSecretKey // ignore: cast_nullable_to_non_nullable
              as Uint8List,
      superSignature: null == superSignature
          ? _value.superSignature
          : superSignature // ignore: cast_nullable_to_non_nullable
              as FixedEncodedString86,
      signature: null == signature
          ? _value.signature
          : signature // ignore: cast_nullable_to_non_nullable
              as FixedEncodedString86,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$IdentityInstanceImpl extends _IdentityInstance {
  const _$IdentityInstanceImpl(
      {required this.recordKey,
      required this.publicKey,
      @Uint8ListJsonConverter() required this.encryptedSecretKey,
      required this.superSignature,
      required this.signature})
      : super._();

  factory _$IdentityInstanceImpl.fromJson(Map<String, dynamic> json) =>
      _$$IdentityInstanceImplFromJson(json);

// Private DHT record storing identity account mapping
  @override
  final Typed<FixedEncodedString43> recordKey;
// Public key of identity instance
  @override
  final FixedEncodedString43 publicKey;
// Secret key of identity instance
// Encrypted with DH(publicKey, SuperIdentity.secret) with appended salt
// Used to recover accounts without generating a new instance
  @override
  @Uint8ListJsonConverter()
  final Uint8List encryptedSecretKey;
// Signature of SuperInstance recordKey and SuperInstance publicKey
// by publicKey
  @override
  final FixedEncodedString86 superSignature;
// Signature of recordKey, publicKey, encryptedSecretKey, and superSignature
// by SuperIdentity publicKey
  @override
  final FixedEncodedString86 signature;

  @override
  String toString() {
    return 'IdentityInstance(recordKey: $recordKey, publicKey: $publicKey, encryptedSecretKey: $encryptedSecretKey, superSignature: $superSignature, signature: $signature)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IdentityInstanceImpl &&
            (identical(other.recordKey, recordKey) ||
                other.recordKey == recordKey) &&
            (identical(other.publicKey, publicKey) ||
                other.publicKey == publicKey) &&
            const DeepCollectionEquality()
                .equals(other.encryptedSecretKey, encryptedSecretKey) &&
            (identical(other.superSignature, superSignature) ||
                other.superSignature == superSignature) &&
            (identical(other.signature, signature) ||
                other.signature == signature));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      recordKey,
      publicKey,
      const DeepCollectionEquality().hash(encryptedSecretKey),
      superSignature,
      signature);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$IdentityInstanceImplCopyWith<_$IdentityInstanceImpl> get copyWith =>
      __$$IdentityInstanceImplCopyWithImpl<_$IdentityInstanceImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IdentityInstanceImplToJson(
      this,
    );
  }
}

abstract class _IdentityInstance extends IdentityInstance {
  const factory _IdentityInstance(
      {required final Typed<FixedEncodedString43> recordKey,
      required final FixedEncodedString43 publicKey,
      @Uint8ListJsonConverter() required final Uint8List encryptedSecretKey,
      required final FixedEncodedString86 superSignature,
      required final FixedEncodedString86 signature}) = _$IdentityInstanceImpl;
  const _IdentityInstance._() : super._();

  factory _IdentityInstance.fromJson(Map<String, dynamic> json) =
      _$IdentityInstanceImpl.fromJson;

  @override // Private DHT record storing identity account mapping
  Typed<FixedEncodedString43> get recordKey;
  @override // Public key of identity instance
  FixedEncodedString43 get publicKey;
  @override // Secret key of identity instance
// Encrypted with DH(publicKey, SuperIdentity.secret) with appended salt
// Used to recover accounts without generating a new instance
  @Uint8ListJsonConverter()
  Uint8List get encryptedSecretKey;
  @override // Signature of SuperInstance recordKey and SuperInstance publicKey
// by publicKey
  FixedEncodedString86 get superSignature;
  @override // Signature of recordKey, publicKey, encryptedSecretKey, and superSignature
// by SuperIdentity publicKey
  FixedEncodedString86 get signature;
  @override
  @JsonKey(ignore: true)
  _$$IdentityInstanceImplCopyWith<_$IdentityInstanceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
