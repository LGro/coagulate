// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'processor_connection_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProcessorConnectionState {
  VeilidStateAttachment get attachment;
  VeilidStateNetwork get network;

  /// Create a copy of ProcessorConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ProcessorConnectionStateCopyWith<ProcessorConnectionState> get copyWith =>
      _$ProcessorConnectionStateCopyWithImpl<ProcessorConnectionState>(
          this as ProcessorConnectionState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ProcessorConnectionState &&
            (identical(other.attachment, attachment) ||
                other.attachment == attachment) &&
            (identical(other.network, network) || other.network == network));
  }

  @override
  int get hashCode => Object.hash(runtimeType, attachment, network);

  @override
  String toString() {
    return 'ProcessorConnectionState(attachment: $attachment, network: $network)';
  }
}

/// @nodoc
abstract mixin class $ProcessorConnectionStateCopyWith<$Res> {
  factory $ProcessorConnectionStateCopyWith(ProcessorConnectionState value,
          $Res Function(ProcessorConnectionState) _then) =
      _$ProcessorConnectionStateCopyWithImpl;
  @useResult
  $Res call({VeilidStateAttachment attachment, VeilidStateNetwork network});

  $VeilidStateAttachmentCopyWith<$Res> get attachment;
  $VeilidStateNetworkCopyWith<$Res> get network;
}

/// @nodoc
class _$ProcessorConnectionStateCopyWithImpl<$Res>
    implements $ProcessorConnectionStateCopyWith<$Res> {
  _$ProcessorConnectionStateCopyWithImpl(this._self, this._then);

  final ProcessorConnectionState _self;
  final $Res Function(ProcessorConnectionState) _then;

  /// Create a copy of ProcessorConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? attachment = null,
    Object? network = null,
  }) {
    return _then(_self.copyWith(
      attachment: null == attachment
          ? _self.attachment
          : attachment // ignore: cast_nullable_to_non_nullable
              as VeilidStateAttachment,
      network: null == network
          ? _self.network
          : network // ignore: cast_nullable_to_non_nullable
              as VeilidStateNetwork,
    ));
  }

  /// Create a copy of ProcessorConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VeilidStateAttachmentCopyWith<$Res> get attachment {
    return $VeilidStateAttachmentCopyWith<$Res>(_self.attachment, (value) {
      return _then(_self.copyWith(attachment: value));
    });
  }

  /// Create a copy of ProcessorConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VeilidStateNetworkCopyWith<$Res> get network {
    return $VeilidStateNetworkCopyWith<$Res>(_self.network, (value) {
      return _then(_self.copyWith(network: value));
    });
  }
}

/// @nodoc

class _ProcessorConnectionState extends ProcessorConnectionState {
  const _ProcessorConnectionState(
      {required this.attachment, required this.network})
      : super._();

  @override
  final VeilidStateAttachment attachment;
  @override
  final VeilidStateNetwork network;

  /// Create a copy of ProcessorConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ProcessorConnectionStateCopyWith<_ProcessorConnectionState> get copyWith =>
      __$ProcessorConnectionStateCopyWithImpl<_ProcessorConnectionState>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ProcessorConnectionState &&
            (identical(other.attachment, attachment) ||
                other.attachment == attachment) &&
            (identical(other.network, network) || other.network == network));
  }

  @override
  int get hashCode => Object.hash(runtimeType, attachment, network);

  @override
  String toString() {
    return 'ProcessorConnectionState(attachment: $attachment, network: $network)';
  }
}

/// @nodoc
abstract mixin class _$ProcessorConnectionStateCopyWith<$Res>
    implements $ProcessorConnectionStateCopyWith<$Res> {
  factory _$ProcessorConnectionStateCopyWith(_ProcessorConnectionState value,
          $Res Function(_ProcessorConnectionState) _then) =
      __$ProcessorConnectionStateCopyWithImpl;
  @override
  @useResult
  $Res call({VeilidStateAttachment attachment, VeilidStateNetwork network});

  @override
  $VeilidStateAttachmentCopyWith<$Res> get attachment;
  @override
  $VeilidStateNetworkCopyWith<$Res> get network;
}

/// @nodoc
class __$ProcessorConnectionStateCopyWithImpl<$Res>
    implements _$ProcessorConnectionStateCopyWith<$Res> {
  __$ProcessorConnectionStateCopyWithImpl(this._self, this._then);

  final _ProcessorConnectionState _self;
  final $Res Function(_ProcessorConnectionState) _then;

  /// Create a copy of ProcessorConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? attachment = null,
    Object? network = null,
  }) {
    return _then(_ProcessorConnectionState(
      attachment: null == attachment
          ? _self.attachment
          : attachment // ignore: cast_nullable_to_non_nullable
              as VeilidStateAttachment,
      network: null == network
          ? _self.network
          : network // ignore: cast_nullable_to_non_nullable
              as VeilidStateNetwork,
    ));
  }

  /// Create a copy of ProcessorConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VeilidStateAttachmentCopyWith<$Res> get attachment {
    return $VeilidStateAttachmentCopyWith<$Res>(_self.attachment, (value) {
      return _then(_self.copyWith(attachment: value));
    });
  }

  /// Create a copy of ProcessorConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VeilidStateNetworkCopyWith<$Res> get network {
    return $VeilidStateNetworkCopyWith<$Res>(_self.network, (value) {
      return _then(_self.copyWith(network: value));
    });
  }
}

// dart format on
