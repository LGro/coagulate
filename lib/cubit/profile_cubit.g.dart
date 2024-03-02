// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileState _$ProfileStateFromJson(Map<String, dynamic> json) => ProfileState(
      status: $enumDecodeNullable(_$ProfileStatusEnumMap, json['status']) ??
          ProfileStatus.initial,
      profileContact: json['profile_contact'] == null
          ? null
          : Contact.fromJson(json['profile_contact'] as Map<String, dynamic>),
      locationCoordinates:
          (json['location_coordinates'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
            k,
            _$recordConvert(
              e,
              ($jsonValue) => (
                $jsonValue[r'$1'] as num,
                $jsonValue[r'$2'] as num,
              ),
            )),
      ),
    );

Map<String, dynamic> _$ProfileStateToJson(ProfileState instance) =>
    <String, dynamic>{
      'status': _$ProfileStatusEnumMap[instance.status]!,
      'profile_contact': instance.profileContact?.toJson(),
      'location_coordinates':
          instance.locationCoordinates?.map((k, e) => MapEntry(k, {
                r'$1': e.$1,
                r'$2': e.$2,
              })),
    };

const _$ProfileStatusEnumMap = {
  ProfileStatus.initial: 'initial',
  ProfileStatus.success: 'success',
  ProfileStatus.create: 'create',
  ProfileStatus.pick: 'pick',
};

$Rec _$recordConvert<$Rec>(
  Object? value,
  $Rec Function(Map) convert,
) =>
    convert(value as Map<String, dynamic>);
