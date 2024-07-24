// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_record_info.dart';

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
