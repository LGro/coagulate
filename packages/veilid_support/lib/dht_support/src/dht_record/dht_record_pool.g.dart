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
              json['childrenByParent'] as Map<String, dynamic>,
              (value) => value as String,
              (value) => ISet<Typed<FixedEncodedString43>>.fromJson(value,
                  (value) => Typed<FixedEncodedString43>.fromJson(value))),
      parentByChild: IMap<String, Typed<FixedEncodedString43>>.fromJson(
          json['parentByChild'] as Map<String, dynamic>,
          (value) => value as String,
          (value) => Typed<FixedEncodedString43>.fromJson(value)),
      rootRecords: ISet<Typed<FixedEncodedString43>>.fromJson(
          json['rootRecords'],
          (value) => Typed<FixedEncodedString43>.fromJson(value)),
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
