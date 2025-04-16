// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IntroductionsState _$IntroductionsStateFromJson(Map<String, dynamic> json) =>
    IntroductionsState(
      contacts: (json['contacts'] as Map<String, dynamic>?)?.map(
            (k, e) =>
                MapEntry(k, CoagContact.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
    );

Map<String, dynamic> _$IntroductionsStateToJson(IntroductionsState instance) =>
    <String, dynamic>{
      'contacts': instance.contacts.map((k, e) => MapEntry(k, e.toJson())),
    };
