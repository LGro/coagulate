//
//  Generated code. Do not modify.
//  source: dht.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'veilid.pb.dart' as $0;

class DHTData extends $pb.GeneratedMessage {
  factory DHTData() => create();
  DHTData._() : super();
  factory DHTData.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DHTData.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DHTData', package: const $pb.PackageName(_omitMessageNames ? '' : 'dht'), createEmptyInstance: create)
    ..pc<$0.TypedKey>(1, _omitFieldNames ? '' : 'keys', $pb.PbFieldType.PM, subBuilder: $0.TypedKey.create)
    ..aOM<$0.TypedKey>(2, _omitFieldNames ? '' : 'hash', subBuilder: $0.TypedKey.create)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'chunk', $pb.PbFieldType.OU3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'size', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DHTData clone() => DHTData()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DHTData copyWith(void Function(DHTData) updates) => super.copyWith((message) => updates(message as DHTData)) as DHTData;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DHTData create() => DHTData._();
  DHTData createEmptyInstance() => create();
  static $pb.PbList<DHTData> createRepeated() => $pb.PbList<DHTData>();
  @$core.pragma('dart2js:noInline')
  static DHTData getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DHTData>(create);
  static DHTData? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$0.TypedKey> get keys => $_getList(0);

  @$pb.TagNumber(2)
  $0.TypedKey get hash => $_getN(1);
  @$pb.TagNumber(2)
  set hash($0.TypedKey v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearHash() => clearField(2);
  @$pb.TagNumber(2)
  $0.TypedKey ensureHash() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.int get chunk => $_getIZ(2);
  @$pb.TagNumber(3)
  set chunk($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasChunk() => $_has(2);
  @$pb.TagNumber(3)
  void clearChunk() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get size => $_getIZ(3);
  @$pb.TagNumber(4)
  set size($core.int v) { $_setUnsignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasSize() => $_has(3);
  @$pb.TagNumber(4)
  void clearSize() => clearField(4);
}

class DHTLog extends $pb.GeneratedMessage {
  factory DHTLog() => create();
  DHTLog._() : super();
  factory DHTLog.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DHTLog.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DHTLog', package: const $pb.PackageName(_omitMessageNames ? '' : 'dht'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'head', $pb.PbFieldType.OU3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'tail', $pb.PbFieldType.OU3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'stride', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DHTLog clone() => DHTLog()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DHTLog copyWith(void Function(DHTLog) updates) => super.copyWith((message) => updates(message as DHTLog)) as DHTLog;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DHTLog create() => DHTLog._();
  DHTLog createEmptyInstance() => create();
  static $pb.PbList<DHTLog> createRepeated() => $pb.PbList<DHTLog>();
  @$core.pragma('dart2js:noInline')
  static DHTLog getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DHTLog>(create);
  static DHTLog? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get head => $_getIZ(0);
  @$pb.TagNumber(1)
  set head($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasHead() => $_has(0);
  @$pb.TagNumber(1)
  void clearHead() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get tail => $_getIZ(1);
  @$pb.TagNumber(2)
  set tail($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTail() => $_has(1);
  @$pb.TagNumber(2)
  void clearTail() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get stride => $_getIZ(2);
  @$pb.TagNumber(3)
  set stride($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasStride() => $_has(2);
  @$pb.TagNumber(3)
  void clearStride() => clearField(3);
}

class DHTShortArray extends $pb.GeneratedMessage {
  factory DHTShortArray() => create();
  DHTShortArray._() : super();
  factory DHTShortArray.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DHTShortArray.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DHTShortArray', package: const $pb.PackageName(_omitMessageNames ? '' : 'dht'), createEmptyInstance: create)
    ..pc<$0.TypedKey>(1, _omitFieldNames ? '' : 'keys', $pb.PbFieldType.PM, subBuilder: $0.TypedKey.create)
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'index', $pb.PbFieldType.OY)
    ..p<$core.int>(3, _omitFieldNames ? '' : 'seqs', $pb.PbFieldType.KU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DHTShortArray clone() => DHTShortArray()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DHTShortArray copyWith(void Function(DHTShortArray) updates) => super.copyWith((message) => updates(message as DHTShortArray)) as DHTShortArray;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DHTShortArray create() => DHTShortArray._();
  DHTShortArray createEmptyInstance() => create();
  static $pb.PbList<DHTShortArray> createRepeated() => $pb.PbList<DHTShortArray>();
  @$core.pragma('dart2js:noInline')
  static DHTShortArray getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DHTShortArray>(create);
  static DHTShortArray? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$0.TypedKey> get keys => $_getList(0);

  @$pb.TagNumber(2)
  $core.List<$core.int> get index => $_getN(1);
  @$pb.TagNumber(2)
  set index($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasIndex() => $_has(1);
  @$pb.TagNumber(2)
  void clearIndex() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get seqs => $_getList(2);
}

class OwnedDHTRecordPointer extends $pb.GeneratedMessage {
  factory OwnedDHTRecordPointer() => create();
  OwnedDHTRecordPointer._() : super();
  factory OwnedDHTRecordPointer.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory OwnedDHTRecordPointer.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'OwnedDHTRecordPointer', package: const $pb.PackageName(_omitMessageNames ? '' : 'dht'), createEmptyInstance: create)
    ..aOM<$0.TypedKey>(1, _omitFieldNames ? '' : 'recordKey', subBuilder: $0.TypedKey.create)
    ..aOM<$0.KeyPair>(2, _omitFieldNames ? '' : 'owner', subBuilder: $0.KeyPair.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  OwnedDHTRecordPointer clone() => OwnedDHTRecordPointer()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  OwnedDHTRecordPointer copyWith(void Function(OwnedDHTRecordPointer) updates) => super.copyWith((message) => updates(message as OwnedDHTRecordPointer)) as OwnedDHTRecordPointer;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OwnedDHTRecordPointer create() => OwnedDHTRecordPointer._();
  OwnedDHTRecordPointer createEmptyInstance() => create();
  static $pb.PbList<OwnedDHTRecordPointer> createRepeated() => $pb.PbList<OwnedDHTRecordPointer>();
  @$core.pragma('dart2js:noInline')
  static OwnedDHTRecordPointer getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OwnedDHTRecordPointer>(create);
  static OwnedDHTRecordPointer? _defaultInstance;

  @$pb.TagNumber(1)
  $0.TypedKey get recordKey => $_getN(0);
  @$pb.TagNumber(1)
  set recordKey($0.TypedKey v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasRecordKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearRecordKey() => clearField(1);
  @$pb.TagNumber(1)
  $0.TypedKey ensureRecordKey() => $_ensure(0);

  @$pb.TagNumber(2)
  $0.KeyPair get owner => $_getN(1);
  @$pb.TagNumber(2)
  set owner($0.KeyPair v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasOwner() => $_has(1);
  @$pb.TagNumber(2)
  void clearOwner() => clearField(2);
  @$pb.TagNumber(2)
  $0.KeyPair ensureOwner() => $_ensure(1);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
