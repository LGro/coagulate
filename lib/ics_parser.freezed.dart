// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ics_parser.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$IcsEvent {
  DateTime get start;
  DateTime get end;
  String get summary;
  String? get location;
  String? get description;

  /// Create a copy of IcsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $IcsEventCopyWith<IcsEvent> get copyWith =>
      _$IcsEventCopyWithImpl<IcsEvent>(this as IcsEvent, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is IcsEvent &&
            (identical(other.start, start) || other.start == start) &&
            (identical(other.end, end) || other.end == end) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, start, end, summary, location, description);

  @override
  String toString() {
    return 'IcsEvent(start: $start, end: $end, summary: $summary, location: $location, description: $description)';
  }
}

/// @nodoc
abstract mixin class $IcsEventCopyWith<$Res> {
  factory $IcsEventCopyWith(IcsEvent value, $Res Function(IcsEvent) _then) =
      _$IcsEventCopyWithImpl;
  @useResult
  $Res call(
      {DateTime start,
      DateTime end,
      String summary,
      String? location,
      String? description});
}

/// @nodoc
class _$IcsEventCopyWithImpl<$Res> implements $IcsEventCopyWith<$Res> {
  _$IcsEventCopyWithImpl(this._self, this._then);

  final IcsEvent _self;
  final $Res Function(IcsEvent) _then;

  /// Create a copy of IcsEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? start = null,
    Object? end = null,
    Object? summary = null,
    Object? location = freezed,
    Object? description = freezed,
  }) {
    return _then(IcsEvent(
      start: null == start
          ? _self.start
          : start // ignore: cast_nullable_to_non_nullable
              as DateTime,
      end: null == end
          ? _self.end
          : end // ignore: cast_nullable_to_non_nullable
              as DateTime,
      summary: null == summary
          ? _self.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
      location: freezed == location
          ? _self.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
