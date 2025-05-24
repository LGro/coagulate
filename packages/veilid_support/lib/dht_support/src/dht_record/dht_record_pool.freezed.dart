// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dht_record_pool.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DHTRecordPoolAllocations {
  IMap<String, ISet<TypedKey>> get childrenByParent;
  IMap<String, TypedKey> get parentByChild;
  ISet<TypedKey> get rootRecords;
  IMap<String, String> get debugNames;

  /// Create a copy of DHTRecordPoolAllocations
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DHTRecordPoolAllocationsCopyWith<DHTRecordPoolAllocations> get copyWith =>
      _$DHTRecordPoolAllocationsCopyWithImpl<DHTRecordPoolAllocations>(
          this as DHTRecordPoolAllocations, _$identity);

  /// Serializes this DHTRecordPoolAllocations to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DHTRecordPoolAllocations &&
            (identical(other.childrenByParent, childrenByParent) ||
                other.childrenByParent == childrenByParent) &&
            (identical(other.parentByChild, parentByChild) ||
                other.parentByChild == parentByChild) &&
            const DeepCollectionEquality()
                .equals(other.rootRecords, rootRecords) &&
            (identical(other.debugNames, debugNames) ||
                other.debugNames == debugNames));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, childrenByParent, parentByChild,
      const DeepCollectionEquality().hash(rootRecords), debugNames);

  @override
  String toString() {
    return 'DHTRecordPoolAllocations(childrenByParent: $childrenByParent, parentByChild: $parentByChild, rootRecords: $rootRecords, debugNames: $debugNames)';
  }
}

/// @nodoc
abstract mixin class $DHTRecordPoolAllocationsCopyWith<$Res> {
  factory $DHTRecordPoolAllocationsCopyWith(DHTRecordPoolAllocations value,
          $Res Function(DHTRecordPoolAllocations) _then) =
      _$DHTRecordPoolAllocationsCopyWithImpl;
  @useResult
  $Res call(
      {IMap<String, ISet<Typed<FixedEncodedString43>>> childrenByParent,
      IMap<String, Typed<FixedEncodedString43>> parentByChild,
      ISet<Typed<FixedEncodedString43>> rootRecords,
      IMap<String, String> debugNames});
}

/// @nodoc
class _$DHTRecordPoolAllocationsCopyWithImpl<$Res>
    implements $DHTRecordPoolAllocationsCopyWith<$Res> {
  _$DHTRecordPoolAllocationsCopyWithImpl(this._self, this._then);

  final DHTRecordPoolAllocations _self;
  final $Res Function(DHTRecordPoolAllocations) _then;

  /// Create a copy of DHTRecordPoolAllocations
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? childrenByParent = null,
    Object? parentByChild = null,
    Object? rootRecords = null,
    Object? debugNames = null,
  }) {
    return _then(_self.copyWith(
      childrenByParent: null == childrenByParent
          ? _self.childrenByParent!
          : childrenByParent // ignore: cast_nullable_to_non_nullable
              as IMap<String, ISet<Typed<FixedEncodedString43>>>,
      parentByChild: null == parentByChild
          ? _self.parentByChild!
          : parentByChild // ignore: cast_nullable_to_non_nullable
              as IMap<String, Typed<FixedEncodedString43>>,
      rootRecords: null == rootRecords
          ? _self.rootRecords!
          : rootRecords // ignore: cast_nullable_to_non_nullable
              as ISet<Typed<FixedEncodedString43>>,
      debugNames: null == debugNames
          ? _self.debugNames
          : debugNames // ignore: cast_nullable_to_non_nullable
              as IMap<String, String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _DHTRecordPoolAllocations implements DHTRecordPoolAllocations {
  const _DHTRecordPoolAllocations(
      {this.childrenByParent = const IMapConst<String, ISet<TypedKey>>({}),
      this.parentByChild = const IMapConst<String, TypedKey>({}),
      this.rootRecords = const ISetConst<TypedKey>({}),
      this.debugNames = const IMapConst<String, String>({})});
  factory _DHTRecordPoolAllocations.fromJson(Map<String, dynamic> json) =>
      _$DHTRecordPoolAllocationsFromJson(json);

  @override
  @JsonKey()
  final IMap<String, ISet<Typed<FixedEncodedString43>>> childrenByParent;
  @override
  @JsonKey()
  final IMap<String, Typed<FixedEncodedString43>> parentByChild;
  @override
  @JsonKey()
  final ISet<Typed<FixedEncodedString43>> rootRecords;
  @override
  @JsonKey()
  final IMap<String, String> debugNames;

  /// Create a copy of DHTRecordPoolAllocations
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DHTRecordPoolAllocationsCopyWith<_DHTRecordPoolAllocations> get copyWith =>
      __$DHTRecordPoolAllocationsCopyWithImpl<_DHTRecordPoolAllocations>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$DHTRecordPoolAllocationsToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DHTRecordPoolAllocations &&
            (identical(other.childrenByParent, childrenByParent) ||
                other.childrenByParent == childrenByParent) &&
            (identical(other.parentByChild, parentByChild) ||
                other.parentByChild == parentByChild) &&
            const DeepCollectionEquality()
                .equals(other.rootRecords, rootRecords) &&
            (identical(other.debugNames, debugNames) ||
                other.debugNames == debugNames));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, childrenByParent, parentByChild,
      const DeepCollectionEquality().hash(rootRecords), debugNames);

  @override
  String toString() {
    return 'DHTRecordPoolAllocations(childrenByParent: $childrenByParent, parentByChild: $parentByChild, rootRecords: $rootRecords, debugNames: $debugNames)';
  }
}

/// @nodoc
abstract mixin class _$DHTRecordPoolAllocationsCopyWith<$Res>
    implements $DHTRecordPoolAllocationsCopyWith<$Res> {
  factory _$DHTRecordPoolAllocationsCopyWith(_DHTRecordPoolAllocations value,
          $Res Function(_DHTRecordPoolAllocations) _then) =
      __$DHTRecordPoolAllocationsCopyWithImpl;
  @override
  @useResult
  $Res call(
      {IMap<String, ISet<Typed<FixedEncodedString43>>> childrenByParent,
      IMap<String, Typed<FixedEncodedString43>> parentByChild,
      ISet<Typed<FixedEncodedString43>> rootRecords,
      IMap<String, String> debugNames});
}

/// @nodoc
class __$DHTRecordPoolAllocationsCopyWithImpl<$Res>
    implements _$DHTRecordPoolAllocationsCopyWith<$Res> {
  __$DHTRecordPoolAllocationsCopyWithImpl(this._self, this._then);

  final _DHTRecordPoolAllocations _self;
  final $Res Function(_DHTRecordPoolAllocations) _then;

  /// Create a copy of DHTRecordPoolAllocations
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? childrenByParent = null,
    Object? parentByChild = null,
    Object? rootRecords = null,
    Object? debugNames = null,
  }) {
    return _then(_DHTRecordPoolAllocations(
      childrenByParent: null == childrenByParent
          ? _self.childrenByParent
          : childrenByParent // ignore: cast_nullable_to_non_nullable
              as IMap<String, ISet<Typed<FixedEncodedString43>>>,
      parentByChild: null == parentByChild
          ? _self.parentByChild
          : parentByChild // ignore: cast_nullable_to_non_nullable
              as IMap<String, Typed<FixedEncodedString43>>,
      rootRecords: null == rootRecords
          ? _self.rootRecords
          : rootRecords // ignore: cast_nullable_to_non_nullable
              as ISet<Typed<FixedEncodedString43>>,
      debugNames: null == debugNames
          ? _self.debugNames
          : debugNames // ignore: cast_nullable_to_non_nullable
              as IMap<String, String>,
    ));
  }
}

/// @nodoc
mixin _$OwnedDHTRecordPointer {
  TypedKey get recordKey;
  KeyPair get owner;

  /// Create a copy of OwnedDHTRecordPointer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $OwnedDHTRecordPointerCopyWith<OwnedDHTRecordPointer> get copyWith =>
      _$OwnedDHTRecordPointerCopyWithImpl<OwnedDHTRecordPointer>(
          this as OwnedDHTRecordPointer, _$identity);

  /// Serializes this OwnedDHTRecordPointer to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is OwnedDHTRecordPointer &&
            (identical(other.recordKey, recordKey) ||
                other.recordKey == recordKey) &&
            (identical(other.owner, owner) || other.owner == owner));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, recordKey, owner);

  @override
  String toString() {
    return 'OwnedDHTRecordPointer(recordKey: $recordKey, owner: $owner)';
  }
}

/// @nodoc
abstract mixin class $OwnedDHTRecordPointerCopyWith<$Res> {
  factory $OwnedDHTRecordPointerCopyWith(OwnedDHTRecordPointer value,
          $Res Function(OwnedDHTRecordPointer) _then) =
      _$OwnedDHTRecordPointerCopyWithImpl;
  @useResult
  $Res call({Typed<FixedEncodedString43> recordKey, KeyPair owner});
}

/// @nodoc
class _$OwnedDHTRecordPointerCopyWithImpl<$Res>
    implements $OwnedDHTRecordPointerCopyWith<$Res> {
  _$OwnedDHTRecordPointerCopyWithImpl(this._self, this._then);

  final OwnedDHTRecordPointer _self;
  final $Res Function(OwnedDHTRecordPointer) _then;

  /// Create a copy of OwnedDHTRecordPointer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recordKey = null,
    Object? owner = null,
  }) {
    return _then(_self.copyWith(
      recordKey: null == recordKey
          ? _self.recordKey!
          : recordKey // ignore: cast_nullable_to_non_nullable
              as Typed<FixedEncodedString43>,
      owner: null == owner
          ? _self.owner
          : owner // ignore: cast_nullable_to_non_nullable
              as KeyPair,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _OwnedDHTRecordPointer implements OwnedDHTRecordPointer {
  const _OwnedDHTRecordPointer({required this.recordKey, required this.owner});
  factory _OwnedDHTRecordPointer.fromJson(Map<String, dynamic> json) =>
      _$OwnedDHTRecordPointerFromJson(json);

  @override
  final Typed<FixedEncodedString43> recordKey;
  @override
  final KeyPair owner;

  /// Create a copy of OwnedDHTRecordPointer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$OwnedDHTRecordPointerCopyWith<_OwnedDHTRecordPointer> get copyWith =>
      __$OwnedDHTRecordPointerCopyWithImpl<_OwnedDHTRecordPointer>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$OwnedDHTRecordPointerToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _OwnedDHTRecordPointer &&
            (identical(other.recordKey, recordKey) ||
                other.recordKey == recordKey) &&
            (identical(other.owner, owner) || other.owner == owner));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, recordKey, owner);

  @override
  String toString() {
    return 'OwnedDHTRecordPointer(recordKey: $recordKey, owner: $owner)';
  }
}

/// @nodoc
abstract mixin class _$OwnedDHTRecordPointerCopyWith<$Res>
    implements $OwnedDHTRecordPointerCopyWith<$Res> {
  factory _$OwnedDHTRecordPointerCopyWith(_OwnedDHTRecordPointer value,
          $Res Function(_OwnedDHTRecordPointer) _then) =
      __$OwnedDHTRecordPointerCopyWithImpl;
  @override
  @useResult
  $Res call({Typed<FixedEncodedString43> recordKey, KeyPair owner});
}

/// @nodoc
class __$OwnedDHTRecordPointerCopyWithImpl<$Res>
    implements _$OwnedDHTRecordPointerCopyWith<$Res> {
  __$OwnedDHTRecordPointerCopyWithImpl(this._self, this._then);

  final _OwnedDHTRecordPointer _self;
  final $Res Function(_OwnedDHTRecordPointer) _then;

  /// Create a copy of OwnedDHTRecordPointer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? recordKey = null,
    Object? owner = null,
  }) {
    return _then(_OwnedDHTRecordPointer(
      recordKey: null == recordKey
          ? _self.recordKey
          : recordKey // ignore: cast_nullable_to_non_nullable
              as Typed<FixedEncodedString43>,
      owner: null == owner
          ? _self.owner
          : owner // ignore: cast_nullable_to_non_nullable
              as KeyPair,
    ));
  }
}

// dart format on
