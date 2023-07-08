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

import 'package:protobuf/protobuf.dart' as $pb;

class AttachmentKind extends $pb.ProtobufEnum {
  static const AttachmentKind ATTACHMENT_KIND_UNSPECIFIED = AttachmentKind._(0, _omitEnumNames ? '' : 'ATTACHMENT_KIND_UNSPECIFIED');
  static const AttachmentKind ATTACHMENT_KIND_FILE = AttachmentKind._(1, _omitEnumNames ? '' : 'ATTACHMENT_KIND_FILE');
  static const AttachmentKind ATTACHMENT_KIND_IMAGE = AttachmentKind._(2, _omitEnumNames ? '' : 'ATTACHMENT_KIND_IMAGE');

  static const $core.List<AttachmentKind> values = <AttachmentKind> [
    ATTACHMENT_KIND_UNSPECIFIED,
    ATTACHMENT_KIND_FILE,
    ATTACHMENT_KIND_IMAGE,
  ];

  static final $core.Map<$core.int, AttachmentKind> _byValue = $pb.ProtobufEnum.initByValue(values);
  static AttachmentKind? valueOf($core.int value) => _byValue[value];

  const AttachmentKind._($core.int v, $core.String n) : super(v, n);
}

class Availability extends $pb.ProtobufEnum {
  static const Availability AVAILABILITY_UNSPECIFIED = Availability._(0, _omitEnumNames ? '' : 'AVAILABILITY_UNSPECIFIED');
  static const Availability AVAILABILITY_OFFLINE = Availability._(1, _omitEnumNames ? '' : 'AVAILABILITY_OFFLINE');
  static const Availability AVAILABILITY_FREE = Availability._(2, _omitEnumNames ? '' : 'AVAILABILITY_FREE');
  static const Availability AVAILABILITY_BUSY = Availability._(3, _omitEnumNames ? '' : 'AVAILABILITY_BUSY');
  static const Availability AVAILABILITY_AWAY = Availability._(4, _omitEnumNames ? '' : 'AVAILABILITY_AWAY');

  static const $core.List<Availability> values = <Availability> [
    AVAILABILITY_UNSPECIFIED,
    AVAILABILITY_OFFLINE,
    AVAILABILITY_FREE,
    AVAILABILITY_BUSY,
    AVAILABILITY_AWAY,
  ];

  static final $core.Map<$core.int, Availability> _byValue = $pb.ProtobufEnum.initByValue(values);
  static Availability? valueOf($core.int value) => _byValue[value];

  const Availability._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
