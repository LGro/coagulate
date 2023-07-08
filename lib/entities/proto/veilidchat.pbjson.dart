//
//  Generated code. Do not modify.
//  source: proto/veilidchat.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use attachmentKindDescriptor instead')
const AttachmentKind$json = {
  '1': 'AttachmentKind',
  '2': [
    {'1': 'ATTACHMENT_KIND_UNSPECIFIED', '2': 0},
    {'1': 'ATTACHMENT_KIND_FILE', '2': 1},
    {'1': 'ATTACHMENT_KIND_IMAGE', '2': 2},
  ],
};

/// Descriptor for `AttachmentKind`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List attachmentKindDescriptor = $convert.base64Decode(
    'Cg5BdHRhY2htZW50S2luZBIfChtBVFRBQ0hNRU5UX0tJTkRfVU5TUEVDSUZJRUQQABIYChRBVF'
    'RBQ0hNRU5UX0tJTkRfRklMRRABEhkKFUFUVEFDSE1FTlRfS0lORF9JTUFHRRAC');

@$core.Deprecated('Use availabilityDescriptor instead')
const Availability$json = {
  '1': 'Availability',
  '2': [
    {'1': 'AVAILABILITY_UNSPECIFIED', '2': 0},
    {'1': 'AVAILABILITY_OFFLINE', '2': 1},
    {'1': 'AVAILABILITY_FREE', '2': 2},
    {'1': 'AVAILABILITY_BUSY', '2': 3},
    {'1': 'AVAILABILITY_AWAY', '2': 4},
  ],
};

/// Descriptor for `Availability`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List availabilityDescriptor = $convert.base64Decode(
    'CgxBdmFpbGFiaWxpdHkSHAoYQVZBSUxBQklMSVRZX1VOU1BFQ0lGSUVEEAASGAoUQVZBSUxBQk'
    'lMSVRZX09GRkxJTkUQARIVChFBVkFJTEFCSUxJVFlfRlJFRRACEhUKEUFWQUlMQUJJTElUWV9C'
    'VVNZEAMSFQoRQVZBSUxBQklMSVRZX0FXQVkQBA==');

@$core.Deprecated('Use cryptoKeyDescriptor instead')
const CryptoKey$json = {
  '1': 'CryptoKey',
  '2': [
    {'1': 'u0', '3': 1, '4': 1, '5': 7, '10': 'u0'},
    {'1': 'u1', '3': 2, '4': 1, '5': 7, '10': 'u1'},
    {'1': 'u2', '3': 3, '4': 1, '5': 7, '10': 'u2'},
    {'1': 'u3', '3': 4, '4': 1, '5': 7, '10': 'u3'},
    {'1': 'u4', '3': 5, '4': 1, '5': 7, '10': 'u4'},
    {'1': 'u5', '3': 6, '4': 1, '5': 7, '10': 'u5'},
    {'1': 'u6', '3': 7, '4': 1, '5': 7, '10': 'u6'},
    {'1': 'u7', '3': 8, '4': 1, '5': 7, '10': 'u7'},
  ],
};

/// Descriptor for `CryptoKey`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cryptoKeyDescriptor = $convert.base64Decode(
    'CglDcnlwdG9LZXkSDgoCdTAYASABKAdSAnUwEg4KAnUxGAIgASgHUgJ1MRIOCgJ1MhgDIAEoB1'
    'ICdTISDgoCdTMYBCABKAdSAnUzEg4KAnU0GAUgASgHUgJ1NBIOCgJ1NRgGIAEoB1ICdTUSDgoC'
    'dTYYByABKAdSAnU2Eg4KAnU3GAggASgHUgJ1Nw==');

@$core.Deprecated('Use signatureDescriptor instead')
const Signature$json = {
  '1': 'Signature',
  '2': [
    {'1': 'u0', '3': 1, '4': 1, '5': 7, '10': 'u0'},
    {'1': 'u1', '3': 2, '4': 1, '5': 7, '10': 'u1'},
    {'1': 'u2', '3': 3, '4': 1, '5': 7, '10': 'u2'},
    {'1': 'u3', '3': 4, '4': 1, '5': 7, '10': 'u3'},
    {'1': 'u4', '3': 5, '4': 1, '5': 7, '10': 'u4'},
    {'1': 'u5', '3': 6, '4': 1, '5': 7, '10': 'u5'},
    {'1': 'u6', '3': 7, '4': 1, '5': 7, '10': 'u6'},
    {'1': 'u7', '3': 8, '4': 1, '5': 7, '10': 'u7'},
    {'1': 'u8', '3': 9, '4': 1, '5': 7, '10': 'u8'},
    {'1': 'u9', '3': 10, '4': 1, '5': 7, '10': 'u9'},
    {'1': 'u10', '3': 11, '4': 1, '5': 7, '10': 'u10'},
    {'1': 'u11', '3': 12, '4': 1, '5': 7, '10': 'u11'},
    {'1': 'u12', '3': 13, '4': 1, '5': 7, '10': 'u12'},
    {'1': 'u13', '3': 14, '4': 1, '5': 7, '10': 'u13'},
    {'1': 'u14', '3': 15, '4': 1, '5': 7, '10': 'u14'},
    {'1': 'u15', '3': 16, '4': 1, '5': 7, '10': 'u15'},
  ],
};

/// Descriptor for `Signature`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List signatureDescriptor = $convert.base64Decode(
    'CglTaWduYXR1cmUSDgoCdTAYASABKAdSAnUwEg4KAnUxGAIgASgHUgJ1MRIOCgJ1MhgDIAEoB1'
    'ICdTISDgoCdTMYBCABKAdSAnUzEg4KAnU0GAUgASgHUgJ1NBIOCgJ1NRgGIAEoB1ICdTUSDgoC'
    'dTYYByABKAdSAnU2Eg4KAnU3GAggASgHUgJ1NxIOCgJ1OBgJIAEoB1ICdTgSDgoCdTkYCiABKA'
    'dSAnU5EhAKA3UxMBgLIAEoB1IDdTEwEhAKA3UxMRgMIAEoB1IDdTExEhAKA3UxMhgNIAEoB1ID'
    'dTEyEhAKA3UxMxgOIAEoB1IDdTEzEhAKA3UxNBgPIAEoB1IDdTE0EhAKA3UxNRgQIAEoB1IDdT'
    'E1');

@$core.Deprecated('Use nonceDescriptor instead')
const Nonce$json = {
  '1': 'Nonce',
  '2': [
    {'1': 'u0', '3': 1, '4': 1, '5': 7, '10': 'u0'},
    {'1': 'u1', '3': 2, '4': 1, '5': 7, '10': 'u1'},
    {'1': 'u2', '3': 3, '4': 1, '5': 7, '10': 'u2'},
    {'1': 'u3', '3': 4, '4': 1, '5': 7, '10': 'u3'},
    {'1': 'u4', '3': 5, '4': 1, '5': 7, '10': 'u4'},
    {'1': 'u5', '3': 6, '4': 1, '5': 7, '10': 'u5'},
  ],
};

/// Descriptor for `Nonce`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List nonceDescriptor = $convert.base64Decode(
    'CgVOb25jZRIOCgJ1MBgBIAEoB1ICdTASDgoCdTEYAiABKAdSAnUxEg4KAnUyGAMgASgHUgJ1Mh'
    'IOCgJ1MxgEIAEoB1ICdTMSDgoCdTQYBSABKAdSAnU0Eg4KAnU1GAYgASgHUgJ1NQ==');

@$core.Deprecated('Use typedKeyDescriptor instead')
const TypedKey$json = {
  '1': 'TypedKey',
  '2': [
    {'1': 'kind', '3': 1, '4': 1, '5': 7, '10': 'kind'},
    {'1': 'value', '3': 2, '4': 1, '5': 11, '6': '.CryptoKey', '10': 'value'},
  ],
};

/// Descriptor for `TypedKey`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List typedKeyDescriptor = $convert.base64Decode(
    'CghUeXBlZEtleRISCgRraW5kGAEgASgHUgRraW5kEiAKBXZhbHVlGAIgASgLMgouQ3J5cHRvS2'
    'V5UgV2YWx1ZQ==');

@$core.Deprecated('Use dHTDataDescriptor instead')
const DHTData$json = {
  '1': 'DHTData',
  '2': [
    {'1': 'keys', '3': 1, '4': 3, '5': 11, '6': '.TypedKey', '10': 'keys'},
    {'1': 'hash', '3': 2, '4': 1, '5': 11, '6': '.TypedKey', '10': 'hash'},
    {'1': 'chunk', '3': 3, '4': 1, '5': 13, '10': 'chunk'},
    {'1': 'size', '3': 4, '4': 1, '5': 13, '10': 'size'},
  ],
};

/// Descriptor for `DHTData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dHTDataDescriptor = $convert.base64Decode(
    'CgdESFREYXRhEh0KBGtleXMYASADKAsyCS5UeXBlZEtleVIEa2V5cxIdCgRoYXNoGAIgASgLMg'
    'kuVHlwZWRLZXlSBGhhc2gSFAoFY2h1bmsYAyABKA1SBWNodW5rEhIKBHNpemUYBCABKA1SBHNp'
    'emU=');

@$core.Deprecated('Use dHTListDescriptor instead')
const DHTList$json = {
  '1': 'DHTList',
  '2': [
    {'1': 'keys', '3': 1, '4': 3, '5': 11, '6': '.TypedKey', '10': 'keys'},
    {'1': 'index', '3': 2, '4': 3, '5': 13, '10': 'index'},
  ],
};

/// Descriptor for `DHTList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dHTListDescriptor = $convert.base64Decode(
    'CgdESFRMaXN0Eh0KBGtleXMYASADKAsyCS5UeXBlZEtleVIEa2V5cxIUCgVpbmRleBgCIAMoDV'
    'IFaW5kZXg=');

@$core.Deprecated('Use dHTLogDescriptor instead')
const DHTLog$json = {
  '1': 'DHTLog',
  '2': [
    {'1': 'keys', '3': 1, '4': 3, '5': 11, '6': '.TypedKey', '10': 'keys'},
    {'1': 'back', '3': 2, '4': 1, '5': 11, '6': '.TypedKey', '10': 'back'},
    {'1': 'subkey_counts', '3': 3, '4': 3, '5': 13, '10': 'subkeyCounts'},
    {'1': 'total_subkeys', '3': 4, '4': 1, '5': 13, '10': 'totalSubkeys'},
  ],
};

/// Descriptor for `DHTLog`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dHTLogDescriptor = $convert.base64Decode(
    'CgZESFRMb2cSHQoEa2V5cxgBIAMoCzIJLlR5cGVkS2V5UgRrZXlzEh0KBGJhY2sYAiABKAsyCS'
    '5UeXBlZEtleVIEYmFjaxIjCg1zdWJrZXlfY291bnRzGAMgAygNUgxzdWJrZXlDb3VudHMSIwoN'
    'dG90YWxfc3Via2V5cxgEIAEoDVIMdG90YWxTdWJrZXlz');

@$core.Deprecated('Use dataReferenceDescriptor instead')
const DataReference$json = {
  '1': 'DataReference',
  '2': [
    {'1': 'dht_data', '3': 1, '4': 1, '5': 11, '6': '.TypedKey', '9': 0, '10': 'dhtData'},
  ],
  '8': [
    {'1': 'kind'},
  ],
};

/// Descriptor for `DataReference`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dataReferenceDescriptor = $convert.base64Decode(
    'Cg1EYXRhUmVmZXJlbmNlEiYKCGRodF9kYXRhGAEgASgLMgkuVHlwZWRLZXlIAFIHZGh0RGF0YU'
    'IGCgRraW5k');

@$core.Deprecated('Use attachmentDescriptor instead')
const Attachment$json = {
  '1': 'Attachment',
  '2': [
    {'1': 'kind', '3': 1, '4': 1, '5': 14, '6': '.AttachmentKind', '10': 'kind'},
    {'1': 'mime', '3': 2, '4': 1, '5': 9, '10': 'mime'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'content', '3': 4, '4': 1, '5': 11, '6': '.DataReference', '10': 'content'},
    {'1': 'signature', '3': 5, '4': 1, '5': 11, '6': '.Signature', '10': 'signature'},
  ],
};

/// Descriptor for `Attachment`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List attachmentDescriptor = $convert.base64Decode(
    'CgpBdHRhY2htZW50EiMKBGtpbmQYASABKA4yDy5BdHRhY2htZW50S2luZFIEa2luZBISCgRtaW'
    '1lGAIgASgJUgRtaW1lEhIKBG5hbWUYAyABKAlSBG5hbWUSKAoHY29udGVudBgEIAEoCzIOLkRh'
    'dGFSZWZlcmVuY2VSB2NvbnRlbnQSKAoJc2lnbmF0dXJlGAUgASgLMgouU2lnbmF0dXJlUglzaW'
    'duYXR1cmU=');

@$core.Deprecated('Use messageDescriptor instead')
const Message$json = {
  '1': 'Message',
  '2': [
    {'1': 'author', '3': 1, '4': 1, '5': 11, '6': '.TypedKey', '10': 'author'},
    {'1': 'timestamp', '3': 2, '4': 1, '5': 4, '10': 'timestamp'},
    {'1': 'text', '3': 3, '4': 1, '5': 9, '10': 'text'},
    {'1': 'signature', '3': 4, '4': 1, '5': 11, '6': '.Signature', '10': 'signature'},
    {'1': 'attachments', '3': 5, '4': 3, '5': 11, '6': '.Attachment', '10': 'attachments'},
  ],
};

/// Descriptor for `Message`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageDescriptor = $convert.base64Decode(
    'CgdNZXNzYWdlEiEKBmF1dGhvchgBIAEoCzIJLlR5cGVkS2V5UgZhdXRob3ISHAoJdGltZXN0YW'
    '1wGAIgASgEUgl0aW1lc3RhbXASEgoEdGV4dBgDIAEoCVIEdGV4dBIoCglzaWduYXR1cmUYBCAB'
    'KAsyCi5TaWduYXR1cmVSCXNpZ25hdHVyZRItCgthdHRhY2htZW50cxgFIAMoCzILLkF0dGFjaG'
    '1lbnRSC2F0dGFjaG1lbnRz');

@$core.Deprecated('Use conversationDescriptor instead')
const Conversation$json = {
  '1': 'Conversation',
  '2': [
    {'1': 'profile', '3': 1, '4': 1, '5': 11, '6': '.Profile', '10': 'profile'},
    {'1': 'identity', '3': 2, '4': 1, '5': 9, '10': 'identity'},
    {'1': 'messages', '3': 3, '4': 1, '5': 11, '6': '.DHTLog', '10': 'messages'},
  ],
};

/// Descriptor for `Conversation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationDescriptor = $convert.base64Decode(
    'CgxDb252ZXJzYXRpb24SIgoHcHJvZmlsZRgBIAEoCzIILlByb2ZpbGVSB3Byb2ZpbGUSGgoIaW'
    'RlbnRpdHkYAiABKAlSCGlkZW50aXR5EiMKCG1lc3NhZ2VzGAMgASgLMgcuREhUTG9nUghtZXNz'
    'YWdlcw==');

@$core.Deprecated('Use contactDescriptor instead')
const Contact$json = {
  '1': 'Contact',
  '2': [
    {'1': 'edited_profile', '3': 1, '4': 1, '5': 11, '6': '.Profile', '10': 'editedProfile'},
    {'1': 'remote_profile', '3': 2, '4': 1, '5': 11, '6': '.Profile', '10': 'remoteProfile'},
    {'1': 'remote_identity', '3': 3, '4': 1, '5': 9, '10': 'remoteIdentity'},
    {'1': 'remote_conversation', '3': 4, '4': 1, '5': 11, '6': '.TypedKey', '10': 'remoteConversation'},
    {'1': 'local_conversation', '3': 5, '4': 1, '5': 11, '6': '.TypedKey', '10': 'localConversation'},
    {'1': 'show_availability', '3': 6, '4': 1, '5': 8, '10': 'showAvailability'},
  ],
};

/// Descriptor for `Contact`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List contactDescriptor = $convert.base64Decode(
    'CgdDb250YWN0Ei8KDmVkaXRlZF9wcm9maWxlGAEgASgLMgguUHJvZmlsZVINZWRpdGVkUHJvZm'
    'lsZRIvCg5yZW1vdGVfcHJvZmlsZRgCIAEoCzIILlByb2ZpbGVSDXJlbW90ZVByb2ZpbGUSJwoP'
    'cmVtb3RlX2lkZW50aXR5GAMgASgJUg5yZW1vdGVJZGVudGl0eRI6ChNyZW1vdGVfY29udmVyc2'
    'F0aW9uGAQgASgLMgkuVHlwZWRLZXlSEnJlbW90ZUNvbnZlcnNhdGlvbhI4ChJsb2NhbF9jb252'
    'ZXJzYXRpb24YBSABKAsyCS5UeXBlZEtleVIRbG9jYWxDb252ZXJzYXRpb24SKwoRc2hvd19hdm'
    'FpbGFiaWxpdHkYBiABKAhSEHNob3dBdmFpbGFiaWxpdHk=');

@$core.Deprecated('Use profileDescriptor instead')
const Profile$json = {
  '1': 'Profile',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'title', '3': 2, '4': 1, '5': 9, '10': 'title'},
    {'1': 'status', '3': 3, '4': 1, '5': 9, '10': 'status'},
    {'1': 'availability', '3': 4, '4': 1, '5': 14, '6': '.Availability', '10': 'availability'},
    {'1': 'icon', '3': 5, '4': 1, '5': 11, '6': '.TypedKey', '10': 'icon'},
  ],
};

/// Descriptor for `Profile`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List profileDescriptor = $convert.base64Decode(
    'CgdQcm9maWxlEhIKBG5hbWUYASABKAlSBG5hbWUSFAoFdGl0bGUYAiABKAlSBXRpdGxlEhYKBn'
    'N0YXR1cxgDIAEoCVIGc3RhdHVzEjEKDGF2YWlsYWJpbGl0eRgEIAEoDjINLkF2YWlsYWJpbGl0'
    'eVIMYXZhaWxhYmlsaXR5Eh0KBGljb24YBSABKAsyCS5UeXBlZEtleVIEaWNvbg==');

@$core.Deprecated('Use accountDescriptor instead')
const Account$json = {
  '1': 'Account',
  '2': [
    {'1': 'profile', '3': 1, '4': 1, '5': 11, '6': '.Profile', '10': 'profile'},
    {'1': 'invisible', '3': 2, '4': 1, '5': 8, '10': 'invisible'},
    {'1': 'auto_away_timeout_sec', '3': 3, '4': 1, '5': 13, '10': 'autoAwayTimeoutSec'},
    {'1': 'contact_list', '3': 4, '4': 1, '5': 11, '6': '.TypedKey', '10': 'contactList'},
  ],
};

/// Descriptor for `Account`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List accountDescriptor = $convert.base64Decode(
    'CgdBY2NvdW50EiIKB3Byb2ZpbGUYASABKAsyCC5Qcm9maWxlUgdwcm9maWxlEhwKCWludmlzaW'
    'JsZRgCIAEoCFIJaW52aXNpYmxlEjEKFWF1dG9fYXdheV90aW1lb3V0X3NlYxgDIAEoDVISYXV0'
    'b0F3YXlUaW1lb3V0U2VjEiwKDGNvbnRhY3RfbGlzdBgEIAEoCzIJLlR5cGVkS2V5Ugtjb250YW'
    'N0TGlzdA==');

