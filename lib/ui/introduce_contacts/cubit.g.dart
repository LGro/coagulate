// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IntroduceContactsState _$IntroduceContactsStateFromJson(
        Map<String, dynamic> json) =>
    IntroduceContactsState(
      $enumDecode(_$IntroduceContactsStatusEnumMap, json['status']),
      contacts: (json['contacts'] as List<dynamic>?)
              ?.map((e) => CoagContact.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$IntroduceContactsStateToJson(
        IntroduceContactsState instance) =>
    <String, dynamic>{
      'status': _$IntroduceContactsStatusEnumMap[instance.status]!,
      'contacts': instance.contacts.map((e) => e.toJson()).toList(),
    };

const _$IntroduceContactsStatusEnumMap = {
  IntroduceContactsStatus.initial: 'initial',
  IntroduceContactsStatus.success: 'success',
  IntroduceContactsStatus.create: 'create',
  IntroduceContactsStatus.pick: 'pick',
};
