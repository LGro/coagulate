// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dht_record_pool.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DHTRecordPoolAllocationsImpl _$$DHTRecordPoolAllocationsImplFromJson(
        Map<String, dynamic> json) =>
    _$DHTRecordPoolAllocationsImpl(
      childrenByParent:
          IMap<String, ISet<Typed<FixedEncodedString43>>>.fromJson(
              json['children_by_parent'] as Map<String, dynamic>,
              (value) => value as String,
              (value) => ISet<Typed<FixedEncodedString43>>.fromJson(value,
                  (value) => Typed<FixedEncodedString43>.fromJson(value))),
      parentByChild: IMap<String, Typed<FixedEncodedString43>>.fromJson(
          json['parent_by_child'] as Map<String, dynamic>,
          (value) => value as String,
          (value) => Typed<FixedEncodedString43>.fromJson(value)),
      rootRecords: ISet<Typed<FixedEncodedString43>>.fromJson(
          json['root_records'],
          (value) => Typed<FixedEncodedString43>.fromJson(value)),
    );

Map<String, dynamic> _$$DHTRecordPoolAllocationsImplToJson(
        _$DHTRecordPoolAllocationsImpl instance) =>
    <String, dynamic>{
      'children_by_parent': instance.childrenByParent.toJson(
        (value) => value,
        (value) => value.toJson(
          (value) => value.toJson(),
        ),
      ),
      'parent_by_child': instance.parentByChild.toJson(
        (value) => value,
        (value) => value.toJson(),
      ),
      'root_records': instance.rootRecords.toJson(
        (value) => value.toJson(),
      ),
    };

_$OwnedDHTRecordPointerImpl _$$OwnedDHTRecordPointerImplFromJson(
        Map<String, dynamic> json) =>
    _$OwnedDHTRecordPointerImpl(
      recordKey: Typed<FixedEncodedString43>.fromJson(json['record_key']),
      owner: KeyPair.fromJson(json['owner']),
    );

Map<String, dynamic> _$$OwnedDHTRecordPointerImplToJson(
        _$OwnedDHTRecordPointerImpl instance) =>
    <String, dynamic>{
      'record_key': instance.recordKey.toJson(),
      'owner': instance.owner.toJson(),
    };
