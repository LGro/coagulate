// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dht_record_pool.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DHTRecordPoolAllocationsImpl _$$DHTRecordPoolAllocationsImplFromJson(
        Map<String, dynamic> json) =>
    _$DHTRecordPoolAllocationsImpl(
      childrenByParent: json['childrenByParent'] == null
          ? const IMapConst<String, ISet<TypedKey>>({})
          : IMap<String, ISet<Typed<FixedEncodedString43>>>.fromJson(
              json['childrenByParent'] as Map<String, dynamic>,
              (value) => value as String,
              (value) => ISet<Typed<FixedEncodedString43>>.fromJson(value,
                  (value) => Typed<FixedEncodedString43>.fromJson(value))),
      parentByChild: json['parentByChild'] == null
          ? const IMapConst<String, TypedKey>({})
          : IMap<String, Typed<FixedEncodedString43>>.fromJson(
              json['parentByChild'] as Map<String, dynamic>,
              (value) => value as String,
              (value) => Typed<FixedEncodedString43>.fromJson(value)),
      rootRecords: json['rootRecords'] == null
          ? const ISetConst<TypedKey>({})
          : ISet<Typed<FixedEncodedString43>>.fromJson(json['rootRecords'],
              (value) => Typed<FixedEncodedString43>.fromJson(value)),
      debugNames: json['debugNames'] == null
          ? const IMapConst<String, String>({})
          : IMap<String, String>.fromJson(
              json['debugNames'] as Map<String, dynamic>,
              (value) => value as String,
              (value) => value as String),
    );

Map<String, dynamic> _$$DHTRecordPoolAllocationsImplToJson(
        _$DHTRecordPoolAllocationsImpl instance) =>
    <String, dynamic>{
      'childrenByParent': instance.childrenByParent.toJson(
        (value) => value,
        (value) => value.toJson(
          (value) => value,
        ),
      ),
      'parentByChild': instance.parentByChild.toJson(
        (value) => value,
        (value) => value,
      ),
      'rootRecords': instance.rootRecords.toJson(
        (value) => value,
      ),
      'debugNames': instance.debugNames.toJson(
        (value) => value,
        (value) => value,
      ),
    };

_$OwnedDHTRecordPointerImpl _$$OwnedDHTRecordPointerImplFromJson(
        Map<String, dynamic> json) =>
    _$OwnedDHTRecordPointerImpl(
      recordKey: Typed<FixedEncodedString43>.fromJson(json['recordKey']),
      owner: KeyPair.fromJson(json['owner']),
    );

Map<String, dynamic> _$$OwnedDHTRecordPointerImplToJson(
        _$OwnedDHTRecordPointerImpl instance) =>
    <String, dynamic>{
      'recordKey': instance.recordKey,
      'owner': instance.owner,
    };
