// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dht_record_pool.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

DHTRecordPoolAllocations _$DHTRecordPoolAllocationsFromJson(
    Map<String, dynamic> json) {
  return _DHTRecordPoolAllocations.fromJson(json);
}

/// @nodoc
mixin _$DHTRecordPoolAllocations {
  IMap<String, ISet<Typed<FixedEncodedString43>>> get childrenByParent =>
      throw _privateConstructorUsedError; // String key due to IMap<> json unsupported in key
  IMap<String, Typed<FixedEncodedString43>> get parentByChild =>
      throw _privateConstructorUsedError; // String key due to IMap<> json unsupported in key
  ISet<Typed<FixedEncodedString43>> get rootRecords =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DHTRecordPoolAllocationsCopyWith<DHTRecordPoolAllocations> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DHTRecordPoolAllocationsCopyWith<$Res> {
  factory $DHTRecordPoolAllocationsCopyWith(DHTRecordPoolAllocations value,
          $Res Function(DHTRecordPoolAllocations) then) =
      _$DHTRecordPoolAllocationsCopyWithImpl<$Res, DHTRecordPoolAllocations>;
  @useResult
  $Res call(
      {IMap<String, ISet<Typed<FixedEncodedString43>>> childrenByParent,
      IMap<String, Typed<FixedEncodedString43>> parentByChild,
      ISet<Typed<FixedEncodedString43>> rootRecords});
}

/// @nodoc
class _$DHTRecordPoolAllocationsCopyWithImpl<$Res,
        $Val extends DHTRecordPoolAllocations>
    implements $DHTRecordPoolAllocationsCopyWith<$Res> {
  _$DHTRecordPoolAllocationsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? childrenByParent = null,
    Object? parentByChild = null,
    Object? rootRecords = null,
  }) {
    return _then(_value.copyWith(
      childrenByParent: null == childrenByParent
          ? _value.childrenByParent
          : childrenByParent // ignore: cast_nullable_to_non_nullable
              as IMap<String, ISet<Typed<FixedEncodedString43>>>,
      parentByChild: null == parentByChild
          ? _value.parentByChild
          : parentByChild // ignore: cast_nullable_to_non_nullable
              as IMap<String, Typed<FixedEncodedString43>>,
      rootRecords: null == rootRecords
          ? _value.rootRecords
          : rootRecords // ignore: cast_nullable_to_non_nullable
              as ISet<Typed<FixedEncodedString43>>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DHTRecordPoolAllocationsImplCopyWith<$Res>
    implements $DHTRecordPoolAllocationsCopyWith<$Res> {
  factory _$$DHTRecordPoolAllocationsImplCopyWith(
          _$DHTRecordPoolAllocationsImpl value,
          $Res Function(_$DHTRecordPoolAllocationsImpl) then) =
      __$$DHTRecordPoolAllocationsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {IMap<String, ISet<Typed<FixedEncodedString43>>> childrenByParent,
      IMap<String, Typed<FixedEncodedString43>> parentByChild,
      ISet<Typed<FixedEncodedString43>> rootRecords});
}

/// @nodoc
class __$$DHTRecordPoolAllocationsImplCopyWithImpl<$Res>
    extends _$DHTRecordPoolAllocationsCopyWithImpl<$Res,
        _$DHTRecordPoolAllocationsImpl>
    implements _$$DHTRecordPoolAllocationsImplCopyWith<$Res> {
  __$$DHTRecordPoolAllocationsImplCopyWithImpl(
      _$DHTRecordPoolAllocationsImpl _value,
      $Res Function(_$DHTRecordPoolAllocationsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? childrenByParent = null,
    Object? parentByChild = null,
    Object? rootRecords = null,
  }) {
    return _then(_$DHTRecordPoolAllocationsImpl(
      childrenByParent: null == childrenByParent
          ? _value.childrenByParent
          : childrenByParent // ignore: cast_nullable_to_non_nullable
              as IMap<String, ISet<Typed<FixedEncodedString43>>>,
      parentByChild: null == parentByChild
          ? _value.parentByChild
          : parentByChild // ignore: cast_nullable_to_non_nullable
              as IMap<String, Typed<FixedEncodedString43>>,
      rootRecords: null == rootRecords
          ? _value.rootRecords
          : rootRecords // ignore: cast_nullable_to_non_nullable
              as ISet<Typed<FixedEncodedString43>>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DHTRecordPoolAllocationsImpl implements _DHTRecordPoolAllocations {
  const _$DHTRecordPoolAllocationsImpl(
      {required this.childrenByParent,
      required this.parentByChild,
      required this.rootRecords});

  factory _$DHTRecordPoolAllocationsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DHTRecordPoolAllocationsImplFromJson(json);

  @override
  final IMap<String, ISet<Typed<FixedEncodedString43>>> childrenByParent;
// String key due to IMap<> json unsupported in key
  @override
  final IMap<String, Typed<FixedEncodedString43>> parentByChild;
// String key due to IMap<> json unsupported in key
  @override
  final ISet<Typed<FixedEncodedString43>> rootRecords;

  @override
  String toString() {
    return 'DHTRecordPoolAllocations(childrenByParent: $childrenByParent, parentByChild: $parentByChild, rootRecords: $rootRecords)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DHTRecordPoolAllocationsImpl &&
            (identical(other.childrenByParent, childrenByParent) ||
                other.childrenByParent == childrenByParent) &&
            (identical(other.parentByChild, parentByChild) ||
                other.parentByChild == parentByChild) &&
            const DeepCollectionEquality()
                .equals(other.rootRecords, rootRecords));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, childrenByParent, parentByChild,
      const DeepCollectionEquality().hash(rootRecords));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DHTRecordPoolAllocationsImplCopyWith<_$DHTRecordPoolAllocationsImpl>
      get copyWith => __$$DHTRecordPoolAllocationsImplCopyWithImpl<
          _$DHTRecordPoolAllocationsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DHTRecordPoolAllocationsImplToJson(
      this,
    );
  }
}

abstract class _DHTRecordPoolAllocations implements DHTRecordPoolAllocations {
  const factory _DHTRecordPoolAllocations(
      {required final IMap<String, ISet<Typed<FixedEncodedString43>>>
          childrenByParent,
      required final IMap<String, Typed<FixedEncodedString43>> parentByChild,
      required final ISet<Typed<FixedEncodedString43>>
          rootRecords}) = _$DHTRecordPoolAllocationsImpl;

  factory _DHTRecordPoolAllocations.fromJson(Map<String, dynamic> json) =
      _$DHTRecordPoolAllocationsImpl.fromJson;

  @override
  IMap<String, ISet<Typed<FixedEncodedString43>>> get childrenByParent;
  @override // String key due to IMap<> json unsupported in key
  IMap<String, Typed<FixedEncodedString43>> get parentByChild;
  @override // String key due to IMap<> json unsupported in key
  ISet<Typed<FixedEncodedString43>> get rootRecords;
  @override
  @JsonKey(ignore: true)
  _$$DHTRecordPoolAllocationsImplCopyWith<_$DHTRecordPoolAllocationsImpl>
      get copyWith => throw _privateConstructorUsedError;
}

OwnedDHTRecordPointer _$OwnedDHTRecordPointerFromJson(
    Map<String, dynamic> json) {
  return _OwnedDHTRecordPointer.fromJson(json);
}

/// @nodoc
mixin _$OwnedDHTRecordPointer {
  Typed<FixedEncodedString43> get recordKey =>
      throw _privateConstructorUsedError;
  KeyPair get owner => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $OwnedDHTRecordPointerCopyWith<OwnedDHTRecordPointer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OwnedDHTRecordPointerCopyWith<$Res> {
  factory $OwnedDHTRecordPointerCopyWith(OwnedDHTRecordPointer value,
          $Res Function(OwnedDHTRecordPointer) then) =
      _$OwnedDHTRecordPointerCopyWithImpl<$Res, OwnedDHTRecordPointer>;
  @useResult
  $Res call({Typed<FixedEncodedString43> recordKey, KeyPair owner});
}

/// @nodoc
class _$OwnedDHTRecordPointerCopyWithImpl<$Res,
        $Val extends OwnedDHTRecordPointer>
    implements $OwnedDHTRecordPointerCopyWith<$Res> {
  _$OwnedDHTRecordPointerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recordKey = null,
    Object? owner = null,
  }) {
    return _then(_value.copyWith(
      recordKey: null == recordKey
          ? _value.recordKey
          : recordKey // ignore: cast_nullable_to_non_nullable
              as Typed<FixedEncodedString43>,
      owner: null == owner
          ? _value.owner
          : owner // ignore: cast_nullable_to_non_nullable
              as KeyPair,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OwnedDHTRecordPointerImplCopyWith<$Res>
    implements $OwnedDHTRecordPointerCopyWith<$Res> {
  factory _$$OwnedDHTRecordPointerImplCopyWith(
          _$OwnedDHTRecordPointerImpl value,
          $Res Function(_$OwnedDHTRecordPointerImpl) then) =
      __$$OwnedDHTRecordPointerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Typed<FixedEncodedString43> recordKey, KeyPair owner});
}

/// @nodoc
class __$$OwnedDHTRecordPointerImplCopyWithImpl<$Res>
    extends _$OwnedDHTRecordPointerCopyWithImpl<$Res,
        _$OwnedDHTRecordPointerImpl>
    implements _$$OwnedDHTRecordPointerImplCopyWith<$Res> {
  __$$OwnedDHTRecordPointerImplCopyWithImpl(_$OwnedDHTRecordPointerImpl _value,
      $Res Function(_$OwnedDHTRecordPointerImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recordKey = null,
    Object? owner = null,
  }) {
    return _then(_$OwnedDHTRecordPointerImpl(
      recordKey: null == recordKey
          ? _value.recordKey
          : recordKey // ignore: cast_nullable_to_non_nullable
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
class _$OwnedDHTRecordPointerImpl implements _OwnedDHTRecordPointer {
  const _$OwnedDHTRecordPointerImpl(
      {required this.recordKey, required this.owner});

  factory _$OwnedDHTRecordPointerImpl.fromJson(Map<String, dynamic> json) =>
      _$$OwnedDHTRecordPointerImplFromJson(json);

  @override
  final Typed<FixedEncodedString43> recordKey;
  @override
  final KeyPair owner;

  @override
  String toString() {
    return 'OwnedDHTRecordPointer(recordKey: $recordKey, owner: $owner)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OwnedDHTRecordPointerImpl &&
            (identical(other.recordKey, recordKey) ||
                other.recordKey == recordKey) &&
            (identical(other.owner, owner) || other.owner == owner));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, recordKey, owner);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OwnedDHTRecordPointerImplCopyWith<_$OwnedDHTRecordPointerImpl>
      get copyWith => __$$OwnedDHTRecordPointerImplCopyWithImpl<
          _$OwnedDHTRecordPointerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OwnedDHTRecordPointerImplToJson(
      this,
    );
  }
}

abstract class _OwnedDHTRecordPointer implements OwnedDHTRecordPointer {
  const factory _OwnedDHTRecordPointer(
      {required final Typed<FixedEncodedString43> recordKey,
      required final KeyPair owner}) = _$OwnedDHTRecordPointerImpl;

  factory _OwnedDHTRecordPointer.fromJson(Map<String, dynamic> json) =
      _$OwnedDHTRecordPointerImpl.fromJson;

  @override
  Typed<FixedEncodedString43> get recordKey;
  @override
  KeyPair get owner;
  @override
  @JsonKey(ignore: true)
  _$$OwnedDHTRecordPointerImplCopyWith<_$OwnedDHTRecordPointerImpl>
      get copyWith => throw _privateConstructorUsedError;
}
