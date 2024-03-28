//
//  Generated code. Do not modify.
//  source: dht.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use dHTDataDescriptor instead')
const DHTData$json = {
  '1': 'DHTData',
  '2': [
    {'1': 'keys', '3': 1, '4': 3, '5': 11, '6': '.veilid.TypedKey', '10': 'keys'},
    {'1': 'hash', '3': 2, '4': 1, '5': 11, '6': '.veilid.TypedKey', '10': 'hash'},
    {'1': 'chunk', '3': 3, '4': 1, '5': 13, '10': 'chunk'},
    {'1': 'size', '3': 4, '4': 1, '5': 13, '10': 'size'},
  ],
};

/// Descriptor for `DHTData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dHTDataDescriptor = $convert.base64Decode(
    'CgdESFREYXRhEiQKBGtleXMYASADKAsyEC52ZWlsaWQuVHlwZWRLZXlSBGtleXMSJAoEaGFzaB'
    'gCIAEoCzIQLnZlaWxpZC5UeXBlZEtleVIEaGFzaBIUCgVjaHVuaxgDIAEoDVIFY2h1bmsSEgoE'
    'c2l6ZRgEIAEoDVIEc2l6ZQ==');

@$core.Deprecated('Use dHTShortArrayDescriptor instead')
const DHTShortArray$json = {
  '1': 'DHTShortArray',
  '2': [
    {'1': 'keys', '3': 1, '4': 3, '5': 11, '6': '.veilid.TypedKey', '10': 'keys'},
    {'1': 'index', '3': 2, '4': 1, '5': 12, '10': 'index'},
    {'1': 'seqs', '3': 3, '4': 3, '5': 13, '10': 'seqs'},
  ],
};

/// Descriptor for `DHTShortArray`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dHTShortArrayDescriptor = $convert.base64Decode(
    'Cg1ESFRTaG9ydEFycmF5EiQKBGtleXMYASADKAsyEC52ZWlsaWQuVHlwZWRLZXlSBGtleXMSFA'
    'oFaW5kZXgYAiABKAxSBWluZGV4EhIKBHNlcXMYAyADKA1SBHNlcXM=');

@$core.Deprecated('Use dHTLogDescriptor instead')
const DHTLog$json = {
  '1': 'DHTLog',
  '2': [
    {'1': 'keys', '3': 1, '4': 3, '5': 11, '6': '.veilid.TypedKey', '10': 'keys'},
    {'1': 'back', '3': 2, '4': 1, '5': 11, '6': '.veilid.TypedKey', '10': 'back'},
    {'1': 'subkey_counts', '3': 3, '4': 3, '5': 13, '10': 'subkeyCounts'},
    {'1': 'total_subkeys', '3': 4, '4': 1, '5': 13, '10': 'totalSubkeys'},
  ],
};

/// Descriptor for `DHTLog`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dHTLogDescriptor = $convert.base64Decode(
    'CgZESFRMb2cSJAoEa2V5cxgBIAMoCzIQLnZlaWxpZC5UeXBlZEtleVIEa2V5cxIkCgRiYWNrGA'
    'IgASgLMhAudmVpbGlkLlR5cGVkS2V5UgRiYWNrEiMKDXN1YmtleV9jb3VudHMYAyADKA1SDHN1'
    'YmtleUNvdW50cxIjCg10b3RhbF9zdWJrZXlzGAQgASgNUgx0b3RhbFN1YmtleXM=');

@$core.Deprecated('Use dataReferenceDescriptor instead')
const DataReference$json = {
  '1': 'DataReference',
  '2': [
    {'1': 'dht_data', '3': 1, '4': 1, '5': 11, '6': '.veilid.TypedKey', '9': 0, '10': 'dhtData'},
  ],
  '8': [
    {'1': 'kind'},
  ],
};

/// Descriptor for `DataReference`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dataReferenceDescriptor = $convert.base64Decode(
    'Cg1EYXRhUmVmZXJlbmNlEi0KCGRodF9kYXRhGAEgASgLMhAudmVpbGlkLlR5cGVkS2V5SABSB2'
    'RodERhdGFCBgoEa2luZA==');

@$core.Deprecated('Use ownedDHTRecordPointerDescriptor instead')
const OwnedDHTRecordPointer$json = {
  '1': 'OwnedDHTRecordPointer',
  '2': [
    {'1': 'record_key', '3': 1, '4': 1, '5': 11, '6': '.veilid.TypedKey', '10': 'recordKey'},
    {'1': 'owner', '3': 2, '4': 1, '5': 11, '6': '.veilid.KeyPair', '10': 'owner'},
  ],
};

/// Descriptor for `OwnedDHTRecordPointer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ownedDHTRecordPointerDescriptor = $convert.base64Decode(
    'ChVPd25lZERIVFJlY29yZFBvaW50ZXISLwoKcmVjb3JkX2tleRgBIAEoCzIQLnZlaWxpZC5UeX'
    'BlZEtleVIJcmVjb3JkS2V5EiUKBW93bmVyGAIgASgLMg8udmVpbGlkLktleVBhaXJSBW93bmVy');

