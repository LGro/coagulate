// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationsState _$LocationsStateFromJson(Map<String, dynamic> json) =>
    LocationsState(
      temporaryLocations: (json['temporary_locations'] as Map<String, dynamic>?)
              ?.map(
            (k, e) => MapEntry(k,
                ContactTemporaryLocation.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
      circleMembersips:
          (json['circle_membersips'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(
                    k, (e as List<dynamic>).map((e) => e as String).toList()),
              ) ??
              const {},
    );

Map<String, dynamic> _$LocationsStateToJson(LocationsState instance) =>
    <String, dynamic>{
      'temporary_locations':
          instance.temporaryLocations.map((k, e) => MapEntry(k, e.toJson())),
      'circle_membersips': instance.circleMembersips,
    };
