// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CirclesState _$CirclesStateFromJson(Map<String, dynamic> json) => CirclesState(
      (json['circles'] as List<dynamic>)
          .map((e) => _$recordConvert(
                e,
                ($jsonValue) => (
                  $jsonValue[r'$1'] as String,
                  $jsonValue[r'$2'] as String,
                  $jsonValue[r'$3'] as bool,
                  ($jsonValue[r'$4'] as num).toInt(),
                ),
              ))
          .toList(),
    );

Map<String, dynamic> _$CirclesStateToJson(CirclesState instance) =>
    <String, dynamic>{
      'circles': instance.circles
          .map((e) => <String, dynamic>{
                r'$1': e.$1,
                r'$2': e.$2,
                r'$3': e.$3,
                r'$4': e.$4,
              })
          .toList(),
    };

$Rec _$recordConvert<$Rec>(
  Object? value,
  $Rec Function(Map) convert,
) =>
    convert(value as Map<String, dynamic>);
