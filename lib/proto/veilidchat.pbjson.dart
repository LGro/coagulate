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

@$core.Deprecated('Use attachmentDescriptor instead')
const Attachment$json = {
  '1': 'Attachment',
  '2': [
    {'1': 'kind', '3': 1, '4': 1, '5': 14, '6': '.veilidchat.AttachmentKind', '10': 'kind'},
    {'1': 'mime', '3': 2, '4': 1, '5': 9, '10': 'mime'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'content', '3': 4, '4': 1, '5': 11, '6': '.dht.DataReference', '10': 'content'},
    {'1': 'signature', '3': 5, '4': 1, '5': 11, '6': '.veilid.Signature', '10': 'signature'},
  ],
};

/// Descriptor for `Attachment`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List attachmentDescriptor = $convert.base64Decode(
    'CgpBdHRhY2htZW50Ei4KBGtpbmQYASABKA4yGi52ZWlsaWRjaGF0LkF0dGFjaG1lbnRLaW5kUg'
    'RraW5kEhIKBG1pbWUYAiABKAlSBG1pbWUSEgoEbmFtZRgDIAEoCVIEbmFtZRIsCgdjb250ZW50'
    'GAQgASgLMhIuZGh0LkRhdGFSZWZlcmVuY2VSB2NvbnRlbnQSLwoJc2lnbmF0dXJlGAUgASgLMh'
    'EudmVpbGlkLlNpZ25hdHVyZVIJc2lnbmF0dXJl');

@$core.Deprecated('Use messageDescriptor instead')
const Message$json = {
  '1': 'Message',
  '2': [
    {'1': 'author', '3': 1, '4': 1, '5': 11, '6': '.veilid.TypedKey', '10': 'author'},
    {'1': 'timestamp', '3': 2, '4': 1, '5': 4, '10': 'timestamp'},
    {'1': 'text', '3': 3, '4': 1, '5': 9, '10': 'text'},
    {'1': 'signature', '3': 4, '4': 1, '5': 11, '6': '.veilid.Signature', '10': 'signature'},
    {'1': 'attachments', '3': 5, '4': 3, '5': 11, '6': '.veilidchat.Attachment', '10': 'attachments'},
  ],
};

/// Descriptor for `Message`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageDescriptor = $convert.base64Decode(
    'CgdNZXNzYWdlEigKBmF1dGhvchgBIAEoCzIQLnZlaWxpZC5UeXBlZEtleVIGYXV0aG9yEhwKCX'
    'RpbWVzdGFtcBgCIAEoBFIJdGltZXN0YW1wEhIKBHRleHQYAyABKAlSBHRleHQSLwoJc2lnbmF0'
    'dXJlGAQgASgLMhEudmVpbGlkLlNpZ25hdHVyZVIJc2lnbmF0dXJlEjgKC2F0dGFjaG1lbnRzGA'
    'UgAygLMhYudmVpbGlkY2hhdC5BdHRhY2htZW50UgthdHRhY2htZW50cw==');

@$core.Deprecated('Use conversationDescriptor instead')
const Conversation$json = {
  '1': 'Conversation',
  '2': [
    {'1': 'profile', '3': 1, '4': 1, '5': 11, '6': '.veilidchat.Profile', '10': 'profile'},
    {'1': 'identity_master_json', '3': 2, '4': 1, '5': 9, '10': 'identityMasterJson'},
    {'1': 'messages', '3': 3, '4': 1, '5': 11, '6': '.veilid.TypedKey', '10': 'messages'},
  ],
};

/// Descriptor for `Conversation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationDescriptor = $convert.base64Decode(
    'CgxDb252ZXJzYXRpb24SLQoHcHJvZmlsZRgBIAEoCzITLnZlaWxpZGNoYXQuUHJvZmlsZVIHcH'
    'JvZmlsZRIwChRpZGVudGl0eV9tYXN0ZXJfanNvbhgCIAEoCVISaWRlbnRpdHlNYXN0ZXJKc29u'
    'EiwKCG1lc3NhZ2VzGAMgASgLMhAudmVpbGlkLlR5cGVkS2V5UghtZXNzYWdlcw==');

@$core.Deprecated('Use contactDescriptor instead')
const Contact$json = {
  '1': 'Contact',
  '2': [
    {'1': 'edited_profile', '3': 1, '4': 1, '5': 11, '6': '.veilidchat.Profile', '10': 'editedProfile'},
    {'1': 'remote_profile', '3': 2, '4': 1, '5': 11, '6': '.veilidchat.Profile', '10': 'remoteProfile'},
    {'1': 'identity_master_json', '3': 3, '4': 1, '5': 9, '10': 'identityMasterJson'},
    {'1': 'identity_public_key', '3': 4, '4': 1, '5': 11, '6': '.veilid.TypedKey', '10': 'identityPublicKey'},
    {'1': 'remote_conversation_record_key', '3': 5, '4': 1, '5': 11, '6': '.veilid.TypedKey', '10': 'remoteConversationRecordKey'},
    {'1': 'local_conversation_record_key', '3': 6, '4': 1, '5': 11, '6': '.veilid.TypedKey', '10': 'localConversationRecordKey'},
    {'1': 'show_availability', '3': 7, '4': 1, '5': 8, '10': 'showAvailability'},
  ],
};

/// Descriptor for `Contact`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List contactDescriptor = $convert.base64Decode(
    'CgdDb250YWN0EjoKDmVkaXRlZF9wcm9maWxlGAEgASgLMhMudmVpbGlkY2hhdC5Qcm9maWxlUg'
    '1lZGl0ZWRQcm9maWxlEjoKDnJlbW90ZV9wcm9maWxlGAIgASgLMhMudmVpbGlkY2hhdC5Qcm9m'
    'aWxlUg1yZW1vdGVQcm9maWxlEjAKFGlkZW50aXR5X21hc3Rlcl9qc29uGAMgASgJUhJpZGVudG'
    'l0eU1hc3Rlckpzb24SQAoTaWRlbnRpdHlfcHVibGljX2tleRgEIAEoCzIQLnZlaWxpZC5UeXBl'
    'ZEtleVIRaWRlbnRpdHlQdWJsaWNLZXkSVQoecmVtb3RlX2NvbnZlcnNhdGlvbl9yZWNvcmRfa2'
    'V5GAUgASgLMhAudmVpbGlkLlR5cGVkS2V5UhtyZW1vdGVDb252ZXJzYXRpb25SZWNvcmRLZXkS'
    'UwodbG9jYWxfY29udmVyc2F0aW9uX3JlY29yZF9rZXkYBiABKAsyEC52ZWlsaWQuVHlwZWRLZX'
    'lSGmxvY2FsQ29udmVyc2F0aW9uUmVjb3JkS2V5EisKEXNob3dfYXZhaWxhYmlsaXR5GAcgASgI'
    'UhBzaG93QXZhaWxhYmlsaXR5');

@$core.Deprecated('Use profileDescriptor instead')
const Profile$json = {
  '1': 'Profile',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'pronouns', '3': 2, '4': 1, '5': 9, '10': 'pronouns'},
    {'1': 'status', '3': 3, '4': 1, '5': 9, '10': 'status'},
    {'1': 'availability', '3': 4, '4': 1, '5': 14, '6': '.veilidchat.Availability', '10': 'availability'},
    {'1': 'avatar', '3': 5, '4': 1, '5': 11, '6': '.veilid.TypedKey', '9': 0, '10': 'avatar', '17': true},
  ],
  '8': [
    {'1': '_avatar'},
  ],
};

/// Descriptor for `Profile`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List profileDescriptor = $convert.base64Decode(
    'CgdQcm9maWxlEhIKBG5hbWUYASABKAlSBG5hbWUSGgoIcHJvbm91bnMYAiABKAlSCHByb25vdW'
    '5zEhYKBnN0YXR1cxgDIAEoCVIGc3RhdHVzEjwKDGF2YWlsYWJpbGl0eRgEIAEoDjIYLnZlaWxp'
    'ZGNoYXQuQXZhaWxhYmlsaXR5UgxhdmFpbGFiaWxpdHkSLQoGYXZhdGFyGAUgASgLMhAudmVpbG'
    'lkLlR5cGVkS2V5SABSBmF2YXRhcogBAUIJCgdfYXZhdGFy');

@$core.Deprecated('Use chatDescriptor instead')
const Chat$json = {
  '1': 'Chat',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 14, '6': '.veilidchat.ChatType', '10': 'type'},
    {'1': 'remote_conversation_record_key', '3': 2, '4': 1, '5': 11, '6': '.veilid.TypedKey', '10': 'remoteConversationRecordKey'},
    {'1': 'reconciled_chat_record', '3': 3, '4': 1, '5': 11, '6': '.dht.OwnedDHTRecordPointer', '10': 'reconciledChatRecord'},
  ],
};

/// Descriptor for `Chat`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatDescriptor = $convert.base64Decode(
    'CgRDaGF0EigKBHR5cGUYASABKA4yFC52ZWlsaWRjaGF0LkNoYXRUeXBlUgR0eXBlElUKHnJlbW'
    '90ZV9jb252ZXJzYXRpb25fcmVjb3JkX2tleRgCIAEoCzIQLnZlaWxpZC5UeXBlZEtleVIbcmVt'
    'b3RlQ29udmVyc2F0aW9uUmVjb3JkS2V5ElAKFnJlY29uY2lsZWRfY2hhdF9yZWNvcmQYAyABKA'
    'syGi5kaHQuT3duZWRESFRSZWNvcmRQb2ludGVyUhRyZWNvbmNpbGVkQ2hhdFJlY29yZA==');

@$core.Deprecated('Use accountDescriptor instead')
const Account$json = {
  '1': 'Account',
  '2': [
    {'1': 'profile', '3': 1, '4': 1, '5': 11, '6': '.veilidchat.Profile', '10': 'profile'},
    {'1': 'invisible', '3': 2, '4': 1, '5': 8, '10': 'invisible'},
    {'1': 'auto_away_timeout_sec', '3': 3, '4': 1, '5': 13, '10': 'autoAwayTimeoutSec'},
    {'1': 'contact_list', '3': 4, '4': 1, '5': 11, '6': '.dht.OwnedDHTRecordPointer', '10': 'contactList'},
    {'1': 'contact_invitation_records', '3': 5, '4': 1, '5': 11, '6': '.dht.OwnedDHTRecordPointer', '10': 'contactInvitationRecords'},
    {'1': 'chat_list', '3': 6, '4': 1, '5': 11, '6': '.dht.OwnedDHTRecordPointer', '10': 'chatList'},
  ],
};

/// Descriptor for `Account`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List accountDescriptor = $convert.base64Decode(
    'CgdBY2NvdW50Ei0KB3Byb2ZpbGUYASABKAsyEy52ZWlsaWRjaGF0LlByb2ZpbGVSB3Byb2ZpbG'
    'USHAoJaW52aXNpYmxlGAIgASgIUglpbnZpc2libGUSMQoVYXV0b19hd2F5X3RpbWVvdXRfc2Vj'
    'GAMgASgNUhJhdXRvQXdheVRpbWVvdXRTZWMSPQoMY29udGFjdF9saXN0GAQgASgLMhouZGh0Lk'
    '93bmVkREhUUmVjb3JkUG9pbnRlclILY29udGFjdExpc3QSWAoaY29udGFjdF9pbnZpdGF0aW9u'
    'X3JlY29yZHMYBSABKAsyGi5kaHQuT3duZWRESFRSZWNvcmRQb2ludGVyUhhjb250YWN0SW52aX'
    'RhdGlvblJlY29yZHMSNwoJY2hhdF9saXN0GAYgASgLMhouZGh0Lk93bmVkREhUUmVjb3JkUG9p'
    'bnRlclIIY2hhdExpc3Q=');

@$core.Deprecated('Use contactInvitationDescriptor instead')
const ContactInvitation$json = {
  '1': 'ContactInvitation',
  '2': [
    {'1': 'contact_request_inbox_key', '3': 1, '4': 1, '5': 11, '6': '.veilid.TypedKey', '10': 'contactRequestInboxKey'},
    {'1': 'writer_secret', '3': 2, '4': 1, '5': 12, '10': 'writerSecret'},
  ],
};

/// Descriptor for `ContactInvitation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List contactInvitationDescriptor = $convert.base64Decode(
    'ChFDb250YWN0SW52aXRhdGlvbhJLChljb250YWN0X3JlcXVlc3RfaW5ib3hfa2V5GAEgASgLMh'
    'AudmVpbGlkLlR5cGVkS2V5UhZjb250YWN0UmVxdWVzdEluYm94S2V5EiMKDXdyaXRlcl9zZWNy'
    'ZXQYAiABKAxSDHdyaXRlclNlY3JldA==');

@$core.Deprecated('Use signedContactInvitationDescriptor instead')
const SignedContactInvitation$json = {
  '1': 'SignedContactInvitation',
  '2': [
    {'1': 'contact_invitation', '3': 1, '4': 1, '5': 12, '10': 'contactInvitation'},
    {'1': 'identity_signature', '3': 2, '4': 1, '5': 11, '6': '.veilid.Signature', '10': 'identitySignature'},
  ],
};

/// Descriptor for `SignedContactInvitation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List signedContactInvitationDescriptor = $convert.base64Decode(
    'ChdTaWduZWRDb250YWN0SW52aXRhdGlvbhItChJjb250YWN0X2ludml0YXRpb24YASABKAxSEW'
    'NvbnRhY3RJbnZpdGF0aW9uEkAKEmlkZW50aXR5X3NpZ25hdHVyZRgCIAEoCzIRLnZlaWxpZC5T'
    'aWduYXR1cmVSEWlkZW50aXR5U2lnbmF0dXJl');

@$core.Deprecated('Use contactRequestDescriptor instead')
const ContactRequest$json = {
  '1': 'ContactRequest',
  '2': [
    {'1': 'encryption_key_type', '3': 1, '4': 1, '5': 14, '6': '.veilidchat.EncryptionKeyType', '10': 'encryptionKeyType'},
    {'1': 'private', '3': 2, '4': 1, '5': 12, '10': 'private'},
  ],
};

/// Descriptor for `ContactRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List contactRequestDescriptor = $convert.base64Decode(
    'Cg5Db250YWN0UmVxdWVzdBJNChNlbmNyeXB0aW9uX2tleV90eXBlGAEgASgOMh0udmVpbGlkY2'
    'hhdC5FbmNyeXB0aW9uS2V5VHlwZVIRZW5jcnlwdGlvbktleVR5cGUSGAoHcHJpdmF0ZRgCIAEo'
    'DFIHcHJpdmF0ZQ==');

@$core.Deprecated('Use contactRequestPrivateDescriptor instead')
const ContactRequestPrivate$json = {
  '1': 'ContactRequestPrivate',
  '2': [
    {'1': 'writer_key', '3': 1, '4': 1, '5': 11, '6': '.veilid.CryptoKey', '10': 'writerKey'},
    {'1': 'profile', '3': 2, '4': 1, '5': 11, '6': '.veilidchat.Profile', '10': 'profile'},
    {'1': 'identity_master_record_key', '3': 3, '4': 1, '5': 11, '6': '.veilid.TypedKey', '10': 'identityMasterRecordKey'},
    {'1': 'chat_record_key', '3': 4, '4': 1, '5': 11, '6': '.veilid.TypedKey', '10': 'chatRecordKey'},
    {'1': 'expiration', '3': 5, '4': 1, '5': 4, '10': 'expiration'},
  ],
};

/// Descriptor for `ContactRequestPrivate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List contactRequestPrivateDescriptor = $convert.base64Decode(
    'ChVDb250YWN0UmVxdWVzdFByaXZhdGUSMAoKd3JpdGVyX2tleRgBIAEoCzIRLnZlaWxpZC5Dcn'
    'lwdG9LZXlSCXdyaXRlcktleRItCgdwcm9maWxlGAIgASgLMhMudmVpbGlkY2hhdC5Qcm9maWxl'
    'Ugdwcm9maWxlEk0KGmlkZW50aXR5X21hc3Rlcl9yZWNvcmRfa2V5GAMgASgLMhAudmVpbGlkLl'
    'R5cGVkS2V5UhdpZGVudGl0eU1hc3RlclJlY29yZEtleRI4Cg9jaGF0X3JlY29yZF9rZXkYBCAB'
    'KAsyEC52ZWlsaWQuVHlwZWRLZXlSDWNoYXRSZWNvcmRLZXkSHgoKZXhwaXJhdGlvbhgFIAEoBF'
    'IKZXhwaXJhdGlvbg==');

@$core.Deprecated('Use contactResponseDescriptor instead')
const ContactResponse$json = {
  '1': 'ContactResponse',
  '2': [
    {'1': 'accept', '3': 1, '4': 1, '5': 8, '10': 'accept'},
    {'1': 'identity_master_record_key', '3': 2, '4': 1, '5': 11, '6': '.veilid.TypedKey', '10': 'identityMasterRecordKey'},
    {'1': 'remote_conversation_record_key', '3': 3, '4': 1, '5': 11, '6': '.veilid.TypedKey', '10': 'remoteConversationRecordKey'},
  ],
};

/// Descriptor for `ContactResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List contactResponseDescriptor = $convert.base64Decode(
    'Cg9Db250YWN0UmVzcG9uc2USFgoGYWNjZXB0GAEgASgIUgZhY2NlcHQSTQoaaWRlbnRpdHlfbW'
    'FzdGVyX3JlY29yZF9rZXkYAiABKAsyEC52ZWlsaWQuVHlwZWRLZXlSF2lkZW50aXR5TWFzdGVy'
    'UmVjb3JkS2V5ElUKHnJlbW90ZV9jb252ZXJzYXRpb25fcmVjb3JkX2tleRgDIAEoCzIQLnZlaW'
    'xpZC5UeXBlZEtleVIbcmVtb3RlQ29udmVyc2F0aW9uUmVjb3JkS2V5');

@$core.Deprecated('Use signedContactResponseDescriptor instead')
const SignedContactResponse$json = {
  '1': 'SignedContactResponse',
  '2': [
    {'1': 'contact_response', '3': 1, '4': 1, '5': 12, '10': 'contactResponse'},
    {'1': 'identity_signature', '3': 2, '4': 1, '5': 11, '6': '.veilid.Signature', '10': 'identitySignature'},
  ],
};

/// Descriptor for `SignedContactResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List signedContactResponseDescriptor = $convert.base64Decode(
    'ChVTaWduZWRDb250YWN0UmVzcG9uc2USKQoQY29udGFjdF9yZXNwb25zZRgBIAEoDFIPY29udG'
    'FjdFJlc3BvbnNlEkAKEmlkZW50aXR5X3NpZ25hdHVyZRgCIAEoCzIRLnZlaWxpZC5TaWduYXR1'
    'cmVSEWlkZW50aXR5U2lnbmF0dXJl');

@$core.Deprecated('Use contactInvitationRecordDescriptor instead')
const ContactInvitationRecord$json = {
  '1': 'ContactInvitationRecord',
  '2': [
    {'1': 'contact_request_inbox', '3': 1, '4': 1, '5': 11, '6': '.dht.OwnedDHTRecordPointer', '10': 'contactRequestInbox'},
    {'1': 'writer_key', '3': 2, '4': 1, '5': 11, '6': '.veilid.CryptoKey', '10': 'writerKey'},
    {'1': 'writer_secret', '3': 3, '4': 1, '5': 11, '6': '.veilid.CryptoKey', '10': 'writerSecret'},
    {'1': 'local_conversation_record_key', '3': 4, '4': 1, '5': 11, '6': '.veilid.TypedKey', '10': 'localConversationRecordKey'},
    {'1': 'expiration', '3': 5, '4': 1, '5': 4, '10': 'expiration'},
    {'1': 'invitation', '3': 6, '4': 1, '5': 12, '10': 'invitation'},
    {'1': 'message', '3': 7, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `ContactInvitationRecord`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List contactInvitationRecordDescriptor = $convert.base64Decode(
    'ChdDb250YWN0SW52aXRhdGlvblJlY29yZBJOChVjb250YWN0X3JlcXVlc3RfaW5ib3gYASABKA'
    'syGi5kaHQuT3duZWRESFRSZWNvcmRQb2ludGVyUhNjb250YWN0UmVxdWVzdEluYm94EjAKCndy'
    'aXRlcl9rZXkYAiABKAsyES52ZWlsaWQuQ3J5cHRvS2V5Ugl3cml0ZXJLZXkSNgoNd3JpdGVyX3'
    'NlY3JldBgDIAEoCzIRLnZlaWxpZC5DcnlwdG9LZXlSDHdyaXRlclNlY3JldBJTCh1sb2NhbF9j'
    'b252ZXJzYXRpb25fcmVjb3JkX2tleRgEIAEoCzIQLnZlaWxpZC5UeXBlZEtleVIabG9jYWxDb2'
    '52ZXJzYXRpb25SZWNvcmRLZXkSHgoKZXhwaXJhdGlvbhgFIAEoBFIKZXhwaXJhdGlvbhIeCgpp'
    'bnZpdGF0aW9uGAYgASgMUgppbnZpdGF0aW9uEhgKB21lc3NhZ2UYByABKAlSB21lc3NhZ2U=');

