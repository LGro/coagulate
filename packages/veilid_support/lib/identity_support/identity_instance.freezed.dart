// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'identity_instance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$IdentityInstance {
// Private DHT record storing identity account mapping
  TypedKey get recordKey; // Public key of identity instance
  PublicKey get publicKey; // Secret key of identity instance
// Encrypted with appended salt, key is DeriveSharedSecret(
//    password = SuperIdentity.secret,
//    salt = publicKey)
// Used to recover accounts without generating a new instance
  @Uint8ListJsonConverter()
  Uint8List
      get encryptedSecretKey; // Signature of SuperInstance recordKey and SuperInstance publicKey
// by publicKey
  Signature
      get superSignature; // Signature of recordKey, publicKey, encryptedSecretKey, and superSignature
// by SuperIdentity publicKey
  Signature get signature;

  /// Create a copy of IdentityInstance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $IdentityInstanceCopyWith<IdentityInstance> get copyWith =>
      _$IdentityInstanceCopyWithImpl<IdentityInstance>(
          this as IdentityInstance, _$identity);

  /// Serializes this IdentityInstance to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is IdentityInstance &&
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

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      recordKey,
      publicKey,
      const DeepCollectionEquality().hash(encryptedSecretKey),
      superSignature,
      signature);

  @override
  String toString() {
    return 'IdentityInstance(recordKey: $recordKey, publicKey: $publicKey, encryptedSecretKey: $encryptedSecretKey, superSignature: $superSignature, signature: $signature)';
  }
}

/// @nodoc
abstract mixin class $IdentityInstanceCopyWith<$Res> {
  factory $IdentityInstanceCopyWith(
          IdentityInstance value, $Res Function(IdentityInstance) _then) =
      _$IdentityInstanceCopyWithImpl;
  @useResult
  $Res call(
      {Typed<FixedEncodedString43> recordKey,
      FixedEncodedString43 publicKey,
      @Uint8ListJsonConverter() Uint8List encryptedSecretKey,
      FixedEncodedString86 superSignature,
      FixedEncodedString86 signature});
}

/// @nodoc
class _$IdentityInstanceCopyWithImpl<$Res>
    implements $IdentityInstanceCopyWith<$Res> {
  _$IdentityInstanceCopyWithImpl(this._self, this._then);

  final IdentityInstance _self;
  final $Res Function(IdentityInstance) _then;

  /// Create a copy of IdentityInstance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recordKey = null,
    Object? publicKey = null,
    Object? encryptedSecretKey = null,
    Object? superSignature = null,
    Object? signature = null,
  }) {
    return _then(_self.copyWith(
      recordKey: null == recordKey
          ? _self.recordKey!
          : recordKey // ignore: cast_nullable_to_non_nullable
              as Typed<FixedEncodedString43>,
      publicKey: null == publicKey
          ? _self.publicKey!
          : publicKey // ignore: cast_nullable_to_non_nullable
              as FixedEncodedString43,
      encryptedSecretKey: null == encryptedSecretKey
          ? _self.encryptedSecretKey
          : encryptedSecretKey // ignore: cast_nullable_to_non_nullable
              as Uint8List,
      superSignature: null == superSignature
          ? _self.superSignature!
          : superSignature // ignore: cast_nullable_to_non_nullable
              as FixedEncodedString86,
      signature: null == signature
          ? _self.signature!
          : signature // ignore: cast_nullable_to_non_nullable
              as FixedEncodedString86,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _IdentityInstance extends IdentityInstance {
  const _IdentityInstance(
      {required this.recordKey,
      required this.publicKey,
      @Uint8ListJsonConverter() required this.encryptedSecretKey,
      required this.superSignature,
      required this.signature})
      : super._();
  factory _IdentityInstance.fromJson(Map<String, dynamic> json) =>
      _$IdentityInstanceFromJson(json);

// Private DHT record storing identity account mapping
  @override
  final Typed<FixedEncodedString43> recordKey;
// Public key of identity instance
  @override
  final FixedEncodedString43 publicKey;
// Secret key of identity instance
// Encrypted with appended salt, key is DeriveSharedSecret(
//    password = SuperIdentity.secret,
//    salt = publicKey)
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

  /// Create a copy of IdentityInstance
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$IdentityInstanceCopyWith<_IdentityInstance> get copyWith =>
      __$IdentityInstanceCopyWithImpl<_IdentityInstance>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$IdentityInstanceToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _IdentityInstance &&
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

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      recordKey,
      publicKey,
      const DeepCollectionEquality().hash(encryptedSecretKey),
      superSignature,
      signature);

  @override
  String toString() {
    return 'IdentityInstance(recordKey: $recordKey, publicKey: $publicKey, encryptedSecretKey: $encryptedSecretKey, superSignature: $superSignature, signature: $signature)';
  }
}

/// @nodoc
abstract mixin class _$IdentityInstanceCopyWith<$Res>
    implements $IdentityInstanceCopyWith<$Res> {
  factory _$IdentityInstanceCopyWith(
          _IdentityInstance value, $Res Function(_IdentityInstance) _then) =
      __$IdentityInstanceCopyWithImpl;
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
class __$IdentityInstanceCopyWithImpl<$Res>
    implements _$IdentityInstanceCopyWith<$Res> {
  __$IdentityInstanceCopyWithImpl(this._self, this._then);

  final _IdentityInstance _self;
  final $Res Function(_IdentityInstance) _then;

  /// Create a copy of IdentityInstance
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? recordKey = null,
    Object? publicKey = null,
    Object? encryptedSecretKey = null,
    Object? superSignature = null,
    Object? signature = null,
  }) {
    return _then(_IdentityInstance(
      recordKey: null == recordKey
          ? _self.recordKey
          : recordKey // ignore: cast_nullable_to_non_nullable
              as Typed<FixedEncodedString43>,
      publicKey: null == publicKey
          ? _self.publicKey
          : publicKey // ignore: cast_nullable_to_non_nullable
              as FixedEncodedString43,
      encryptedSecretKey: null == encryptedSecretKey
          ? _self.encryptedSecretKey
          : encryptedSecretKey // ignore: cast_nullable_to_non_nullable
              as Uint8List,
      superSignature: null == superSignature
          ? _self.superSignature
          : superSignature // ignore: cast_nullable_to_non_nullable
              as FixedEncodedString86,
      signature: null == signature
          ? _self.signature
          : signature // ignore: cast_nullable_to_non_nullable
              as FixedEncodedString86,
    ));
  }
}

// dart format on
