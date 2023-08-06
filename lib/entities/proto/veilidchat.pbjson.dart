//
//  Generated code. Do not modify.
//  source: veilidchat.proto
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

@$core.Deprecated('Use chatTypeDescriptor instead')
const ChatType$json = {
  '1': 'ChatType',
  '2': [
    {'1': 'CHAT_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'SINGLE_CONTACT', '2': 1},
    {'1': 'GROUP', '2': 2},
  ],
};

/// Descriptor for `ChatType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List chatTypeDescriptor = $convert.base64Decode(
    'CghDaGF0VHlwZRIZChVDSEFUX1RZUEVfVU5TUEVDSUZJRUQQABISCg5TSU5HTEVfQ09OVEFDVB'
    'ABEgkKBUdST1VQEAI=');

@$core.Deprecated('Use encryptionKeyTypeDescriptor instead')
const EncryptionKeyType$json = {
  '1': 'EncryptionKeyType',
  '2': [
    {'1': 'ENCRYPTION_KEY_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'ENCRYPTION_KEY_TYPE_NONE', '2': 1},
    {'1': 'ENCRYPTION_KEY_TYPE_PIN', '2': 2},
    {'1': 'ENCRYPTION_KEY_TYPE_PASSWORD', '2': 3},
  ],
};

/// Descriptor for `EncryptionKeyType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List encryptionKeyTypeDescriptor = $convert.base64Decode(
    'ChFFbmNyeXB0aW9uS2V5VHlwZRIjCh9FTkNSWVBUSU9OX0tFWV9UWVBFX1VOU1BFQ0lGSUVEEA'
    'ASHAoYRU5DUllQVElPTl9LRVlfVFlQRV9OT05FEAESGwoXRU5DUllQVElPTl9LRVlfVFlQRV9Q'
    'SU4QAhIgChxFTkNSWVBUSU9OX0tFWV9UWVBFX1BBU1NXT1JEEAM=');

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

@$core.Deprecated('Use keyPairDescriptor instead')
const KeyPair$json = {
  '1': 'KeyPair',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 11, '6': '.CryptoKey', '10': 'key'},
    {'1': 'secret', '3': 2, '4': 1, '5': 11, '6': '.CryptoKey', '10': 'secret'},
  ],
};

/// Descriptor for `KeyPair`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List keyPairDescriptor = $convert.base64Decode(
    'CgdLZXlQYWlyEhwKA2tleRgBIAEoCzIKLkNyeXB0b0tleVIDa2V5EiIKBnNlY3JldBgCIAEoCz'
    'IKLkNyeXB0b0tleVIGc2VjcmV0');

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

@$core.Deprecated('Use dHTShortArrayDescriptor instead')
const DHTShortArray$json = {
  '1': 'DHTShortArray',
  '2': [
    {'1': 'keys', '3': 1, '4': 3, '5': 11, '6': '.TypedKey', '10': 'keys'},
    {'1': 'index', '3': 2, '4': 1, '5': 12, '10': 'index'},
  ],
};

/// Descriptor for `DHTShortArray`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dHTShortArrayDescriptor = $convert.base64Decode(
    'Cg1ESFRTaG9ydEFycmF5Eh0KBGtleXMYASADKAsyCS5UeXBlZEtleVIEa2V5cxIUCgVpbmRleB'
    'gCIAEoDFIFaW5kZXg=');

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
    {'1': 'identity_master_json', '3': 2, '4': 1, '5': 9, '10': 'identityMasterJson'},
    {'1': 'messages', '3': 3, '4': 1, '5': 11, '6': '.OwnedDHTRecordPointer', '10': 'messages'},
  ],
};

/// Descriptor for `Conversation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationDescriptor = $convert.base64Decode(
    'CgxDb252ZXJzYXRpb24SIgoHcHJvZmlsZRgBIAEoCzIILlByb2ZpbGVSB3Byb2ZpbGUSMAoUaW'
    'RlbnRpdHlfbWFzdGVyX2pzb24YAiABKAlSEmlkZW50aXR5TWFzdGVySnNvbhIyCghtZXNzYWdl'
    'cxgDIAEoCzIWLk93bmVkREhUUmVjb3JkUG9pbnRlclIIbWVzc2FnZXM=');

@$core.Deprecated('Use contactDescriptor instead')
const Contact$json = {
  '1': 'Contact',
  '2': [
    {'1': 'edited_profile', '3': 1, '4': 1, '5': 11, '6': '.Profile', '10': 'editedProfile'},
    {'1': 'remote_profile', '3': 2, '4': 1, '5': 11, '6': '.Profile', '10': 'remoteProfile'},
    {'1': 'identity_master_json', '3': 3, '4': 1, '5': 9, '10': 'identityMasterJson'},
    {'1': 'identity_public_key', '3': 4, '4': 1, '5': 11, '6': '.TypedKey', '10': 'identityPublicKey'},
    {'1': 'remote_conversation_key', '3': 5, '4': 1, '5': 11, '6': '.TypedKey', '10': 'remoteConversationKey'},
    {'1': 'local_conversation', '3': 6, '4': 1, '5': 11, '6': '.OwnedDHTRecordPointer', '10': 'localConversation'},
    {'1': 'show_availability', '3': 7, '4': 1, '5': 8, '10': 'showAvailability'},
  ],
};

/// Descriptor for `Contact`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List contactDescriptor = $convert.base64Decode(
    'CgdDb250YWN0Ei8KDmVkaXRlZF9wcm9maWxlGAEgASgLMgguUHJvZmlsZVINZWRpdGVkUHJvZm'
    'lsZRIvCg5yZW1vdGVfcHJvZmlsZRgCIAEoCzIILlByb2ZpbGVSDXJlbW90ZVByb2ZpbGUSMAoU'
    'aWRlbnRpdHlfbWFzdGVyX2pzb24YAyABKAlSEmlkZW50aXR5TWFzdGVySnNvbhI5ChNpZGVudG'
    'l0eV9wdWJsaWNfa2V5GAQgASgLMgkuVHlwZWRLZXlSEWlkZW50aXR5UHVibGljS2V5EkEKF3Jl'
    'bW90ZV9jb252ZXJzYXRpb25fa2V5GAUgASgLMgkuVHlwZWRLZXlSFXJlbW90ZUNvbnZlcnNhdG'
    'lvbktleRJFChJsb2NhbF9jb252ZXJzYXRpb24YBiABKAsyFi5Pd25lZERIVFJlY29yZFBvaW50'
    'ZXJSEWxvY2FsQ29udmVyc2F0aW9uEisKEXNob3dfYXZhaWxhYmlsaXR5GAcgASgIUhBzaG93QX'
    'ZhaWxhYmlsaXR5');

@$core.Deprecated('Use profileDescriptor instead')
const Profile$json = {
  '1': 'Profile',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'title', '3': 2, '4': 1, '5': 9, '10': 'title'},
    {'1': 'status', '3': 3, '4': 1, '5': 9, '10': 'status'},
    {'1': 'availability', '3': 4, '4': 1, '5': 14, '6': '.Availability', '10': 'availability'},
    {'1': 'avatar', '3': 5, '4': 1, '5': 11, '6': '.TypedKey', '9': 0, '10': 'avatar', '17': true},
  ],
  '8': [
    {'1': '_avatar'},
  ],
};

/// Descriptor for `Profile`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List profileDescriptor = $convert.base64Decode(
    'CgdQcm9maWxlEhIKBG5hbWUYASABKAlSBG5hbWUSFAoFdGl0bGUYAiABKAlSBXRpdGxlEhYKBn'
    'N0YXR1cxgDIAEoCVIGc3RhdHVzEjEKDGF2YWlsYWJpbGl0eRgEIAEoDjINLkF2YWlsYWJpbGl0'
    'eVIMYXZhaWxhYmlsaXR5EiYKBmF2YXRhchgFIAEoCzIJLlR5cGVkS2V5SABSBmF2YXRhcogBAU'
    'IJCgdfYXZhdGFy');

@$core.Deprecated('Use ownedDHTRecordPointerDescriptor instead')
const OwnedDHTRecordPointer$json = {
  '1': 'OwnedDHTRecordPointer',
  '2': [
    {'1': 'record_key', '3': 1, '4': 1, '5': 11, '6': '.TypedKey', '10': 'recordKey'},
    {'1': 'owner', '3': 2, '4': 1, '5': 11, '6': '.KeyPair', '10': 'owner'},
  ],
};

/// Descriptor for `OwnedDHTRecordPointer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ownedDHTRecordPointerDescriptor = $convert.base64Decode(
    'ChVPd25lZERIVFJlY29yZFBvaW50ZXISKAoKcmVjb3JkX2tleRgBIAEoCzIJLlR5cGVkS2V5Ug'
    'lyZWNvcmRLZXkSHgoFb3duZXIYAiABKAsyCC5LZXlQYWlyUgVvd25lcg==');

@$core.Deprecated('Use chatDescriptor instead')
const Chat$json = {
  '1': 'Chat',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 14, '6': '.ChatType', '10': 'type'},
    {'1': 'remote_conversation_key', '3': 2, '4': 1, '5': 11, '6': '.TypedKey', '10': 'remoteConversationKey'},
  ],
};

/// Descriptor for `Chat`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatDescriptor = $convert.base64Decode(
    'CgRDaGF0Eh0KBHR5cGUYASABKA4yCS5DaGF0VHlwZVIEdHlwZRJBChdyZW1vdGVfY29udmVyc2'
    'F0aW9uX2tleRgCIAEoCzIJLlR5cGVkS2V5UhVyZW1vdGVDb252ZXJzYXRpb25LZXk=');

@$core.Deprecated('Use accountDescriptor instead')
const Account$json = {
  '1': 'Account',
  '2': [
    {'1': 'profile', '3': 1, '4': 1, '5': 11, '6': '.Profile', '10': 'profile'},
    {'1': 'invisible', '3': 2, '4': 1, '5': 8, '10': 'invisible'},
    {'1': 'auto_away_timeout_sec', '3': 3, '4': 1, '5': 13, '10': 'autoAwayTimeoutSec'},
    {'1': 'contact_list', '3': 4, '4': 1, '5': 11, '6': '.OwnedDHTRecordPointer', '10': 'contactList'},
    {'1': 'contact_invitation_records', '3': 5, '4': 1, '5': 11, '6': '.OwnedDHTRecordPointer', '10': 'contactInvitationRecords'},
    {'1': 'chat_list', '3': 6, '4': 1, '5': 11, '6': '.OwnedDHTRecordPointer', '10': 'chatList'},
  ],
};

/// Descriptor for `Account`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List accountDescriptor = $convert.base64Decode(
    'CgdBY2NvdW50EiIKB3Byb2ZpbGUYASABKAsyCC5Qcm9maWxlUgdwcm9maWxlEhwKCWludmlzaW'
    'JsZRgCIAEoCFIJaW52aXNpYmxlEjEKFWF1dG9fYXdheV90aW1lb3V0X3NlYxgDIAEoDVISYXV0'
    'b0F3YXlUaW1lb3V0U2VjEjkKDGNvbnRhY3RfbGlzdBgEIAEoCzIWLk93bmVkREhUUmVjb3JkUG'
    '9pbnRlclILY29udGFjdExpc3QSVAoaY29udGFjdF9pbnZpdGF0aW9uX3JlY29yZHMYBSABKAsy'
    'Fi5Pd25lZERIVFJlY29yZFBvaW50ZXJSGGNvbnRhY3RJbnZpdGF0aW9uUmVjb3JkcxIzCgljaG'
    'F0X2xpc3QYBiABKAsyFi5Pd25lZERIVFJlY29yZFBvaW50ZXJSCGNoYXRMaXN0');

@$core.Deprecated('Use contactInvitationDescriptor instead')
const ContactInvitation$json = {
  '1': 'ContactInvitation',
  '2': [
    {'1': 'contact_request_inbox_key', '3': 1, '4': 1, '5': 11, '6': '.TypedKey', '10': 'contactRequestInboxKey'},
    {'1': 'writer_secret', '3': 2, '4': 1, '5': 12, '10': 'writerSecret'},
  ],
};

/// Descriptor for `ContactInvitation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List contactInvitationDescriptor = $convert.base64Decode(
    'ChFDb250YWN0SW52aXRhdGlvbhJEChljb250YWN0X3JlcXVlc3RfaW5ib3hfa2V5GAEgASgLMg'
    'kuVHlwZWRLZXlSFmNvbnRhY3RSZXF1ZXN0SW5ib3hLZXkSIwoNd3JpdGVyX3NlY3JldBgCIAEo'
    'DFIMd3JpdGVyU2VjcmV0');

@$core.Deprecated('Use signedContactInvitationDescriptor instead')
const SignedContactInvitation$json = {
  '1': 'SignedContactInvitation',
  '2': [
    {'1': 'contact_invitation', '3': 1, '4': 1, '5': 12, '10': 'contactInvitation'},
    {'1': 'identity_signature', '3': 2, '4': 1, '5': 11, '6': '.Signature', '10': 'identitySignature'},
  ],
};

/// Descriptor for `SignedContactInvitation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List signedContactInvitationDescriptor = $convert.base64Decode(
    'ChdTaWduZWRDb250YWN0SW52aXRhdGlvbhItChJjb250YWN0X2ludml0YXRpb24YASABKAxSEW'
    'NvbnRhY3RJbnZpdGF0aW9uEjkKEmlkZW50aXR5X3NpZ25hdHVyZRgCIAEoCzIKLlNpZ25hdHVy'
    'ZVIRaWRlbnRpdHlTaWduYXR1cmU=');

@$core.Deprecated('Use contactRequestDescriptor instead')
const ContactRequest$json = {
  '1': 'ContactRequest',
  '2': [
    {'1': 'encryption_key_type', '3': 1, '4': 1, '5': 14, '6': '.EncryptionKeyType', '10': 'encryptionKeyType'},
    {'1': 'private', '3': 2, '4': 1, '5': 12, '10': 'private'},
  ],
};

/// Descriptor for `ContactRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List contactRequestDescriptor = $convert.base64Decode(
    'Cg5Db250YWN0UmVxdWVzdBJCChNlbmNyeXB0aW9uX2tleV90eXBlGAEgASgOMhIuRW5jcnlwdG'
    'lvbktleVR5cGVSEWVuY3J5cHRpb25LZXlUeXBlEhgKB3ByaXZhdGUYAiABKAxSB3ByaXZhdGU=');

@$core.Deprecated('Use contactRequestPrivateDescriptor instead')
const ContactRequestPrivate$json = {
  '1': 'ContactRequestPrivate',
  '2': [
    {'1': 'writer_key', '3': 1, '4': 1, '5': 11, '6': '.CryptoKey', '10': 'writerKey'},
    {'1': 'profile', '3': 2, '4': 1, '5': 11, '6': '.Profile', '10': 'profile'},
    {'1': 'identity_master_record_key', '3': 3, '4': 1, '5': 11, '6': '.TypedKey', '10': 'identityMasterRecordKey'},
    {'1': 'chat_record_key', '3': 4, '4': 1, '5': 11, '6': '.TypedKey', '10': 'chatRecordKey'},
    {'1': 'expiration', '3': 5, '4': 1, '5': 4, '10': 'expiration'},
  ],
};

/// Descriptor for `ContactRequestPrivate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List contactRequestPrivateDescriptor = $convert.base64Decode(
    'ChVDb250YWN0UmVxdWVzdFByaXZhdGUSKQoKd3JpdGVyX2tleRgBIAEoCzIKLkNyeXB0b0tleV'
    'IJd3JpdGVyS2V5EiIKB3Byb2ZpbGUYAiABKAsyCC5Qcm9maWxlUgdwcm9maWxlEkYKGmlkZW50'
    'aXR5X21hc3Rlcl9yZWNvcmRfa2V5GAMgASgLMgkuVHlwZWRLZXlSF2lkZW50aXR5TWFzdGVyUm'
    'Vjb3JkS2V5EjEKD2NoYXRfcmVjb3JkX2tleRgEIAEoCzIJLlR5cGVkS2V5Ug1jaGF0UmVjb3Jk'
    'S2V5Eh4KCmV4cGlyYXRpb24YBSABKARSCmV4cGlyYXRpb24=');

@$core.Deprecated('Use contactResponseDescriptor instead')
const ContactResponse$json = {
  '1': 'ContactResponse',
  '2': [
    {'1': 'accept', '3': 1, '4': 1, '5': 8, '10': 'accept'},
    {'1': 'identity_master_record_key', '3': 2, '4': 1, '5': 11, '6': '.TypedKey', '10': 'identityMasterRecordKey'},
    {'1': 'remote_conversation_key', '3': 3, '4': 1, '5': 11, '6': '.TypedKey', '10': 'remoteConversationKey'},
  ],
};

/// Descriptor for `ContactResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List contactResponseDescriptor = $convert.base64Decode(
    'Cg9Db250YWN0UmVzcG9uc2USFgoGYWNjZXB0GAEgASgIUgZhY2NlcHQSRgoaaWRlbnRpdHlfbW'
    'FzdGVyX3JlY29yZF9rZXkYAiABKAsyCS5UeXBlZEtleVIXaWRlbnRpdHlNYXN0ZXJSZWNvcmRL'
    'ZXkSQQoXcmVtb3RlX2NvbnZlcnNhdGlvbl9rZXkYAyABKAsyCS5UeXBlZEtleVIVcmVtb3RlQ2'
    '9udmVyc2F0aW9uS2V5');

@$core.Deprecated('Use signedContactResponseDescriptor instead')
const SignedContactResponse$json = {
  '1': 'SignedContactResponse',
  '2': [
    {'1': 'contact_response', '3': 1, '4': 1, '5': 12, '10': 'contactResponse'},
    {'1': 'identity_signature', '3': 2, '4': 1, '5': 11, '6': '.Signature', '10': 'identitySignature'},
  ],
};

/// Descriptor for `SignedContactResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List signedContactResponseDescriptor = $convert.base64Decode(
    'ChVTaWduZWRDb250YWN0UmVzcG9uc2USKQoQY29udGFjdF9yZXNwb25zZRgBIAEoDFIPY29udG'
    'FjdFJlc3BvbnNlEjkKEmlkZW50aXR5X3NpZ25hdHVyZRgCIAEoCzIKLlNpZ25hdHVyZVIRaWRl'
    'bnRpdHlTaWduYXR1cmU=');

@$core.Deprecated('Use contactInvitationRecordDescriptor instead')
const ContactInvitationRecord$json = {
  '1': 'ContactInvitationRecord',
  '2': [
    {'1': 'contact_request_inbox', '3': 1, '4': 1, '5': 11, '6': '.OwnedDHTRecordPointer', '10': 'contactRequestInbox'},
    {'1': 'writer_key', '3': 2, '4': 1, '5': 11, '6': '.CryptoKey', '10': 'writerKey'},
    {'1': 'writer_secret', '3': 3, '4': 1, '5': 11, '6': '.CryptoKey', '10': 'writerSecret'},
    {'1': 'local_conversation', '3': 4, '4': 1, '5': 11, '6': '.OwnedDHTRecordPointer', '10': 'localConversation'},
    {'1': 'expiration', '3': 5, '4': 1, '5': 4, '10': 'expiration'},
    {'1': 'invitation', '3': 6, '4': 1, '5': 12, '10': 'invitation'},
    {'1': 'message', '3': 7, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `ContactInvitationRecord`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List contactInvitationRecordDescriptor = $convert.base64Decode(
    'ChdDb250YWN0SW52aXRhdGlvblJlY29yZBJKChVjb250YWN0X3JlcXVlc3RfaW5ib3gYASABKA'
    'syFi5Pd25lZERIVFJlY29yZFBvaW50ZXJSE2NvbnRhY3RSZXF1ZXN0SW5ib3gSKQoKd3JpdGVy'
    'X2tleRgCIAEoCzIKLkNyeXB0b0tleVIJd3JpdGVyS2V5Ei8KDXdyaXRlcl9zZWNyZXQYAyABKA'
    'syCi5DcnlwdG9LZXlSDHdyaXRlclNlY3JldBJFChJsb2NhbF9jb252ZXJzYXRpb24YBCABKAsy'
    'Fi5Pd25lZERIVFJlY29yZFBvaW50ZXJSEWxvY2FsQ29udmVyc2F0aW9uEh4KCmV4cGlyYXRpb2'
    '4YBSABKARSCmV4cGlyYXRpb24SHgoKaW52aXRhdGlvbhgGIAEoDFIKaW52aXRhdGlvbhIYCgdt'
    'ZXNzYWdlGAcgASgJUgdtZXNzYWdl');

