// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'super_identity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SuperIdentityImpl _$$SuperIdentityImplFromJson(Map<String, dynamic> json) =>
    _$SuperIdentityImpl(
      recordKey: Typed<FixedEncodedString43>.fromJson(json['record_key']),
      publicKey: FixedEncodedString43.fromJson(json['public_key']),
      currentInstance: IdentityInstance.fromJson(json['current_instance']),
      deprecatedInstances: (json['deprecated_instances'] as List<dynamic>)
          .map(IdentityInstance.fromJson)
          .toList(),
      deprecatedSuperRecordKeys:
          (json['deprecated_super_record_keys'] as List<dynamic>)
              .map(Typed<FixedEncodedString43>.fromJson)
              .toList(),
      signature: FixedEncodedString86.fromJson(json['signature']),
    );

Map<String, dynamic> _$$SuperIdentityImplToJson(_$SuperIdentityImpl instance) =>
    <String, dynamic>{
      'record_key': instance.recordKey.toJson(),
      'public_key': instance.publicKey.toJson(),
      'current_instance': instance.currentInstance.toJson(),
      'deprecated_instances':
          instance.deprecatedInstances.map((e) => e.toJson()).toList(),
      'deprecated_super_record_keys':
          instance.deprecatedSuperRecordKeys.map((e) => e.toJson()).toList(),
      'signature': instance.signature.toJson(),
    };
