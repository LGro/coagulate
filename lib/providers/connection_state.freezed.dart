// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'connection_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ConnectionState {
  VeilidStateAttachment get attachment => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ConnectionStateCopyWith<ConnectionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConnectionStateCopyWith<$Res> {
  factory $ConnectionStateCopyWith(
          ConnectionState value, $Res Function(ConnectionState) then) =
      _$ConnectionStateCopyWithImpl<$Res, ConnectionState>;
  @useResult
  $Res call({VeilidStateAttachment attachment});

  $VeilidStateAttachmentCopyWith<$Res> get attachment;
}

/// @nodoc
class _$ConnectionStateCopyWithImpl<$Res, $Val extends ConnectionState>
    implements $ConnectionStateCopyWith<$Res> {
  _$ConnectionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? attachment = null,
  }) {
    return _then(_value.copyWith(
      attachment: null == attachment
          ? _value.attachment
          : attachment // ignore: cast_nullable_to_non_nullable
              as VeilidStateAttachment,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $VeilidStateAttachmentCopyWith<$Res> get attachment {
    return $VeilidStateAttachmentCopyWith<$Res>(_value.attachment, (value) {
      return _then(_value.copyWith(attachment: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ConnectionStateImplCopyWith<$Res>
    implements $ConnectionStateCopyWith<$Res> {
  factory _$$ConnectionStateImplCopyWith(_$ConnectionStateImpl value,
          $Res Function(_$ConnectionStateImpl) then) =
      __$$ConnectionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({VeilidStateAttachment attachment});

  @override
  $VeilidStateAttachmentCopyWith<$Res> get attachment;
}

/// @nodoc
class __$$ConnectionStateImplCopyWithImpl<$Res>
    extends _$ConnectionStateCopyWithImpl<$Res, _$ConnectionStateImpl>
    implements _$$ConnectionStateImplCopyWith<$Res> {
  __$$ConnectionStateImplCopyWithImpl(
      _$ConnectionStateImpl _value, $Res Function(_$ConnectionStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? attachment = null,
  }) {
    return _then(_$ConnectionStateImpl(
      attachment: null == attachment
          ? _value.attachment
          : attachment // ignore: cast_nullable_to_non_nullable
              as VeilidStateAttachment,
    ));
  }
}

/// @nodoc

class _$ConnectionStateImpl extends _ConnectionState {
  const _$ConnectionStateImpl({required this.attachment}) : super._();

  @override
  final VeilidStateAttachment attachment;

  @override
  String toString() {
    return 'ConnectionState(attachment: $attachment)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConnectionStateImpl &&
            (identical(other.attachment, attachment) ||
                other.attachment == attachment));
  }

  @override
  int get hashCode => Object.hash(runtimeType, attachment);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ConnectionStateImplCopyWith<_$ConnectionStateImpl> get copyWith =>
      __$$ConnectionStateImplCopyWithImpl<_$ConnectionStateImpl>(
          this, _$identity);
}

abstract class _ConnectionState extends ConnectionState {
  const factory _ConnectionState(
          {required final VeilidStateAttachment attachment}) =
      _$ConnectionStateImpl;
  const _ConnectionState._() : super._();

  @override
  VeilidStateAttachment get attachment;
  @override
  @JsonKey(ignore: true)
  _$$ConnectionStateImplCopyWith<_$ConnectionStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
