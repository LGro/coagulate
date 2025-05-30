// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'super_identity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SuperIdentity {
  /// Public DHT record storing this structure for account recovery
  /// changing this can migrate/forward the SuperIdentity to a new DHT record
  /// Instances should not hash this recordKey, rather the actual record
  /// key used to store the superIdentity, as this may change.
  TypedKey get recordKey;

  /// Public key of the SuperIdentity used to sign identity keys for recovery
  /// This must match the owner of the superRecord DHT record and can not be
  /// changed without changing the record
  PublicKey get publicKey;

  /// Current identity instance
  /// The most recently generated identity instance for this SuperIdentity
  IdentityInstance get currentInstance;

  /// Deprecated identity instances
  /// These may be compromised and should not be considered valid for
  /// new signatures, but may be used to validate old signatures
  List<IdentityInstance> get deprecatedInstances;

  /// Deprecated superRecords
  /// These may be compromised and should not be considered valid for
  /// new signatures, but may be used to validate old signatures
  List<TypedKey> get deprecatedSuperRecordKeys;

  /// Signature of recordKey, currentInstance signature,
  /// signatures of deprecatedInstances, and deprecatedSuperRecordKeys
  /// by publicKey
  Signature get signature;

  /// Create a copy of SuperIdentity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SuperIdentityCopyWith<SuperIdentity> get copyWith =>
      _$SuperIdentityCopyWithImpl<SuperIdentity>(
          this as SuperIdentity, _$identity);

  /// Serializes this SuperIdentity to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SuperIdentity &&
            (identical(other.recordKey, recordKey) ||
                other.recordKey == recordKey) &&
            (identical(other.publicKey, publicKey) ||
                other.publicKey == publicKey) &&
            (identical(other.currentInstance, currentInstance) ||
                other.currentInstance == currentInstance) &&
            const DeepCollectionEquality()
                .equals(other.deprecatedInstances, deprecatedInstances) &&
            const DeepCollectionEquality().equals(
                other.deprecatedSuperRecordKeys, deprecatedSuperRecordKeys) &&
            (identical(other.signature, signature) ||
                other.signature == signature));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      recordKey,
      publicKey,
      currentInstance,
      const DeepCollectionEquality().hash(deprecatedInstances),
      const DeepCollectionEquality().hash(deprecatedSuperRecordKeys),
      signature);

  @override
  String toString() {
    return 'SuperIdentity(recordKey: $recordKey, publicKey: $publicKey, currentInstance: $currentInstance, deprecatedInstances: $deprecatedInstances, deprecatedSuperRecordKeys: $deprecatedSuperRecordKeys, signature: $signature)';
  }
}

/// @nodoc
abstract mixin class $SuperIdentityCopyWith<$Res> {
  factory $SuperIdentityCopyWith(
          SuperIdentity value, $Res Function(SuperIdentity) _then) =
      _$SuperIdentityCopyWithImpl;
  @useResult
  $Res call(
      {Typed<FixedEncodedString43> recordKey,
      FixedEncodedString43 publicKey,
      IdentityInstance currentInstance,
      List<IdentityInstance> deprecatedInstances,
      List<Typed<FixedEncodedString43>> deprecatedSuperRecordKeys,
      FixedEncodedString86 signature});

  $IdentityInstanceCopyWith<$Res> get currentInstance;
}

/// @nodoc
class _$SuperIdentityCopyWithImpl<$Res>
    implements $SuperIdentityCopyWith<$Res> {
  _$SuperIdentityCopyWithImpl(this._self, this._then);

  final SuperIdentity _self;
  final $Res Function(SuperIdentity) _then;

  /// Create a copy of SuperIdentity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recordKey = null,
    Object? publicKey = null,
    Object? currentInstance = null,
    Object? deprecatedInstances = null,
    Object? deprecatedSuperRecordKeys = null,
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
      currentInstance: null == currentInstance
          ? _self.currentInstance
          : currentInstance // ignore: cast_nullable_to_non_nullable
              as IdentityInstance,
      deprecatedInstances: null == deprecatedInstances
          ? _self.deprecatedInstances
          : deprecatedInstances // ignore: cast_nullable_to_non_nullable
              as List<IdentityInstance>,
      deprecatedSuperRecordKeys: null == deprecatedSuperRecordKeys
          ? _self.deprecatedSuperRecordKeys!
          : deprecatedSuperRecordKeys // ignore: cast_nullable_to_non_nullable
              as List<Typed<FixedEncodedString43>>,
      signature: null == signature
          ? _self.signature!
          : signature // ignore: cast_nullable_to_non_nullable
              as FixedEncodedString86,
    ));
  }

  /// Create a copy of SuperIdentity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $IdentityInstanceCopyWith<$Res> get currentInstance {
    return $IdentityInstanceCopyWith<$Res>(_self.currentInstance, (value) {
      return _then(_self.copyWith(currentInstance: value));
    });
  }
}

/// @nodoc

@JsonSerializable()
class _SuperIdentity extends SuperIdentity {
  const _SuperIdentity(
      {required this.recordKey,
      required this.publicKey,
      required this.currentInstance,
      required final List<IdentityInstance> deprecatedInstances,
      required final List<Typed<FixedEncodedString43>>
          deprecatedSuperRecordKeys,
      required this.signature})
      : _deprecatedInstances = deprecatedInstances,
        _deprecatedSuperRecordKeys = deprecatedSuperRecordKeys,
        super._();
  factory _SuperIdentity.fromJson(Map<String, dynamic> json) =>
      _$SuperIdentityFromJson(json);

  /// Public DHT record storing this structure for account recovery
  /// changing this can migrate/forward the SuperIdentity to a new DHT record
  /// Instances should not hash this recordKey, rather the actual record
  /// key used to store the superIdentity, as this may change.
  @override
  final Typed<FixedEncodedString43> recordKey;

  /// Public key of the SuperIdentity used to sign identity keys for recovery
  /// This must match the owner of the superRecord DHT record and can not be
  /// changed without changing the record
  @override
  final FixedEncodedString43 publicKey;

  /// Current identity instance
  /// The most recently generated identity instance for this SuperIdentity
  @override
  final IdentityInstance currentInstance;

  /// Deprecated identity instances
  /// These may be compromised and should not be considered valid for
  /// new signatures, but may be used to validate old signatures
  final List<IdentityInstance> _deprecatedInstances;

  /// Deprecated identity instances
  /// These may be compromised and should not be considered valid for
  /// new signatures, but may be used to validate old signatures
  @override
  List<IdentityInstance> get deprecatedInstances {
    if (_deprecatedInstances is EqualUnmodifiableListView)
      return _deprecatedInstances;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_deprecatedInstances);
  }

  /// Deprecated superRecords
  /// These may be compromised and should not be considered valid for
  /// new signatures, but may be used to validate old signatures
  final List<Typed<FixedEncodedString43>> _deprecatedSuperRecordKeys;

  /// Deprecated superRecords
  /// These may be compromised and should not be considered valid for
  /// new signatures, but may be used to validate old signatures
  @override
  List<Typed<FixedEncodedString43>> get deprecatedSuperRecordKeys {
    if (_deprecatedSuperRecordKeys is EqualUnmodifiableListView)
      return _deprecatedSuperRecordKeys;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_deprecatedSuperRecordKeys);
  }

  /// Signature of recordKey, currentInstance signature,
  /// signatures of deprecatedInstances, and deprecatedSuperRecordKeys
  /// by publicKey
  @override
  final FixedEncodedString86 signature;

  /// Create a copy of SuperIdentity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SuperIdentityCopyWith<_SuperIdentity> get copyWith =>
      __$SuperIdentityCopyWithImpl<_SuperIdentity>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SuperIdentityToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SuperIdentity &&
            (identical(other.recordKey, recordKey) ||
                other.recordKey == recordKey) &&
            (identical(other.publicKey, publicKey) ||
                other.publicKey == publicKey) &&
            (identical(other.currentInstance, currentInstance) ||
                other.currentInstance == currentInstance) &&
            const DeepCollectionEquality()
                .equals(other._deprecatedInstances, _deprecatedInstances) &&
            const DeepCollectionEquality().equals(
                other._deprecatedSuperRecordKeys, _deprecatedSuperRecordKeys) &&
            (identical(other.signature, signature) ||
                other.signature == signature));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      recordKey,
      publicKey,
      currentInstance,
      const DeepCollectionEquality().hash(_deprecatedInstances),
      const DeepCollectionEquality().hash(_deprecatedSuperRecordKeys),
      signature);

  @override
  String toString() {
    return 'SuperIdentity(recordKey: $recordKey, publicKey: $publicKey, currentInstance: $currentInstance, deprecatedInstances: $deprecatedInstances, deprecatedSuperRecordKeys: $deprecatedSuperRecordKeys, signature: $signature)';
  }
}

/// @nodoc
abstract mixin class _$SuperIdentityCopyWith<$Res>
    implements $SuperIdentityCopyWith<$Res> {
  factory _$SuperIdentityCopyWith(
          _SuperIdentity value, $Res Function(_SuperIdentity) _then) =
      __$SuperIdentityCopyWithImpl;
  @override
  @useResult
  $Res call(
      {Typed<FixedEncodedString43> recordKey,
      FixedEncodedString43 publicKey,
      IdentityInstance currentInstance,
      List<IdentityInstance> deprecatedInstances,
      List<Typed<FixedEncodedString43>> deprecatedSuperRecordKeys,
      FixedEncodedString86 signature});

  @override
  $IdentityInstanceCopyWith<$Res> get currentInstance;
}

/// @nodoc
class __$SuperIdentityCopyWithImpl<$Res>
    implements _$SuperIdentityCopyWith<$Res> {
  __$SuperIdentityCopyWithImpl(this._self, this._then);

  final _SuperIdentity _self;
  final $Res Function(_SuperIdentity) _then;

  /// Create a copy of SuperIdentity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? recordKey = null,
    Object? publicKey = null,
    Object? currentInstance = null,
    Object? deprecatedInstances = null,
    Object? deprecatedSuperRecordKeys = null,
    Object? signature = null,
  }) {
    return _then(_SuperIdentity(
      recordKey: null == recordKey
          ? _self.recordKey
          : recordKey // ignore: cast_nullable_to_non_nullable
              as Typed<FixedEncodedString43>,
      publicKey: null == publicKey
          ? _self.publicKey
          : publicKey // ignore: cast_nullable_to_non_nullable
              as FixedEncodedString43,
      currentInstance: null == currentInstance
          ? _self.currentInstance
          : currentInstance // ignore: cast_nullable_to_non_nullable
              as IdentityInstance,
      deprecatedInstances: null == deprecatedInstances
          ? _self._deprecatedInstances
          : deprecatedInstances // ignore: cast_nullable_to_non_nullable
              as List<IdentityInstance>,
      deprecatedSuperRecordKeys: null == deprecatedSuperRecordKeys
          ? _self._deprecatedSuperRecordKeys
          : deprecatedSuperRecordKeys // ignore: cast_nullable_to_non_nullable
              as List<Typed<FixedEncodedString43>>,
      signature: null == signature
          ? _self.signature
          : signature // ignore: cast_nullable_to_non_nullable
              as FixedEncodedString86,
    ));
  }

  /// Create a copy of SuperIdentity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $IdentityInstanceCopyWith<$Res> get currentInstance {
    return $IdentityInstanceCopyWith<$Res>(_self.currentInstance, (value) {
      return _then(_self.copyWith(currentInstance: value));
    });
  }
}

// dart format on
