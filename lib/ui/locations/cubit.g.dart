// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationsState _$LocationsStateFromJson(Map<String, dynamic> json) =>
    LocationsState(
      temporaryLocations: (json['temporary_locations'] as List<dynamic>?)?.map(
              (e) => ContactTemporaryLocation.fromJson(
                  e as Map<String, dynamic>)) ??
          const [],
    );

Map<String, dynamic> _$LocationsStateToJson(LocationsState instance) =>
    <String, dynamic>{
      'temporary_locations':
          instance.temporaryLocations.map((e) => e.toJson()).toList(),
    };
