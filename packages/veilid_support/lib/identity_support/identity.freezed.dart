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
