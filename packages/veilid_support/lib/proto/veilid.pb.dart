//
//  Generated code. Do not modify.
//  source: veilid.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// 32-byte value in bigendian format
class CryptoKey extends $pb.GeneratedMessage {
  factory CryptoKey({
    $core.int? u0,
    $core.int? u1,
    $core.int? u2,
    $core.int? u3,
    $core.int? u4,
    $core.int? u5,
    $core.int? u6,
    $core.int? u7,
  }) {
    final $result = create();
    if (u0 != null) {
      $result.u0 = u0;
    }
    if (u1 != null) {
      $result.u1 = u1;
    }
    if (u2 != null) {
      $result.u2 = u2;
    }
    if (u3 != null) {
      $result.u3 = u3;
    }
    if (u4 != null) {
      $result.u4 = u4;
    }
    if (u5 != null) {
      $result.u5 = u5;
    }
    if (u6 != null) {
      $result.u6 = u6;
    }
    if (u7 != null) {
      $result.u7 = u7;
    }
    return $result;
  }
  CryptoKey._() : super();
  factory CryptoKey.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CryptoKey.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CryptoKey', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilid'), createEmptyInstance: create)
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

/// 64-byte value in bigendian format
class Signature extends $pb.GeneratedMessage {
  factory Signature({
    $core.int? u0,
    $core.int? u1,
    $core.int? u2,
    $core.int? u3,
    $core.int? u4,
    $core.int? u5,
    $core.int? u6,
    $core.int? u7,
    $core.int? u8,
    $core.int? u9,
    $core.int? u10,
    $core.int? u11,
    $core.int? u12,
    $core.int? u13,
    $core.int? u14,
    $core.int? u15,
  }) {
    final $result = create();
    if (u0 != null) {
      $result.u0 = u0;
    }
    if (u1 != null) {
      $result.u1 = u1;
    }
    if (u2 != null) {
      $result.u2 = u2;
    }
    if (u3 != null) {
      $result.u3 = u3;
    }
    if (u4 != null) {
      $result.u4 = u4;
    }
    if (u5 != null) {
      $result.u5 = u5;
    }
    if (u6 != null) {
      $result.u6 = u6;
    }
    if (u7 != null) {
      $result.u7 = u7;
    }
    if (u8 != null) {
      $result.u8 = u8;
    }
    if (u9 != null) {
      $result.u9 = u9;
    }
    if (u10 != null) {
      $result.u10 = u10;
    }
    if (u11 != null) {
      $result.u11 = u11;
    }
    if (u12 != null) {
      $result.u12 = u12;
    }
    if (u13 != null) {
      $result.u13 = u13;
    }
    if (u14 != null) {
      $result.u14 = u14;
    }
    if (u15 != null) {
      $result.u15 = u15;
    }
    return $result;
  }
  Signature._() : super();
  factory Signature.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Signature.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Signature', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilid'), createEmptyInstance: create)
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

/// 24-byte value in bigendian format
class Nonce extends $pb.GeneratedMessage {
  factory Nonce({
    $core.int? u0,
    $core.int? u1,
    $core.int? u2,
    $core.int? u3,
    $core.int? u4,
    $core.int? u5,
  }) {
    final $result = create();
    if (u0 != null) {
      $result.u0 = u0;
    }
    if (u1 != null) {
      $result.u1 = u1;
    }
    if (u2 != null) {
      $result.u2 = u2;
    }
    if (u3 != null) {
      $result.u3 = u3;
    }
    if (u4 != null) {
      $result.u4 = u4;
    }
    if (u5 != null) {
      $result.u5 = u5;
    }
    return $result;
  }
  Nonce._() : super();
  factory Nonce.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Nonce.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Nonce', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilid'), createEmptyInstance: create)
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

/// 36-byte typed crypto key
class TypedKey extends $pb.GeneratedMessage {
  factory TypedKey({
    $core.int? kind,
    CryptoKey? value,
  }) {
    final $result = create();
    if (kind != null) {
      $result.kind = kind;
    }
    if (value != null) {
      $result.value = value;
    }
    return $result;
  }
  TypedKey._() : super();
  factory TypedKey.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TypedKey.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TypedKey', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilid'), createEmptyInstance: create)
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

  /// CryptoKind FourCC in bigendian format
  @$pb.TagNumber(1)
  $core.int get kind => $_getIZ(0);
  @$pb.TagNumber(1)
  set kind($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasKind() => $_has(0);
  @$pb.TagNumber(1)
  void clearKind() => clearField(1);

  /// Key value
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

/// Key pair
class KeyPair extends $pb.GeneratedMessage {
  factory KeyPair({
    CryptoKey? key,
    CryptoKey? secret,
  }) {
    final $result = create();
    if (key != null) {
      $result.key = key;
    }
    if (secret != null) {
      $result.secret = secret;
    }
    return $result;
  }
  KeyPair._() : super();
  factory KeyPair.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory KeyPair.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'KeyPair', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilid'), createEmptyInstance: create)
    ..aOM<CryptoKey>(1, _omitFieldNames ? '' : 'key', subBuilder: CryptoKey.create)
    ..aOM<CryptoKey>(2, _omitFieldNames ? '' : 'secret', subBuilder: CryptoKey.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  KeyPair clone() => KeyPair()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  KeyPair copyWith(void Function(KeyPair) updates) => super.copyWith((message) => updates(message as KeyPair)) as KeyPair;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static KeyPair create() => KeyPair._();
  KeyPair createEmptyInstance() => create();
  static $pb.PbList<KeyPair> createRepeated() => $pb.PbList<KeyPair>();
  @$core.pragma('dart2js:noInline')
  static KeyPair getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<KeyPair>(create);
  static KeyPair? _defaultInstance;

  /// Public key
  @$pb.TagNumber(1)
  CryptoKey get key => $_getN(0);
  @$pb.TagNumber(1)
  set key(CryptoKey v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => clearField(1);
  @$pb.TagNumber(1)
  CryptoKey ensureKey() => $_ensure(0);

  /// Private key
  @$pb.TagNumber(2)
  CryptoKey get secret => $_getN(1);
  @$pb.TagNumber(2)
  set secret(CryptoKey v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasSecret() => $_has(1);
  @$pb.TagNumber(2)
  void clearSecret() => clearField(2);
  @$pb.TagNumber(2)
  CryptoKey ensureSecret() => $_ensure(1);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
