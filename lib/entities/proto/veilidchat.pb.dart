//
//  Generated code. Do not modify.
//  source: veilidchat.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'veilidchat.pbenum.dart';

export 'veilidchat.pbenum.dart';

class CryptoKey extends $pb.GeneratedMessage {
  factory CryptoKey() => create();
  CryptoKey._() : super();
  factory CryptoKey.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CryptoKey.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CryptoKey', createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'u0', $pb.PbFieldType.OF3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'u1', $pb.PbFieldType.OF3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'u2', $pb.PbFieldType.OF3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'u3', $pb.PbFieldType.OF3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'u4', $pb.PbFieldType.OF3)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'u5', $pb.PbFieldType.OF3)
    ..a<$core.int>(7, _omitFieldNames ? '' : 'u6', $pb.PbFieldType.OF3)
    ..a<$core.int>(8, _omitFieldNames ? '' : 'u7', $pb.PbFieldType.OF3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CryptoKey clone() => CryptoKey()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CryptoKey copyWith(void Function(CryptoKey) updates) => super.copyWith((message) => updates(message as CryptoKey)) as CryptoKey;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CryptoKey create() => CryptoKey._();
  CryptoKey createEmptyInstance() => create();
  static $pb.PbList<CryptoKey> createRepeated() => $pb.PbList<CryptoKey>();
  @$core.pragma('dart2js:noInline')
  static CryptoKey getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CryptoKey>(create);
  static CryptoKey? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get u0 => $_getIZ(0);
  @$pb.TagNumber(1)
  set u0($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasU0() => $_has(0);
  @$pb.TagNumber(1)
  void clearU0() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get u1 => $_getIZ(1);
  @$pb.TagNumber(2)
  set u1($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasU1() => $_has(1);
  @$pb.TagNumber(2)
  void clearU1() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get u2 => $_getIZ(2);
  @$pb.TagNumber(3)
  set u2($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasU2() => $_has(2);
  @$pb.TagNumber(3)
  void clearU2() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get u3 => $_getIZ(3);
  @$pb.TagNumber(4)
  set u3($core.int v) { $_setUnsignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasU3() => $_has(3);
  @$pb.TagNumber(4)
  void clearU3() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get u4 => $_getIZ(4);
  @$pb.TagNumber(5)
  set u4($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasU4() => $_has(4);
  @$pb.TagNumber(5)
  void clearU4() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get u5 => $_getIZ(5);
  @$pb.TagNumber(6)
  set u5($core.int v) { $_setUnsignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasU5() => $_has(5);
  @$pb.TagNumber(6)
  void clearU5() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get u6 => $_getIZ(6);
  @$pb.TagNumber(7)
  set u6($core.int v) { $_setUnsignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasU6() => $_has(6);
  @$pb.TagNumber(7)
  void clearU6() => clearField(7);

  @$pb.TagNumber(8)
  $core.int get u7 => $_getIZ(7);
  @$pb.TagNumber(8)
  set u7($core.int v) { $_setUnsignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasU7() => $_has(7);
  @$pb.TagNumber(8)
  void clearU7() => clearField(8);
}

class Signature extends $pb.GeneratedMessage {
  factory Signature() => create();
  Signature._() : super();
  factory Signature.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Signature.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Signature', createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'u0', $pb.PbFieldType.OF3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'u1', $pb.PbFieldType.OF3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'u2', $pb.PbFieldType.OF3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'u3', $pb.PbFieldType.OF3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'u4', $pb.PbFieldType.OF3)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'u5', $pb.PbFieldType.OF3)
    ..a<$core.int>(7, _omitFieldNames ? '' : 'u6', $pb.PbFieldType.OF3)
    ..a<$core.int>(8, _omitFieldNames ? '' : 'u7', $pb.PbFieldType.OF3)
    ..a<$core.int>(9, _omitFieldNames ? '' : 'u8', $pb.PbFieldType.OF3)
    ..a<$core.int>(10, _omitFieldNames ? '' : 'u9', $pb.PbFieldType.OF3)
    ..a<$core.int>(11, _omitFieldNames ? '' : 'u10', $pb.PbFieldType.OF3)
    ..a<$core.int>(12, _omitFieldNames ? '' : 'u11', $pb.PbFieldType.OF3)
    ..a<$core.int>(13, _omitFieldNames ? '' : 'u12', $pb.PbFieldType.OF3)
    ..a<$core.int>(14, _omitFieldNames ? '' : 'u13', $pb.PbFieldType.OF3)
    ..a<$core.int>(15, _omitFieldNames ? '' : 'u14', $pb.PbFieldType.OF3)
    ..a<$core.int>(16, _omitFieldNames ? '' : 'u15', $pb.PbFieldType.OF3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Signature clone() => Signature()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Signature copyWith(void Function(Signature) updates) => super.copyWith((message) => updates(message as Signature)) as Signature;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Signature create() => Signature._();
  Signature createEmptyInstance() => create();
  static $pb.PbList<Signature> createRepeated() => $pb.PbList<Signature>();
  @$core.pragma('dart2js:noInline')
  static Signature getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Signature>(create);
  static Signature? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get u0 => $_getIZ(0);
  @$pb.TagNumber(1)
  set u0($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasU0() => $_has(0);
  @$pb.TagNumber(1)
  void clearU0() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get u1 => $_getIZ(1);
  @$pb.TagNumber(2)
  set u1($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasU1() => $_has(1);
  @$pb.TagNumber(2)
  void clearU1() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get u2 => $_getIZ(2);
  @$pb.TagNumber(3)
  set u2($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasU2() => $_has(2);
  @$pb.TagNumber(3)
  void clearU2() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get u3 => $_getIZ(3);
  @$pb.TagNumber(4)
  set u3($core.int v) { $_setUnsignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasU3() => $_has(3);
  @$pb.TagNumber(4)
  void clearU3() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get u4 => $_getIZ(4);
  @$pb.TagNumber(5)
  set u4($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasU4() => $_has(4);
  @$pb.TagNumber(5)
  void clearU4() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get u5 => $_getIZ(5);
  @$pb.TagNumber(6)
  set u5($core.int v) { $_setUnsignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasU5() => $_has(5);
  @$pb.TagNumber(6)
  void clearU5() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get u6 => $_getIZ(6);
  @$pb.TagNumber(7)
  set u6($core.int v) { $_setUnsignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasU6() => $_has(6);
  @$pb.TagNumber(7)
  void clearU6() => clearField(7);

  @$pb.TagNumber(8)
  $core.int get u7 => $_getIZ(7);
  @$pb.TagNumber(8)
  set u7($core.int v) { $_setUnsignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasU7() => $_has(7);
  @$pb.TagNumber(8)
  void clearU7() => clearField(8);

  @$pb.TagNumber(9)
  $core.int get u8 => $_getIZ(8);
  @$pb.TagNumber(9)
  set u8($core.int v) { $_setUnsignedInt32(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasU8() => $_has(8);
  @$pb.TagNumber(9)
  void clearU8() => clearField(9);

  @$pb.TagNumber(10)
  $core.int get u9 => $_getIZ(9);
  @$pb.TagNumber(10)
  set u9($core.int v) { $_setUnsignedInt32(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasU9() => $_has(9);
  @$pb.TagNumber(10)
  void clearU9() => clearField(10);

  @$pb.TagNumber(11)
  $core.int get u10 => $_getIZ(10);
  @$pb.TagNumber(11)
  set u10($core.int v) { $_setUnsignedInt32(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasU10() => $_has(10);
  @$pb.TagNumber(11)
  void clearU10() => clearField(11);

  @$pb.TagNumber(12)
  $core.int get u11 => $_getIZ(11);
  @$pb.TagNumber(12)
  set u11($core.int v) { $_setUnsignedInt32(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasU11() => $_has(11);
  @$pb.TagNumber(12)
  void clearU11() => clearField(12);

  @$pb.TagNumber(13)
  $core.int get u12 => $_getIZ(12);
  @$pb.TagNumber(13)
  set u12($core.int v) { $_setUnsignedInt32(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasU12() => $_has(12);
  @$pb.TagNumber(13)
  void clearU12() => clearField(13);

  @$pb.TagNumber(14)
  $core.int get u13 => $_getIZ(13);
  @$pb.TagNumber(14)
  set u13($core.int v) { $_setUnsignedInt32(13, v); }
  @$pb.TagNumber(14)
  $core.bool hasU13() => $_has(13);
  @$pb.TagNumber(14)
  void clearU13() => clearField(14);

  @$pb.TagNumber(15)
  $core.int get u14 => $_getIZ(14);
  @$pb.TagNumber(15)
  set u14($core.int v) { $_setUnsignedInt32(14, v); }
  @$pb.TagNumber(15)
  $core.bool hasU14() => $_has(14);
  @$pb.TagNumber(15)
  void clearU14() => clearField(15);

  @$pb.TagNumber(16)
  $core.int get u15 => $_getIZ(15);
  @$pb.TagNumber(16)
  set u15($core.int v) { $_setUnsignedInt32(15, v); }
  @$pb.TagNumber(16)
  $core.bool hasU15() => $_has(15);
  @$pb.TagNumber(16)
  void clearU15() => clearField(16);
}

class Nonce extends $pb.GeneratedMessage {
  factory Nonce() => create();
  Nonce._() : super();
  factory Nonce.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Nonce.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Nonce', createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'u0', $pb.PbFieldType.OF3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'u1', $pb.PbFieldType.OF3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'u2', $pb.PbFieldType.OF3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'u3', $pb.PbFieldType.OF3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'u4', $pb.PbFieldType.OF3)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'u5', $pb.PbFieldType.OF3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Nonce clone() => Nonce()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Nonce copyWith(void Function(Nonce) updates) => super.copyWith((message) => updates(message as Nonce)) as Nonce;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Nonce create() => Nonce._();
  Nonce createEmptyInstance() => create();
  static $pb.PbList<Nonce> createRepeated() => $pb.PbList<Nonce>();
  @$core.pragma('dart2js:noInline')
  static Nonce getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Nonce>(create);
  static Nonce? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get u0 => $_getIZ(0);
  @$pb.TagNumber(1)
  set u0($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasU0() => $_has(0);
  @$pb.TagNumber(1)
  void clearU0() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get u1 => $_getIZ(1);
  @$pb.TagNumber(2)
  set u1($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasU1() => $_has(1);
  @$pb.TagNumber(2)
  void clearU1() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get u2 => $_getIZ(2);
  @$pb.TagNumber(3)
  set u2($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasU2() => $_has(2);
  @$pb.TagNumber(3)
  void clearU2() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get u3 => $_getIZ(3);
  @$pb.TagNumber(4)
  set u3($core.int v) { $_setUnsignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasU3() => $_has(3);
  @$pb.TagNumber(4)
  void clearU3() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get u4 => $_getIZ(4);
  @$pb.TagNumber(5)
  set u4($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasU4() => $_has(4);
  @$pb.TagNumber(5)
  void clearU4() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get u5 => $_getIZ(5);
  @$pb.TagNumber(6)
  set u5($core.int v) { $_setUnsignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasU5() => $_has(5);
  @$pb.TagNumber(6)
  void clearU5() => clearField(6);
}

class TypedKey extends $pb.GeneratedMessage {
  factory TypedKey() => create();
  TypedKey._() : super();
  factory TypedKey.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TypedKey.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TypedKey', createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'kind', $pb.PbFieldType.OF3)
    ..aOM<CryptoKey>(2, _omitFieldNames ? '' : 'value', subBuilder: CryptoKey.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TypedKey clone() => TypedKey()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TypedKey copyWith(void Function(TypedKey) updates) => super.copyWith((message) => updates(message as TypedKey)) as TypedKey;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TypedKey create() => TypedKey._();
  TypedKey createEmptyInstance() => create();
  static $pb.PbList<TypedKey> createRepeated() => $pb.PbList<TypedKey>();
  @$core.pragma('dart2js:noInline')
  static TypedKey getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TypedKey>(create);
  static TypedKey? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get kind => $_getIZ(0);
  @$pb.TagNumber(1)
  set kind($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasKind() => $_has(0);
  @$pb.TagNumber(1)
  void clearKind() => clearField(1);

  @$pb.TagNumber(2)
  CryptoKey get value => $_getN(1);
  @$pb.TagNumber(2)
  set value(CryptoKey v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => clearField(2);
  @$pb.TagNumber(2)
  CryptoKey ensureValue() => $_ensure(1);
}

class DHTData extends $pb.GeneratedMessage {
  factory DHTData() => create();
  DHTData._() : super();
  factory DHTData.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DHTData.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DHTData', createEmptyInstance: create)
    ..pc<TypedKey>(1, _omitFieldNames ? '' : 'keys', $pb.PbFieldType.PM, subBuilder: TypedKey.create)
    ..aOM<TypedKey>(2, _omitFieldNames ? '' : 'hash', subBuilder: TypedKey.create)
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
  $core.List<TypedKey> get keys => $_getList(0);

  @$pb.TagNumber(2)
  TypedKey get hash => $_getN(1);
  @$pb.TagNumber(2)
  set hash(TypedKey v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearHash() => clearField(2);
  @$pb.TagNumber(2)
  TypedKey ensureHash() => $_ensure(1);

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

class DHTList extends $pb.GeneratedMessage {
  factory DHTList() => create();
  DHTList._() : super();
  factory DHTList.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DHTList.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DHTList', createEmptyInstance: create)
    ..pc<TypedKey>(1, _omitFieldNames ? '' : 'keys', $pb.PbFieldType.PM, subBuilder: TypedKey.create)
    ..p<$core.int>(2, _omitFieldNames ? '' : 'index', $pb.PbFieldType.KU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DHTList clone() => DHTList()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DHTList copyWith(void Function(DHTList) updates) => super.copyWith((message) => updates(message as DHTList)) as DHTList;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DHTList create() => DHTList._();
  DHTList createEmptyInstance() => create();
  static $pb.PbList<DHTList> createRepeated() => $pb.PbList<DHTList>();
  @$core.pragma('dart2js:noInline')
  static DHTList getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DHTList>(create);
  static DHTList? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<TypedKey> get keys => $_getList(0);

  @$pb.TagNumber(2)
  $core.List<$core.int> get index => $_getList(1);
}

class DHTLog extends $pb.GeneratedMessage {
  factory DHTLog() => create();
  DHTLog._() : super();
  factory DHTLog.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DHTLog.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DHTLog', createEmptyInstance: create)
    ..pc<TypedKey>(1, _omitFieldNames ? '' : 'keys', $pb.PbFieldType.PM, subBuilder: TypedKey.create)
    ..aOM<TypedKey>(2, _omitFieldNames ? '' : 'back', subBuilder: TypedKey.create)
    ..p<$core.int>(3, _omitFieldNames ? '' : 'subkeyCounts', $pb.PbFieldType.KU3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'totalSubkeys', $pb.PbFieldType.OU3)
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
  $core.List<TypedKey> get keys => $_getList(0);

  @$pb.TagNumber(2)
  TypedKey get back => $_getN(1);
  @$pb.TagNumber(2)
  set back(TypedKey v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasBack() => $_has(1);
  @$pb.TagNumber(2)
  void clearBack() => clearField(2);
  @$pb.TagNumber(2)
  TypedKey ensureBack() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.List<$core.int> get subkeyCounts => $_getList(2);

  @$pb.TagNumber(4)
  $core.int get totalSubkeys => $_getIZ(3);
  @$pb.TagNumber(4)
  set totalSubkeys($core.int v) { $_setUnsignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasTotalSubkeys() => $_has(3);
  @$pb.TagNumber(4)
  void clearTotalSubkeys() => clearField(4);
}

enum DataReference_Kind {
  dhtData, 
  notSet
}

class DataReference extends $pb.GeneratedMessage {
  factory DataReference() => create();
  DataReference._() : super();
  factory DataReference.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DataReference.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, DataReference_Kind> _DataReference_KindByTag = {
    1 : DataReference_Kind.dhtData,
    0 : DataReference_Kind.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DataReference', createEmptyInstance: create)
    ..oo(0, [1])
    ..aOM<TypedKey>(1, _omitFieldNames ? '' : 'dhtData', subBuilder: TypedKey.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DataReference clone() => DataReference()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DataReference copyWith(void Function(DataReference) updates) => super.copyWith((message) => updates(message as DataReference)) as DataReference;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DataReference create() => DataReference._();
  DataReference createEmptyInstance() => create();
  static $pb.PbList<DataReference> createRepeated() => $pb.PbList<DataReference>();
  @$core.pragma('dart2js:noInline')
  static DataReference getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DataReference>(create);
  static DataReference? _defaultInstance;

  DataReference_Kind whichKind() => _DataReference_KindByTag[$_whichOneof(0)]!;
  void clearKind() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  TypedKey get dhtData => $_getN(0);
  @$pb.TagNumber(1)
  set dhtData(TypedKey v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasDhtData() => $_has(0);
  @$pb.TagNumber(1)
  void clearDhtData() => clearField(1);
  @$pb.TagNumber(1)
  TypedKey ensureDhtData() => $_ensure(0);
}

class Attachment extends $pb.GeneratedMessage {
  factory Attachment() => create();
  Attachment._() : super();
  factory Attachment.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Attachment.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Attachment', createEmptyInstance: create)
    ..e<AttachmentKind>(1, _omitFieldNames ? '' : 'kind', $pb.PbFieldType.OE, defaultOrMaker: AttachmentKind.ATTACHMENT_KIND_UNSPECIFIED, valueOf: AttachmentKind.valueOf, enumValues: AttachmentKind.values)
    ..aOS(2, _omitFieldNames ? '' : 'mime')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOM<DataReference>(4, _omitFieldNames ? '' : 'content', subBuilder: DataReference.create)
    ..aOM<Signature>(5, _omitFieldNames ? '' : 'signature', subBuilder: Signature.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Attachment clone() => Attachment()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Attachment copyWith(void Function(Attachment) updates) => super.copyWith((message) => updates(message as Attachment)) as Attachment;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Attachment create() => Attachment._();
  Attachment createEmptyInstance() => create();
  static $pb.PbList<Attachment> createRepeated() => $pb.PbList<Attachment>();
  @$core.pragma('dart2js:noInline')
  static Attachment getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Attachment>(create);
  static Attachment? _defaultInstance;

  @$pb.TagNumber(1)
  AttachmentKind get kind => $_getN(0);
  @$pb.TagNumber(1)
  set kind(AttachmentKind v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasKind() => $_has(0);
  @$pb.TagNumber(1)
  void clearKind() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get mime => $_getSZ(1);
  @$pb.TagNumber(2)
  set mime($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMime() => $_has(1);
  @$pb.TagNumber(2)
  void clearMime() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => clearField(3);

  @$pb.TagNumber(4)
  DataReference get content => $_getN(3);
  @$pb.TagNumber(4)
  set content(DataReference v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasContent() => $_has(3);
  @$pb.TagNumber(4)
  void clearContent() => clearField(4);
  @$pb.TagNumber(4)
  DataReference ensureContent() => $_ensure(3);

  @$pb.TagNumber(5)
  Signature get signature => $_getN(4);
  @$pb.TagNumber(5)
  set signature(Signature v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasSignature() => $_has(4);
  @$pb.TagNumber(5)
  void clearSignature() => clearField(5);
  @$pb.TagNumber(5)
  Signature ensureSignature() => $_ensure(4);
}

class Message extends $pb.GeneratedMessage {
  factory Message() => create();
  Message._() : super();
  factory Message.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Message.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Message', createEmptyInstance: create)
    ..aOM<TypedKey>(1, _omitFieldNames ? '' : 'author', subBuilder: TypedKey.create)
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'timestamp', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(3, _omitFieldNames ? '' : 'text')
    ..aOM<Signature>(4, _omitFieldNames ? '' : 'signature', subBuilder: Signature.create)
    ..pc<Attachment>(5, _omitFieldNames ? '' : 'attachments', $pb.PbFieldType.PM, subBuilder: Attachment.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Message clone() => Message()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Message copyWith(void Function(Message) updates) => super.copyWith((message) => updates(message as Message)) as Message;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Message create() => Message._();
  Message createEmptyInstance() => create();
  static $pb.PbList<Message> createRepeated() => $pb.PbList<Message>();
  @$core.pragma('dart2js:noInline')
  static Message getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Message>(create);
  static Message? _defaultInstance;

  @$pb.TagNumber(1)
  TypedKey get author => $_getN(0);
  @$pb.TagNumber(1)
  set author(TypedKey v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasAuthor() => $_has(0);
  @$pb.TagNumber(1)
  void clearAuthor() => clearField(1);
  @$pb.TagNumber(1)
  TypedKey ensureAuthor() => $_ensure(0);

  @$pb.TagNumber(2)
  $fixnum.Int64 get timestamp => $_getI64(1);
  @$pb.TagNumber(2)
  set timestamp($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get text => $_getSZ(2);
  @$pb.TagNumber(3)
  set text($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasText() => $_has(2);
  @$pb.TagNumber(3)
  void clearText() => clearField(3);

  @$pb.TagNumber(4)
  Signature get signature => $_getN(3);
  @$pb.TagNumber(4)
  set signature(Signature v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasSignature() => $_has(3);
  @$pb.TagNumber(4)
  void clearSignature() => clearField(4);
  @$pb.TagNumber(4)
  Signature ensureSignature() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.List<Attachment> get attachments => $_getList(4);
}

class Conversation extends $pb.GeneratedMessage {
  factory Conversation() => create();
  Conversation._() : super();
  factory Conversation.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Conversation.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Conversation', createEmptyInstance: create)
    ..aOM<Profile>(1, _omitFieldNames ? '' : 'profile', subBuilder: Profile.create)
    ..aOS(2, _omitFieldNames ? '' : 'identity')
    ..aOM<DHTLog>(3, _omitFieldNames ? '' : 'messages', subBuilder: DHTLog.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Conversation clone() => Conversation()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Conversation copyWith(void Function(Conversation) updates) => super.copyWith((message) => updates(message as Conversation)) as Conversation;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Conversation create() => Conversation._();
  Conversation createEmptyInstance() => create();
  static $pb.PbList<Conversation> createRepeated() => $pb.PbList<Conversation>();
  @$core.pragma('dart2js:noInline')
  static Conversation getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Conversation>(create);
  static Conversation? _defaultInstance;

  @$pb.TagNumber(1)
  Profile get profile => $_getN(0);
  @$pb.TagNumber(1)
  set profile(Profile v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasProfile() => $_has(0);
  @$pb.TagNumber(1)
  void clearProfile() => clearField(1);
  @$pb.TagNumber(1)
  Profile ensureProfile() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get identity => $_getSZ(1);
  @$pb.TagNumber(2)
  set identity($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasIdentity() => $_has(1);
  @$pb.TagNumber(2)
  void clearIdentity() => clearField(2);

  @$pb.TagNumber(3)
  DHTLog get messages => $_getN(2);
  @$pb.TagNumber(3)
  set messages(DHTLog v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasMessages() => $_has(2);
  @$pb.TagNumber(3)
  void clearMessages() => clearField(3);
  @$pb.TagNumber(3)
  DHTLog ensureMessages() => $_ensure(2);
}

class Contact extends $pb.GeneratedMessage {
  factory Contact() => create();
  Contact._() : super();
  factory Contact.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Contact.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Contact', createEmptyInstance: create)
    ..aOM<Profile>(1, _omitFieldNames ? '' : 'editedProfile', subBuilder: Profile.create)
    ..aOM<Profile>(2, _omitFieldNames ? '' : 'remoteProfile', subBuilder: Profile.create)
    ..aOS(3, _omitFieldNames ? '' : 'remoteIdentity')
    ..aOM<TypedKey>(4, _omitFieldNames ? '' : 'remoteConversation', subBuilder: TypedKey.create)
    ..aOM<TypedKey>(5, _omitFieldNames ? '' : 'localConversation', subBuilder: TypedKey.create)
    ..aOB(6, _omitFieldNames ? '' : 'showAvailability')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Contact clone() => Contact()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Contact copyWith(void Function(Contact) updates) => super.copyWith((message) => updates(message as Contact)) as Contact;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Contact create() => Contact._();
  Contact createEmptyInstance() => create();
  static $pb.PbList<Contact> createRepeated() => $pb.PbList<Contact>();
  @$core.pragma('dart2js:noInline')
  static Contact getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Contact>(create);
  static Contact? _defaultInstance;

  @$pb.TagNumber(1)
  Profile get editedProfile => $_getN(0);
  @$pb.TagNumber(1)
  set editedProfile(Profile v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasEditedProfile() => $_has(0);
  @$pb.TagNumber(1)
  void clearEditedProfile() => clearField(1);
  @$pb.TagNumber(1)
  Profile ensureEditedProfile() => $_ensure(0);

  @$pb.TagNumber(2)
  Profile get remoteProfile => $_getN(1);
  @$pb.TagNumber(2)
  set remoteProfile(Profile v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasRemoteProfile() => $_has(1);
  @$pb.TagNumber(2)
  void clearRemoteProfile() => clearField(2);
  @$pb.TagNumber(2)
  Profile ensureRemoteProfile() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get remoteIdentity => $_getSZ(2);
  @$pb.TagNumber(3)
  set remoteIdentity($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRemoteIdentity() => $_has(2);
  @$pb.TagNumber(3)
  void clearRemoteIdentity() => clearField(3);

  @$pb.TagNumber(4)
  TypedKey get remoteConversation => $_getN(3);
  @$pb.TagNumber(4)
  set remoteConversation(TypedKey v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasRemoteConversation() => $_has(3);
  @$pb.TagNumber(4)
  void clearRemoteConversation() => clearField(4);
  @$pb.TagNumber(4)
  TypedKey ensureRemoteConversation() => $_ensure(3);

  @$pb.TagNumber(5)
  TypedKey get localConversation => $_getN(4);
  @$pb.TagNumber(5)
  set localConversation(TypedKey v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasLocalConversation() => $_has(4);
  @$pb.TagNumber(5)
  void clearLocalConversation() => clearField(5);
  @$pb.TagNumber(5)
  TypedKey ensureLocalConversation() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.bool get showAvailability => $_getBF(5);
  @$pb.TagNumber(6)
  set showAvailability($core.bool v) { $_setBool(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasShowAvailability() => $_has(5);
  @$pb.TagNumber(6)
  void clearShowAvailability() => clearField(6);
}

class Profile extends $pb.GeneratedMessage {
  factory Profile() => create();
  Profile._() : super();
  factory Profile.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Profile.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Profile', createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'title')
    ..aOS(3, _omitFieldNames ? '' : 'status')
    ..e<Availability>(4, _omitFieldNames ? '' : 'availability', $pb.PbFieldType.OE, defaultOrMaker: Availability.AVAILABILITY_UNSPECIFIED, valueOf: Availability.valueOf, enumValues: Availability.values)
    ..aOM<TypedKey>(5, _omitFieldNames ? '' : 'avatar', subBuilder: TypedKey.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Profile clone() => Profile()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Profile copyWith(void Function(Profile) updates) => super.copyWith((message) => updates(message as Profile)) as Profile;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Profile create() => Profile._();
  Profile createEmptyInstance() => create();
  static $pb.PbList<Profile> createRepeated() => $pb.PbList<Profile>();
  @$core.pragma('dart2js:noInline')
  static Profile getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Profile>(create);
  static Profile? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get title => $_getSZ(1);
  @$pb.TagNumber(2)
  set title($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTitle() => $_has(1);
  @$pb.TagNumber(2)
  void clearTitle() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get status => $_getSZ(2);
  @$pb.TagNumber(3)
  set status($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatus() => clearField(3);

  @$pb.TagNumber(4)
  Availability get availability => $_getN(3);
  @$pb.TagNumber(4)
  set availability(Availability v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasAvailability() => $_has(3);
  @$pb.TagNumber(4)
  void clearAvailability() => clearField(4);

  @$pb.TagNumber(5)
  TypedKey get avatar => $_getN(4);
  @$pb.TagNumber(5)
  set avatar(TypedKey v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasAvatar() => $_has(4);
  @$pb.TagNumber(5)
  void clearAvatar() => clearField(5);
  @$pb.TagNumber(5)
  TypedKey ensureAvatar() => $_ensure(4);
}

class Account extends $pb.GeneratedMessage {
  factory Account() => create();
  Account._() : super();
  factory Account.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Account.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Account', createEmptyInstance: create)
    ..aOM<Profile>(1, _omitFieldNames ? '' : 'profile', subBuilder: Profile.create)
    ..aOB(2, _omitFieldNames ? '' : 'invisible')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'autoAwayTimeoutSec', $pb.PbFieldType.OU3)
    ..aOM<TypedKey>(4, _omitFieldNames ? '' : 'contactList', subBuilder: TypedKey.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Account clone() => Account()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Account copyWith(void Function(Account) updates) => super.copyWith((message) => updates(message as Account)) as Account;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Account create() => Account._();
  Account createEmptyInstance() => create();
  static $pb.PbList<Account> createRepeated() => $pb.PbList<Account>();
  @$core.pragma('dart2js:noInline')
  static Account getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Account>(create);
  static Account? _defaultInstance;

  @$pb.TagNumber(1)
  Profile get profile => $_getN(0);
  @$pb.TagNumber(1)
  set profile(Profile v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasProfile() => $_has(0);
  @$pb.TagNumber(1)
  void clearProfile() => clearField(1);
  @$pb.TagNumber(1)
  Profile ensureProfile() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.bool get invisible => $_getBF(1);
  @$pb.TagNumber(2)
  set invisible($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasInvisible() => $_has(1);
  @$pb.TagNumber(2)
  void clearInvisible() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get autoAwayTimeoutSec => $_getIZ(2);
  @$pb.TagNumber(3)
  set autoAwayTimeoutSec($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAutoAwayTimeoutSec() => $_has(2);
  @$pb.TagNumber(3)
  void clearAutoAwayTimeoutSec() => clearField(3);

  @$pb.TagNumber(4)
  TypedKey get contactList => $_getN(3);
  @$pb.TagNumber(4)
  set contactList(TypedKey v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasContactList() => $_has(3);
  @$pb.TagNumber(4)
  void clearContactList() => clearField(4);
  @$pb.TagNumber(4)
  TypedKey ensureContactList() => $_ensure(3);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
