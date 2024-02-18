// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_contact_cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileContactState _$ProfileContactStateFromJson(Map<String, dynamic> json) =>
    ProfileContactState(
      status:
          $enumDecodeNullable(_$ProfileContactStatusEnumMap, json['status']) ??
              ProfileContactStatus.initial,
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

Map<String, dynamic> _$ProfileContactStateToJson(
        ProfileContactState instance) =>
    <String, dynamic>{
      'status': _$ProfileContactStatusEnumMap[instance.status]!,
      'profile_contact': instance.profileContact?.toJson(),
      'location_coordinates':
          instance.locationCoordinates?.map((k, e) => MapEntry(k, {
                r'$1': e.$1,
                r'$2': e.$2,
              })),
    };

const _$ProfileContactStatusEnumMap = {
  ProfileContactStatus.initial: 'initial',
  ProfileContactStatus.success: 'success',
  ProfileContactStatus.create: 'create',
  ProfileContactStatus.pick: 'pick',
};

$Rec _$recordConvert<$Rec>(
  Object? value,
  $Rec Function(Map) convert,
) =>
    convert(value as Map<String, dynamic>);
