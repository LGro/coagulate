// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dht_record_pool.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DHTRecordPoolAllocations _$DHTRecordPoolAllocationsFromJson(
        Map<String, dynamic> json) =>
    _DHTRecordPoolAllocations(
      childrenByParent: json['children_by_parent'] == null
          ? const IMapConst<String, ISet<TypedKey>>({})
          : IMap<String, ISet<Typed<FixedEncodedString43>>>.fromJson(
              json['children_by_parent'] as Map<String, dynamic>,
              (value) => value as String,
              (value) => ISet<Typed<FixedEncodedString43>>.fromJson(value,
                  (value) => Typed<FixedEncodedString43>.fromJson(value))),
      parentByChild: json['parent_by_child'] == null
          ? const IMapConst<String, TypedKey>({})
          : IMap<String, Typed<FixedEncodedString43>>.fromJson(
              json['parent_by_child'] as Map<String, dynamic>,
              (value) => value as String,
              (value) => Typed<FixedEncodedString43>.fromJson(value)),
      rootRecords: json['root_records'] == null
          ? const ISetConst<TypedKey>({})
          : ISet<Typed<FixedEncodedString43>>.fromJson(json['root_records'],
              (value) => Typed<FixedEncodedString43>.fromJson(value)),
      debugNames: json['debug_names'] == null
          ? const IMapConst<String, String>({})
          : IMap<String, String>.fromJson(
              json['debug_names'] as Map<String, dynamic>,
              (value) => value as String,
              (value) => value as String),
    );

Map<String, dynamic> _$DHTRecordPoolAllocationsToJson(
        _DHTRecordPoolAllocations instance) =>
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
      'debug_names': instance.debugNames.toJson(
        (value) => value,
        (value) => value,
      ),
    };

_OwnedDHTRecordPointer _$OwnedDHTRecordPointerFromJson(
        Map<String, dynamic> json) =>
    _OwnedDHTRecordPointer(
      recordKey: Typed<FixedEncodedString43>.fromJson(json['record_key']),
      owner: KeyPair.fromJson(json['owner']),
    );

Map<String, dynamic> _$OwnedDHTRecordPointerToJson(
        _OwnedDHTRecordPointer instance) =>
    <String, dynamic>{
      'record_key': instance.recordKey.toJson(),
      'owner': instance.owner.toJson(),
    };
