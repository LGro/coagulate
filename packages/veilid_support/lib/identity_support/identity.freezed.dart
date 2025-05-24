// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'identity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Identity {
// Top level account keys and secrets
  IMap<String, ISet<AccountRecordInfo>> get accountRecords;

  /// Create a copy of Identity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $IdentityCopyWith<Identity> get copyWith =>
      _$IdentityCopyWithImpl<Identity>(this as Identity, _$identity);

  /// Serializes this Identity to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Identity &&
            (identical(other.accountRecords, accountRecords) ||
                other.accountRecords == accountRecords));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, accountRecords);

  @override
  String toString() {
    return 'Identity(accountRecords: $accountRecords)';
  }
}

/// @nodoc
abstract mixin class $IdentityCopyWith<$Res> {
  factory $IdentityCopyWith(Identity value, $Res Function(Identity) _then) =
      _$IdentityCopyWithImpl;
  @useResult
  $Res call({IMap<String, ISet<AccountRecordInfo>> accountRecords});
}

/// @nodoc
class _$IdentityCopyWithImpl<$Res> implements $IdentityCopyWith<$Res> {
  _$IdentityCopyWithImpl(this._self, this._then);

  final Identity _self;
  final $Res Function(Identity) _then;

  /// Create a copy of Identity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accountRecords = null,
  }) {
    return _then(_self.copyWith(
      accountRecords: null == accountRecords
          ? _self.accountRecords
          : accountRecords // ignore: cast_nullable_to_non_nullable
              as IMap<String, ISet<AccountRecordInfo>>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _Identity implements Identity {
  const _Identity({required this.accountRecords});
  factory _Identity.fromJson(Map<String, dynamic> json) =>
      _$IdentityFromJson(json);

// Top level account keys and secrets
  @override
  final IMap<String, ISet<AccountRecordInfo>> accountRecords;

  /// Create a copy of Identity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$IdentityCopyWith<_Identity> get copyWith =>
      __$IdentityCopyWithImpl<_Identity>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$IdentityToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Identity &&
            (identical(other.accountRecords, accountRecords) ||
                other.accountRecords == accountRecords));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, accountRecords);

  @override
  String toString() {
    return 'Identity(accountRecords: $accountRecords)';
  }
}

/// @nodoc
abstract mixin class _$IdentityCopyWith<$Res>
    implements $IdentityCopyWith<$Res> {
  factory _$IdentityCopyWith(_Identity value, $Res Function(_Identity) _then) =
      __$IdentityCopyWithImpl;
  @override
  @useResult
  $Res call({IMap<String, ISet<AccountRecordInfo>> accountRecords});
}

/// @nodoc
class __$IdentityCopyWithImpl<$Res> implements _$IdentityCopyWith<$Res> {
  __$IdentityCopyWithImpl(this._self, this._then);

  final _Identity _self;
  final $Res Function(_Identity) _then;

  /// Create a copy of Identity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? accountRecords = null,
  }) {
    return _then(_Identity(
      accountRecords: null == accountRecords
          ? _self.accountRecords
          : accountRecords // ignore: cast_nullable_to_non_nullable
              as IMap<String, ISet<AccountRecordInfo>>,
    ));
  }
}

// dart format on
