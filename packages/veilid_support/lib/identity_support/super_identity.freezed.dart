// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'super_identity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SuperIdentity _$SuperIdentityFromJson(Map<String, dynamic> json) {
  return _SuperIdentity.fromJson(json);
}

/// @nodoc
mixin _$SuperIdentity {
  /// Public DHT record storing this structure for account recovery
  /// changing this can migrate/forward the SuperIdentity to a new DHT record
  /// Instances should not hash this recordKey, rather the actual record
  /// key used to store the superIdentity, as this may change.
  Typed<FixedEncodedString43> get recordKey =>
      throw _privateConstructorUsedError;

  /// Public key of the SuperIdentity used to sign identity keys for recovery
  /// This must match the owner of the superRecord DHT record and can not be
  /// changed without changing the record
  FixedEncodedString43 get publicKey => throw _privateConstructorUsedError;

  /// Current identity instance
  /// The most recently generated identity instance for this SuperIdentity
  IdentityInstance get currentInstance => throw _privateConstructorUsedError;

  /// Deprecated identity instances
  /// These may be compromised and should not be considered valid for
  /// new signatures, but may be used to validate old signatures
  List<IdentityInstance> get deprecatedInstances =>
      throw _privateConstructorUsedError;

  /// Deprecated superRecords
  /// These may be compromised and should not be considered valid for
  /// new signatures, but may be used to validate old signatures
  List<Typed<FixedEncodedString43>> get deprecatedSuperRecordKeys =>
      throw _privateConstructorUsedError;

  /// Signature of recordKey, currentInstance signature,
  /// signatures of deprecatedInstances, and deprecatedSuperRecordKeys
  /// by publicKey
  FixedEncodedString86 get signature => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SuperIdentityCopyWith<SuperIdentity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SuperIdentityCopyWith<$Res> {
  factory $SuperIdentityCopyWith(
          SuperIdentity value, $Res Function(SuperIdentity) then) =
      _$SuperIdentityCopyWithImpl<$Res, SuperIdentity>;
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
class _$SuperIdentityCopyWithImpl<$Res, $Val extends SuperIdentity>
    implements $SuperIdentityCopyWith<$Res> {
  _$SuperIdentityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      recordKey: null == recordKey
          ? _value.recordKey
          : recordKey // ignore: cast_nullable_to_non_nullable
              as Typed<FixedEncodedString43>,
      publicKey: null == publicKey
          ? _value.publicKey
          : publicKey // ignore: cast_nullable_to_non_nullable
              as FixedEncodedString43,
      currentInstance: null == currentInstance
          ? _value.currentInstance
          : currentInstance // ignore: cast_nullable_to_non_nullable
              as IdentityInstance,
      deprecatedInstances: null == deprecatedInstances
          ? _value.deprecatedInstances
          : deprecatedInstances // ignore: cast_nullable_to_non_nullable
              as List<IdentityInstance>,
      deprecatedSuperRecordKeys: null == deprecatedSuperRecordKeys
          ? _value.deprecatedSuperRecordKeys
          : deprecatedSuperRecordKeys // ignore: cast_nullable_to_non_nullable
              as List<Typed<FixedEncodedString43>>,
      signature: null == signature
          ? _value.signature
          : signature // ignore: cast_nullable_to_non_nullable
              as FixedEncodedString86,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $IdentityInstanceCopyWith<$Res> get currentInstance {
    return $IdentityInstanceCopyWith<$Res>(_value.currentInstance, (value) {
      return _then(_value.copyWith(currentInstance: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SuperIdentityImplCopyWith<$Res>
    implements $SuperIdentityCopyWith<$Res> {
  factory _$$SuperIdentityImplCopyWith(
          _$SuperIdentityImpl value, $Res Function(_$SuperIdentityImpl) then) =
      __$$SuperIdentityImplCopyWithImpl<$Res>;
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
class __$$SuperIdentityImplCopyWithImpl<$Res>
    extends _$SuperIdentityCopyWithImpl<$Res, _$SuperIdentityImpl>
    implements _$$SuperIdentityImplCopyWith<$Res> {
  __$$SuperIdentityImplCopyWithImpl(
      _$SuperIdentityImpl _value, $Res Function(_$SuperIdentityImpl) _then)
      : super(_value, _then);

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
    return _then(_$SuperIdentityImpl(
      recordKey: null == recordKey
          ? _value.recordKey
          : recordKey // ignore: cast_nullable_to_non_nullable
              as Typed<FixedEncodedString43>,
      publicKey: null == publicKey
          ? _value.publicKey
          : publicKey // ignore: cast_nullable_to_non_nullable
              as FixedEncodedString43,
      currentInstance: null == currentInstance
          ? _value.currentInstance
          : currentInstance // ignore: cast_nullable_to_non_nullable
              as IdentityInstance,
      deprecatedInstances: null == deprecatedInstances
          ? _value._deprecatedInstances
          : deprecatedInstances // ignore: cast_nullable_to_non_nullable
              as List<IdentityInstance>,
      deprecatedSuperRecordKeys: null == deprecatedSuperRecordKeys
          ? _value._deprecatedSuperRecordKeys
          : deprecatedSuperRecordKeys // ignore: cast_nullable_to_non_nullable
              as List<Typed<FixedEncodedString43>>,
      signature: null == signature
          ? _value.signature
          : signature // ignore: cast_nullable_to_non_nullable
              as FixedEncodedString86,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SuperIdentityImpl extends _SuperIdentity {
  const _$SuperIdentityImpl(
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

  factory _$SuperIdentityImpl.fromJson(Map<String, dynamic> json) =>
      _$$SuperIdentityImplFromJson(json);

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

  @override
  String toString() {
    return 'SuperIdentity(recordKey: $recordKey, publicKey: $publicKey, currentInstance: $currentInstance, deprecatedInstances: $deprecatedInstances, deprecatedSuperRecordKeys: $deprecatedSuperRecordKeys, signature: $signature)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SuperIdentityImpl &&
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

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      recordKey,
      publicKey,
      currentInstance,
      const DeepCollectionEquality().hash(_deprecatedInstances),
      const DeepCollectionEquality().hash(_deprecatedSuperRecordKeys),
      signature);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SuperIdentityImplCopyWith<_$SuperIdentityImpl> get copyWith =>
      __$$SuperIdentityImplCopyWithImpl<_$SuperIdentityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SuperIdentityImplToJson(
      this,
    );
  }
}

abstract class _SuperIdentity extends SuperIdentity {
  const factory _SuperIdentity(
      {required final Typed<FixedEncodedString43> recordKey,
      required final FixedEncodedString43 publicKey,
      required final IdentityInstance currentInstance,
      required final List<IdentityInstance> deprecatedInstances,
      required final List<Typed<FixedEncodedString43>>
          deprecatedSuperRecordKeys,
      required final FixedEncodedString86 signature}) = _$SuperIdentityImpl;
  const _SuperIdentity._() : super._();

  factory _SuperIdentity.fromJson(Map<String, dynamic> json) =
      _$SuperIdentityImpl.fromJson;

  @override

  /// Public DHT record storing this structure for account recovery
  /// changing this can migrate/forward the SuperIdentity to a new DHT record
  /// Instances should not hash this recordKey, rather the actual record
  /// key used to store the superIdentity, as this may change.
  Typed<FixedEncodedString43> get recordKey;
  @override

  /// Public key of the SuperIdentity used to sign identity keys for recovery
  /// This must match the owner of the superRecord DHT record and can not be
  /// changed without changing the record
  FixedEncodedString43 get publicKey;
  @override

  /// Current identity instance
  /// The most recently generated identity instance for this SuperIdentity
  IdentityInstance get currentInstance;
  @override

  /// Deprecated identity instances
  /// These may be compromised and should not be considered valid for
  /// new signatures, but may be used to validate old signatures
  List<IdentityInstance> get deprecatedInstances;
  @override

  /// Deprecated superRecords
  /// These may be compromised and should not be considered valid for
  /// new signatures, but may be used to validate old signatures
  List<Typed<FixedEncodedString43>> get deprecatedSuperRecordKeys;
  @override

  /// Signature of recordKey, currentInstance signature,
  /// signatures of deprecatedInstances, and deprecatedSuperRecordKeys
  /// by publicKey
  FixedEncodedString86 get signature;
  @override
  @JsonKey(ignore: true)
  _$$SuperIdentityImplCopyWith<_$SuperIdentityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
