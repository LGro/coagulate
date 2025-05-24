// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_record_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AccountRecordInfo {
// Top level account keys and secrets
  OwnedDHTRecordPointer get accountRecord;

  /// Create a copy of AccountRecordInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AccountRecordInfoCopyWith<AccountRecordInfo> get copyWith =>
      _$AccountRecordInfoCopyWithImpl<AccountRecordInfo>(
          this as AccountRecordInfo, _$identity);

  /// Serializes this AccountRecordInfo to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AccountRecordInfo &&
            (identical(other.accountRecord, accountRecord) ||
                other.accountRecord == accountRecord));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, accountRecord);

  @override
  String toString() {
    return 'AccountRecordInfo(accountRecord: $accountRecord)';
  }
}

/// @nodoc
abstract mixin class $AccountRecordInfoCopyWith<$Res> {
  factory $AccountRecordInfoCopyWith(
          AccountRecordInfo value, $Res Function(AccountRecordInfo) _then) =
      _$AccountRecordInfoCopyWithImpl;
  @useResult
  $Res call({OwnedDHTRecordPointer accountRecord});

  $OwnedDHTRecordPointerCopyWith<$Res> get accountRecord;
}

/// @nodoc
class _$AccountRecordInfoCopyWithImpl<$Res>
    implements $AccountRecordInfoCopyWith<$Res> {
  _$AccountRecordInfoCopyWithImpl(this._self, this._then);

  final AccountRecordInfo _self;
  final $Res Function(AccountRecordInfo) _then;

  /// Create a copy of AccountRecordInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accountRecord = null,
  }) {
    return _then(_self.copyWith(
      accountRecord: null == accountRecord
          ? _self.accountRecord
          : accountRecord // ignore: cast_nullable_to_non_nullable
              as OwnedDHTRecordPointer,
    ));
  }

  /// Create a copy of AccountRecordInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OwnedDHTRecordPointerCopyWith<$Res> get accountRecord {
    return $OwnedDHTRecordPointerCopyWith<$Res>(_self.accountRecord, (value) {
      return _then(_self.copyWith(accountRecord: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _AccountRecordInfo implements AccountRecordInfo {
  const _AccountRecordInfo({required this.accountRecord});
  factory _AccountRecordInfo.fromJson(Map<String, dynamic> json) =>
      _$AccountRecordInfoFromJson(json);

// Top level account keys and secrets
  @override
  final OwnedDHTRecordPointer accountRecord;

  /// Create a copy of AccountRecordInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AccountRecordInfoCopyWith<_AccountRecordInfo> get copyWith =>
      __$AccountRecordInfoCopyWithImpl<_AccountRecordInfo>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AccountRecordInfoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AccountRecordInfo &&
            (identical(other.accountRecord, accountRecord) ||
                other.accountRecord == accountRecord));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, accountRecord);

  @override
  String toString() {
    return 'AccountRecordInfo(accountRecord: $accountRecord)';
  }
}

/// @nodoc
abstract mixin class _$AccountRecordInfoCopyWith<$Res>
    implements $AccountRecordInfoCopyWith<$Res> {
  factory _$AccountRecordInfoCopyWith(
          _AccountRecordInfo value, $Res Function(_AccountRecordInfo) _then) =
      __$AccountRecordInfoCopyWithImpl;
  @override
  @useResult
  $Res call({OwnedDHTRecordPointer accountRecord});

  @override
  $OwnedDHTRecordPointerCopyWith<$Res> get accountRecord;
}

/// @nodoc
class __$AccountRecordInfoCopyWithImpl<$Res>
    implements _$AccountRecordInfoCopyWith<$Res> {
  __$AccountRecordInfoCopyWithImpl(this._self, this._then);

  final _AccountRecordInfo _self;
  final $Res Function(_AccountRecordInfo) _then;

  /// Create a copy of AccountRecordInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? accountRecord = null,
  }) {
    return _then(_AccountRecordInfo(
      accountRecord: null == accountRecord
          ? _self.accountRecord
          : accountRecord // ignore: cast_nullable_to_non_nullable
              as OwnedDHTRecordPointer,
    ));
  }

  /// Create a copy of AccountRecordInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OwnedDHTRecordPointerCopyWith<$Res> get accountRecord {
    return $OwnedDHTRecordPointerCopyWith<$Res>(_self.accountRecord, (value) {
      return _then(_self.copyWith(accountRecord: value));
    });
  }
}

// dart format on
