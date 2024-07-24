// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'processor_connection_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ProcessorConnectionState {
  VeilidStateAttachment get attachment => throw _privateConstructorUsedError;
  VeilidStateNetwork get network => throw _privateConstructorUsedError;

  /// Create a copy of ProcessorConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProcessorConnectionStateCopyWith<ProcessorConnectionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProcessorConnectionStateCopyWith<$Res> {
  factory $ProcessorConnectionStateCopyWith(ProcessorConnectionState value,
          $Res Function(ProcessorConnectionState) then) =
      _$ProcessorConnectionStateCopyWithImpl<$Res, ProcessorConnectionState>;
  @useResult
  $Res call({VeilidStateAttachment attachment, VeilidStateNetwork network});

  $VeilidStateAttachmentCopyWith<$Res> get attachment;
  $VeilidStateNetworkCopyWith<$Res> get network;
}

/// @nodoc
class _$ProcessorConnectionStateCopyWithImpl<$Res,
        $Val extends ProcessorConnectionState>
    implements $ProcessorConnectionStateCopyWith<$Res> {
  _$ProcessorConnectionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProcessorConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? attachment = null,
    Object? network = null,
  }) {
    return _then(_value.copyWith(
      attachment: null == attachment
          ? _value.attachment
          : attachment // ignore: cast_nullable_to_non_nullable
              as VeilidStateAttachment,
      network: null == network
          ? _value.network
          : network // ignore: cast_nullable_to_non_nullable
              as VeilidStateNetwork,
    ) as $Val);
  }

  /// Create a copy of ProcessorConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VeilidStateAttachmentCopyWith<$Res> get attachment {
    return $VeilidStateAttachmentCopyWith<$Res>(_value.attachment, (value) {
      return _then(_value.copyWith(attachment: value) as $Val);
    });
  }

  /// Create a copy of ProcessorConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VeilidStateNetworkCopyWith<$Res> get network {
    return $VeilidStateNetworkCopyWith<$Res>(_value.network, (value) {
      return _then(_value.copyWith(network: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProcessorConnectionStateImplCopyWith<$Res>
    implements $ProcessorConnectionStateCopyWith<$Res> {
  factory _$$ProcessorConnectionStateImplCopyWith(
          _$ProcessorConnectionStateImpl value,
          $Res Function(_$ProcessorConnectionStateImpl) then) =
      __$$ProcessorConnectionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({VeilidStateAttachment attachment, VeilidStateNetwork network});

  @override
  $VeilidStateAttachmentCopyWith<$Res> get attachment;
  @override
  $VeilidStateNetworkCopyWith<$Res> get network;
}

/// @nodoc
class __$$ProcessorConnectionStateImplCopyWithImpl<$Res>
    extends _$ProcessorConnectionStateCopyWithImpl<$Res,
        _$ProcessorConnectionStateImpl>
    implements _$$ProcessorConnectionStateImplCopyWith<$Res> {
  __$$ProcessorConnectionStateImplCopyWithImpl(
      _$ProcessorConnectionStateImpl _value,
      $Res Function(_$ProcessorConnectionStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProcessorConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? attachment = null,
    Object? network = null,
  }) {
    return _then(_$ProcessorConnectionStateImpl(
      attachment: null == attachment
          ? _value.attachment
          : attachment // ignore: cast_nullable_to_non_nullable
              as VeilidStateAttachment,
      network: null == network
          ? _value.network
          : network // ignore: cast_nullable_to_non_nullable
              as VeilidStateNetwork,
    ));
  }
}

/// @nodoc

class _$ProcessorConnectionStateImpl extends _ProcessorConnectionState {
  const _$ProcessorConnectionStateImpl(
      {required this.attachment, required this.network})
      : super._();

  @override
  final VeilidStateAttachment attachment;
  @override
  final VeilidStateNetwork network;

  @override
  String toString() {
    return 'ProcessorConnectionState(attachment: $attachment, network: $network)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProcessorConnectionStateImpl &&
            (identical(other.attachment, attachment) ||
                other.attachment == attachment) &&
            (identical(other.network, network) || other.network == network));
  }

  @override
  int get hashCode => Object.hash(runtimeType, attachment, network);

  /// Create a copy of ProcessorConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProcessorConnectionStateImplCopyWith<_$ProcessorConnectionStateImpl>
      get copyWith => __$$ProcessorConnectionStateImplCopyWithImpl<
          _$ProcessorConnectionStateImpl>(this, _$identity);
}

abstract class _ProcessorConnectionState extends ProcessorConnectionState {
  const factory _ProcessorConnectionState(
          {required final VeilidStateAttachment attachment,
          required final VeilidStateNetwork network}) =
      _$ProcessorConnectionStateImpl;
  const _ProcessorConnectionState._() : super._();

  @override
  VeilidStateAttachment get attachment;
  @override
  VeilidStateNetwork get network;

  /// Create a copy of ProcessorConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProcessorConnectionStateImplCopyWith<_$ProcessorConnectionStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
