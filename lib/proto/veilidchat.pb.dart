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

import 'dht.pb.dart' as $0;
import 'veilid.pb.dart' as $1;
import 'veilidchat.pbenum.dart';

export 'veilidchat.pbenum.dart';

class Attachment extends $pb.GeneratedMessage {
  factory Attachment() => create();
  Attachment._() : super();
  factory Attachment.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Attachment.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Attachment', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilidchat'), createEmptyInstance: create)
    ..e<AttachmentKind>(1, _omitFieldNames ? '' : 'kind', $pb.PbFieldType.OE, defaultOrMaker: AttachmentKind.ATTACHMENT_KIND_UNSPECIFIED, valueOf: AttachmentKind.valueOf, enumValues: AttachmentKind.values)
    ..aOS(2, _omitFieldNames ? '' : 'mime')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOM<$0.DataReference>(4, _omitFieldNames ? '' : 'content', subBuilder: $0.DataReference.create)
    ..aOM<$1.Signature>(5, _omitFieldNames ? '' : 'signature', subBuilder: $1.Signature.create)
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
  $0.DataReference get content => $_getN(3);
  @$pb.TagNumber(4)
  set content($0.DataReference v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasContent() => $_has(3);
  @$pb.TagNumber(4)
  void clearContent() => clearField(4);
  @$pb.TagNumber(4)
  $0.DataReference ensureContent() => $_ensure(3);

  @$pb.TagNumber(5)
  $1.Signature get signature => $_getN(4);
  @$pb.TagNumber(5)
  set signature($1.Signature v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasSignature() => $_has(4);
  @$pb.TagNumber(5)
  void clearSignature() => clearField(5);
  @$pb.TagNumber(5)
  $1.Signature ensureSignature() => $_ensure(4);
}

class Message extends $pb.GeneratedMessage {
  factory Message() => create();
  Message._() : super();
  factory Message.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Message.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Message', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilidchat'), createEmptyInstance: create)
    ..aOM<$1.TypedKey>(1, _omitFieldNames ? '' : 'author', subBuilder: $1.TypedKey.create)
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'timestamp', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(3, _omitFieldNames ? '' : 'text')
    ..aOM<$1.Signature>(4, _omitFieldNames ? '' : 'signature', subBuilder: $1.Signature.create)
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
  $1.TypedKey get author => $_getN(0);
  @$pb.TagNumber(1)
  set author($1.TypedKey v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasAuthor() => $_has(0);
  @$pb.TagNumber(1)
  void clearAuthor() => clearField(1);
  @$pb.TagNumber(1)
  $1.TypedKey ensureAuthor() => $_ensure(0);

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
  $1.Signature get signature => $_getN(3);
  @$pb.TagNumber(4)
  set signature($1.Signature v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasSignature() => $_has(3);
  @$pb.TagNumber(4)
  void clearSignature() => clearField(4);
  @$pb.TagNumber(4)
  $1.Signature ensureSignature() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.List<Attachment> get attachments => $_getList(4);
}

class Conversation extends $pb.GeneratedMessage {
  factory Conversation() => create();
  Conversation._() : super();
  factory Conversation.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Conversation.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Conversation', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilidchat'), createEmptyInstance: create)
    ..aOM<Profile>(1, _omitFieldNames ? '' : 'profile', subBuilder: Profile.create)
    ..aOS(2, _omitFieldNames ? '' : 'identityMasterJson')
    ..aOM<$1.TypedKey>(3, _omitFieldNames ? '' : 'messages', subBuilder: $1.TypedKey.create)
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
  $core.String get identityMasterJson => $_getSZ(1);
  @$pb.TagNumber(2)
  set identityMasterJson($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasIdentityMasterJson() => $_has(1);
  @$pb.TagNumber(2)
  void clearIdentityMasterJson() => clearField(2);

  @$pb.TagNumber(3)
  $1.TypedKey get messages => $_getN(2);
  @$pb.TagNumber(3)
  set messages($1.TypedKey v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasMessages() => $_has(2);
  @$pb.TagNumber(3)
  void clearMessages() => clearField(3);
  @$pb.TagNumber(3)
  $1.TypedKey ensureMessages() => $_ensure(2);
}

class Contact extends $pb.GeneratedMessage {
  factory Contact() => create();
  Contact._() : super();
  factory Contact.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Contact.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Contact', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilidchat'), createEmptyInstance: create)
    ..aOM<Profile>(1, _omitFieldNames ? '' : 'editedProfile', subBuilder: Profile.create)
    ..aOM<Profile>(2, _omitFieldNames ? '' : 'remoteProfile', subBuilder: Profile.create)
    ..aOS(3, _omitFieldNames ? '' : 'identityMasterJson')
    ..aOM<$1.TypedKey>(4, _omitFieldNames ? '' : 'identityPublicKey', subBuilder: $1.TypedKey.create)
    ..aOM<$1.TypedKey>(5, _omitFieldNames ? '' : 'remoteConversationRecordKey', subBuilder: $1.TypedKey.create)
    ..aOM<$1.TypedKey>(6, _omitFieldNames ? '' : 'localConversationRecordKey', subBuilder: $1.TypedKey.create)
    ..aOB(7, _omitFieldNames ? '' : 'showAvailability')
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
  $core.String get identityMasterJson => $_getSZ(2);
  @$pb.TagNumber(3)
  set identityMasterJson($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasIdentityMasterJson() => $_has(2);
  @$pb.TagNumber(3)
  void clearIdentityMasterJson() => clearField(3);

  @$pb.TagNumber(4)
  $1.TypedKey get identityPublicKey => $_getN(3);
  @$pb.TagNumber(4)
  set identityPublicKey($1.TypedKey v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasIdentityPublicKey() => $_has(3);
  @$pb.TagNumber(4)
  void clearIdentityPublicKey() => clearField(4);
  @$pb.TagNumber(4)
  $1.TypedKey ensureIdentityPublicKey() => $_ensure(3);

  @$pb.TagNumber(5)
  $1.TypedKey get remoteConversationRecordKey => $_getN(4);
  @$pb.TagNumber(5)
  set remoteConversationRecordKey($1.TypedKey v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasRemoteConversationRecordKey() => $_has(4);
  @$pb.TagNumber(5)
  void clearRemoteConversationRecordKey() => clearField(5);
  @$pb.TagNumber(5)
  $1.TypedKey ensureRemoteConversationRecordKey() => $_ensure(4);

  @$pb.TagNumber(6)
  $1.TypedKey get localConversationRecordKey => $_getN(5);
  @$pb.TagNumber(6)
  set localConversationRecordKey($1.TypedKey v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasLocalConversationRecordKey() => $_has(5);
  @$pb.TagNumber(6)
  void clearLocalConversationRecordKey() => clearField(6);
  @$pb.TagNumber(6)
  $1.TypedKey ensureLocalConversationRecordKey() => $_ensure(5);

  @$pb.TagNumber(7)
  $core.bool get showAvailability => $_getBF(6);
  @$pb.TagNumber(7)
  set showAvailability($core.bool v) { $_setBool(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasShowAvailability() => $_has(6);
  @$pb.TagNumber(7)
  void clearShowAvailability() => clearField(7);
}

class Profile extends $pb.GeneratedMessage {
  factory Profile() => create();
  Profile._() : super();
  factory Profile.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Profile.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Profile', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilidchat'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'title')
    ..aOS(3, _omitFieldNames ? '' : 'status')
    ..e<Availability>(4, _omitFieldNames ? '' : 'availability', $pb.PbFieldType.OE, defaultOrMaker: Availability.AVAILABILITY_UNSPECIFIED, valueOf: Availability.valueOf, enumValues: Availability.values)
    ..aOM<$1.TypedKey>(5, _omitFieldNames ? '' : 'avatar', subBuilder: $1.TypedKey.create)
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
  $1.TypedKey get avatar => $_getN(4);
  @$pb.TagNumber(5)
  set avatar($1.TypedKey v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasAvatar() => $_has(4);
  @$pb.TagNumber(5)
  void clearAvatar() => clearField(5);
  @$pb.TagNumber(5)
  $1.TypedKey ensureAvatar() => $_ensure(4);
}

class Chat extends $pb.GeneratedMessage {
  factory Chat() => create();
  Chat._() : super();
  factory Chat.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Chat.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Chat', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilidchat'), createEmptyInstance: create)
    ..e<ChatType>(1, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OE, defaultOrMaker: ChatType.CHAT_TYPE_UNSPECIFIED, valueOf: ChatType.valueOf, enumValues: ChatType.values)
    ..aOM<$1.TypedKey>(2, _omitFieldNames ? '' : 'remoteConversationKey', subBuilder: $1.TypedKey.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Chat clone() => Chat()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Chat copyWith(void Function(Chat) updates) => super.copyWith((message) => updates(message as Chat)) as Chat;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Chat create() => Chat._();
  Chat createEmptyInstance() => create();
  static $pb.PbList<Chat> createRepeated() => $pb.PbList<Chat>();
  @$core.pragma('dart2js:noInline')
  static Chat getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Chat>(create);
  static Chat? _defaultInstance;

  @$pb.TagNumber(1)
  ChatType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(ChatType v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => clearField(1);

  @$pb.TagNumber(2)
  $1.TypedKey get remoteConversationKey => $_getN(1);
  @$pb.TagNumber(2)
  set remoteConversationKey($1.TypedKey v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasRemoteConversationKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearRemoteConversationKey() => clearField(2);
  @$pb.TagNumber(2)
  $1.TypedKey ensureRemoteConversationKey() => $_ensure(1);
}

class Account extends $pb.GeneratedMessage {
  factory Account() => create();
  Account._() : super();
  factory Account.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Account.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Account', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilidchat'), createEmptyInstance: create)
    ..aOM<Profile>(1, _omitFieldNames ? '' : 'profile', subBuilder: Profile.create)
    ..aOB(2, _omitFieldNames ? '' : 'invisible')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'autoAwayTimeoutSec', $pb.PbFieldType.OU3)
    ..aOM<$0.OwnedDHTRecordPointer>(4, _omitFieldNames ? '' : 'contactList', subBuilder: $0.OwnedDHTRecordPointer.create)
    ..aOM<$0.OwnedDHTRecordPointer>(5, _omitFieldNames ? '' : 'contactInvitationRecords', subBuilder: $0.OwnedDHTRecordPointer.create)
    ..aOM<$0.OwnedDHTRecordPointer>(6, _omitFieldNames ? '' : 'chatList', subBuilder: $0.OwnedDHTRecordPointer.create)
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
  $0.OwnedDHTRecordPointer get contactList => $_getN(3);
  @$pb.TagNumber(4)
  set contactList($0.OwnedDHTRecordPointer v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasContactList() => $_has(3);
  @$pb.TagNumber(4)
  void clearContactList() => clearField(4);
  @$pb.TagNumber(4)
  $0.OwnedDHTRecordPointer ensureContactList() => $_ensure(3);

  @$pb.TagNumber(5)
  $0.OwnedDHTRecordPointer get contactInvitationRecords => $_getN(4);
  @$pb.TagNumber(5)
  set contactInvitationRecords($0.OwnedDHTRecordPointer v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasContactInvitationRecords() => $_has(4);
  @$pb.TagNumber(5)
  void clearContactInvitationRecords() => clearField(5);
  @$pb.TagNumber(5)
  $0.OwnedDHTRecordPointer ensureContactInvitationRecords() => $_ensure(4);

  @$pb.TagNumber(6)
  $0.OwnedDHTRecordPointer get chatList => $_getN(5);
  @$pb.TagNumber(6)
  set chatList($0.OwnedDHTRecordPointer v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasChatList() => $_has(5);
  @$pb.TagNumber(6)
  void clearChatList() => clearField(6);
  @$pb.TagNumber(6)
  $0.OwnedDHTRecordPointer ensureChatList() => $_ensure(5);
}

class ContactInvitation extends $pb.GeneratedMessage {
  factory ContactInvitation() => create();
  ContactInvitation._() : super();
  factory ContactInvitation.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ContactInvitation.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ContactInvitation', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilidchat'), createEmptyInstance: create)
    ..aOM<$1.TypedKey>(1, _omitFieldNames ? '' : 'contactRequestInboxKey', subBuilder: $1.TypedKey.create)
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'writerSecret', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ContactInvitation clone() => ContactInvitation()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ContactInvitation copyWith(void Function(ContactInvitation) updates) => super.copyWith((message) => updates(message as ContactInvitation)) as ContactInvitation;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ContactInvitation create() => ContactInvitation._();
  ContactInvitation createEmptyInstance() => create();
  static $pb.PbList<ContactInvitation> createRepeated() => $pb.PbList<ContactInvitation>();
  @$core.pragma('dart2js:noInline')
  static ContactInvitation getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ContactInvitation>(create);
  static ContactInvitation? _defaultInstance;

  @$pb.TagNumber(1)
  $1.TypedKey get contactRequestInboxKey => $_getN(0);
  @$pb.TagNumber(1)
  set contactRequestInboxKey($1.TypedKey v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasContactRequestInboxKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearContactRequestInboxKey() => clearField(1);
  @$pb.TagNumber(1)
  $1.TypedKey ensureContactRequestInboxKey() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.List<$core.int> get writerSecret => $_getN(1);
  @$pb.TagNumber(2)
  set writerSecret($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWriterSecret() => $_has(1);
  @$pb.TagNumber(2)
  void clearWriterSecret() => clearField(2);
}

class SignedContactInvitation extends $pb.GeneratedMessage {
  factory SignedContactInvitation() => create();
  SignedContactInvitation._() : super();
  factory SignedContactInvitation.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SignedContactInvitation.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SignedContactInvitation', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilidchat'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'contactInvitation', $pb.PbFieldType.OY)
    ..aOM<$1.Signature>(2, _omitFieldNames ? '' : 'identitySignature', subBuilder: $1.Signature.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SignedContactInvitation clone() => SignedContactInvitation()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SignedContactInvitation copyWith(void Function(SignedContactInvitation) updates) => super.copyWith((message) => updates(message as SignedContactInvitation)) as SignedContactInvitation;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SignedContactInvitation create() => SignedContactInvitation._();
  SignedContactInvitation createEmptyInstance() => create();
  static $pb.PbList<SignedContactInvitation> createRepeated() => $pb.PbList<SignedContactInvitation>();
  @$core.pragma('dart2js:noInline')
  static SignedContactInvitation getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SignedContactInvitation>(create);
  static SignedContactInvitation? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get contactInvitation => $_getN(0);
  @$pb.TagNumber(1)
  set contactInvitation($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasContactInvitation() => $_has(0);
  @$pb.TagNumber(1)
  void clearContactInvitation() => clearField(1);

  @$pb.TagNumber(2)
  $1.Signature get identitySignature => $_getN(1);
  @$pb.TagNumber(2)
  set identitySignature($1.Signature v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasIdentitySignature() => $_has(1);
  @$pb.TagNumber(2)
  void clearIdentitySignature() => clearField(2);
  @$pb.TagNumber(2)
  $1.Signature ensureIdentitySignature() => $_ensure(1);
}

class ContactRequest extends $pb.GeneratedMessage {
  factory ContactRequest() => create();
  ContactRequest._() : super();
  factory ContactRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ContactRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ContactRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilidchat'), createEmptyInstance: create)
    ..e<EncryptionKeyType>(1, _omitFieldNames ? '' : 'encryptionKeyType', $pb.PbFieldType.OE, defaultOrMaker: EncryptionKeyType.ENCRYPTION_KEY_TYPE_UNSPECIFIED, valueOf: EncryptionKeyType.valueOf, enumValues: EncryptionKeyType.values)
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'private', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ContactRequest clone() => ContactRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ContactRequest copyWith(void Function(ContactRequest) updates) => super.copyWith((message) => updates(message as ContactRequest)) as ContactRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ContactRequest create() => ContactRequest._();
  ContactRequest createEmptyInstance() => create();
  static $pb.PbList<ContactRequest> createRepeated() => $pb.PbList<ContactRequest>();
  @$core.pragma('dart2js:noInline')
  static ContactRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ContactRequest>(create);
  static ContactRequest? _defaultInstance;

  @$pb.TagNumber(1)
  EncryptionKeyType get encryptionKeyType => $_getN(0);
  @$pb.TagNumber(1)
  set encryptionKeyType(EncryptionKeyType v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasEncryptionKeyType() => $_has(0);
  @$pb.TagNumber(1)
  void clearEncryptionKeyType() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get private => $_getN(1);
  @$pb.TagNumber(2)
  set private($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPrivate() => $_has(1);
  @$pb.TagNumber(2)
  void clearPrivate() => clearField(2);
}

class ContactRequestPrivate extends $pb.GeneratedMessage {
  factory ContactRequestPrivate() => create();
  ContactRequestPrivate._() : super();
  factory ContactRequestPrivate.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ContactRequestPrivate.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ContactRequestPrivate', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilidchat'), createEmptyInstance: create)
    ..aOM<$1.CryptoKey>(1, _omitFieldNames ? '' : 'writerKey', subBuilder: $1.CryptoKey.create)
    ..aOM<Profile>(2, _omitFieldNames ? '' : 'profile', subBuilder: Profile.create)
    ..aOM<$1.TypedKey>(3, _omitFieldNames ? '' : 'identityMasterRecordKey', subBuilder: $1.TypedKey.create)
    ..aOM<$1.TypedKey>(4, _omitFieldNames ? '' : 'chatRecordKey', subBuilder: $1.TypedKey.create)
    ..a<$fixnum.Int64>(5, _omitFieldNames ? '' : 'expiration', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ContactRequestPrivate clone() => ContactRequestPrivate()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ContactRequestPrivate copyWith(void Function(ContactRequestPrivate) updates) => super.copyWith((message) => updates(message as ContactRequestPrivate)) as ContactRequestPrivate;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ContactRequestPrivate create() => ContactRequestPrivate._();
  ContactRequestPrivate createEmptyInstance() => create();
  static $pb.PbList<ContactRequestPrivate> createRepeated() => $pb.PbList<ContactRequestPrivate>();
  @$core.pragma('dart2js:noInline')
  static ContactRequestPrivate getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ContactRequestPrivate>(create);
  static ContactRequestPrivate? _defaultInstance;

  @$pb.TagNumber(1)
  $1.CryptoKey get writerKey => $_getN(0);
  @$pb.TagNumber(1)
  set writerKey($1.CryptoKey v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasWriterKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearWriterKey() => clearField(1);
  @$pb.TagNumber(1)
  $1.CryptoKey ensureWriterKey() => $_ensure(0);

  @$pb.TagNumber(2)
  Profile get profile => $_getN(1);
  @$pb.TagNumber(2)
  set profile(Profile v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasProfile() => $_has(1);
  @$pb.TagNumber(2)
  void clearProfile() => clearField(2);
  @$pb.TagNumber(2)
  Profile ensureProfile() => $_ensure(1);

  @$pb.TagNumber(3)
  $1.TypedKey get identityMasterRecordKey => $_getN(2);
  @$pb.TagNumber(3)
  set identityMasterRecordKey($1.TypedKey v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasIdentityMasterRecordKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearIdentityMasterRecordKey() => clearField(3);
  @$pb.TagNumber(3)
  $1.TypedKey ensureIdentityMasterRecordKey() => $_ensure(2);

  @$pb.TagNumber(4)
  $1.TypedKey get chatRecordKey => $_getN(3);
  @$pb.TagNumber(4)
  set chatRecordKey($1.TypedKey v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasChatRecordKey() => $_has(3);
  @$pb.TagNumber(4)
  void clearChatRecordKey() => clearField(4);
  @$pb.TagNumber(4)
  $1.TypedKey ensureChatRecordKey() => $_ensure(3);

  @$pb.TagNumber(5)
  $fixnum.Int64 get expiration => $_getI64(4);
  @$pb.TagNumber(5)
  set expiration($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasExpiration() => $_has(4);
  @$pb.TagNumber(5)
  void clearExpiration() => clearField(5);
}

class ContactResponse extends $pb.GeneratedMessage {
  factory ContactResponse() => create();
  ContactResponse._() : super();
  factory ContactResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ContactResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ContactResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilidchat'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'accept')
    ..aOM<$1.TypedKey>(2, _omitFieldNames ? '' : 'identityMasterRecordKey', subBuilder: $1.TypedKey.create)
    ..aOM<$1.TypedKey>(3, _omitFieldNames ? '' : 'remoteConversationRecordKey', subBuilder: $1.TypedKey.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ContactResponse clone() => ContactResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ContactResponse copyWith(void Function(ContactResponse) updates) => super.copyWith((message) => updates(message as ContactResponse)) as ContactResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ContactResponse create() => ContactResponse._();
  ContactResponse createEmptyInstance() => create();
  static $pb.PbList<ContactResponse> createRepeated() => $pb.PbList<ContactResponse>();
  @$core.pragma('dart2js:noInline')
  static ContactResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ContactResponse>(create);
  static ContactResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get accept => $_getBF(0);
  @$pb.TagNumber(1)
  set accept($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAccept() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccept() => clearField(1);

  @$pb.TagNumber(2)
  $1.TypedKey get identityMasterRecordKey => $_getN(1);
  @$pb.TagNumber(2)
  set identityMasterRecordKey($1.TypedKey v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasIdentityMasterRecordKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearIdentityMasterRecordKey() => clearField(2);
  @$pb.TagNumber(2)
  $1.TypedKey ensureIdentityMasterRecordKey() => $_ensure(1);

  @$pb.TagNumber(3)
  $1.TypedKey get remoteConversationRecordKey => $_getN(2);
  @$pb.TagNumber(3)
  set remoteConversationRecordKey($1.TypedKey v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasRemoteConversationRecordKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearRemoteConversationRecordKey() => clearField(3);
  @$pb.TagNumber(3)
  $1.TypedKey ensureRemoteConversationRecordKey() => $_ensure(2);
}

class SignedContactResponse extends $pb.GeneratedMessage {
  factory SignedContactResponse() => create();
  SignedContactResponse._() : super();
  factory SignedContactResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SignedContactResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SignedContactResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilidchat'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'contactResponse', $pb.PbFieldType.OY)
    ..aOM<$1.Signature>(2, _omitFieldNames ? '' : 'identitySignature', subBuilder: $1.Signature.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SignedContactResponse clone() => SignedContactResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SignedContactResponse copyWith(void Function(SignedContactResponse) updates) => super.copyWith((message) => updates(message as SignedContactResponse)) as SignedContactResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SignedContactResponse create() => SignedContactResponse._();
  SignedContactResponse createEmptyInstance() => create();
  static $pb.PbList<SignedContactResponse> createRepeated() => $pb.PbList<SignedContactResponse>();
  @$core.pragma('dart2js:noInline')
  static SignedContactResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SignedContactResponse>(create);
  static SignedContactResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get contactResponse => $_getN(0);
  @$pb.TagNumber(1)
  set contactResponse($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasContactResponse() => $_has(0);
  @$pb.TagNumber(1)
  void clearContactResponse() => clearField(1);

  @$pb.TagNumber(2)
  $1.Signature get identitySignature => $_getN(1);
  @$pb.TagNumber(2)
  set identitySignature($1.Signature v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasIdentitySignature() => $_has(1);
  @$pb.TagNumber(2)
  void clearIdentitySignature() => clearField(2);
  @$pb.TagNumber(2)
  $1.Signature ensureIdentitySignature() => $_ensure(1);
}

class ContactInvitationRecord extends $pb.GeneratedMessage {
  factory ContactInvitationRecord() => create();
  ContactInvitationRecord._() : super();
  factory ContactInvitationRecord.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ContactInvitationRecord.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ContactInvitationRecord', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilidchat'), createEmptyInstance: create)
    ..aOM<$0.OwnedDHTRecordPointer>(1, _omitFieldNames ? '' : 'contactRequestInbox', subBuilder: $0.OwnedDHTRecordPointer.create)
    ..aOM<$1.CryptoKey>(2, _omitFieldNames ? '' : 'writerKey', subBuilder: $1.CryptoKey.create)
    ..aOM<$1.CryptoKey>(3, _omitFieldNames ? '' : 'writerSecret', subBuilder: $1.CryptoKey.create)
    ..aOM<$1.TypedKey>(4, _omitFieldNames ? '' : 'localConversationRecordKey', subBuilder: $1.TypedKey.create)
    ..a<$fixnum.Int64>(5, _omitFieldNames ? '' : 'expiration', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.List<$core.int>>(6, _omitFieldNames ? '' : 'invitation', $pb.PbFieldType.OY)
    ..aOS(7, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ContactInvitationRecord clone() => ContactInvitationRecord()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ContactInvitationRecord copyWith(void Function(ContactInvitationRecord) updates) => super.copyWith((message) => updates(message as ContactInvitationRecord)) as ContactInvitationRecord;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ContactInvitationRecord create() => ContactInvitationRecord._();
  ContactInvitationRecord createEmptyInstance() => create();
  static $pb.PbList<ContactInvitationRecord> createRepeated() => $pb.PbList<ContactInvitationRecord>();
  @$core.pragma('dart2js:noInline')
  static ContactInvitationRecord getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ContactInvitationRecord>(create);
  static ContactInvitationRecord? _defaultInstance;

  @$pb.TagNumber(1)
  $0.OwnedDHTRecordPointer get contactRequestInbox => $_getN(0);
  @$pb.TagNumber(1)
  set contactRequestInbox($0.OwnedDHTRecordPointer v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasContactRequestInbox() => $_has(0);
  @$pb.TagNumber(1)
  void clearContactRequestInbox() => clearField(1);
  @$pb.TagNumber(1)
  $0.OwnedDHTRecordPointer ensureContactRequestInbox() => $_ensure(0);

  @$pb.TagNumber(2)
  $1.CryptoKey get writerKey => $_getN(1);
  @$pb.TagNumber(2)
  set writerKey($1.CryptoKey v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasWriterKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearWriterKey() => clearField(2);
  @$pb.TagNumber(2)
  $1.CryptoKey ensureWriterKey() => $_ensure(1);

  @$pb.TagNumber(3)
  $1.CryptoKey get writerSecret => $_getN(2);
  @$pb.TagNumber(3)
  set writerSecret($1.CryptoKey v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasWriterSecret() => $_has(2);
  @$pb.TagNumber(3)
  void clearWriterSecret() => clearField(3);
  @$pb.TagNumber(3)
  $1.CryptoKey ensureWriterSecret() => $_ensure(2);

  @$pb.TagNumber(4)
  $1.TypedKey get localConversationRecordKey => $_getN(3);
  @$pb.TagNumber(4)
  set localConversationRecordKey($1.TypedKey v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasLocalConversationRecordKey() => $_has(3);
  @$pb.TagNumber(4)
  void clearLocalConversationRecordKey() => clearField(4);
  @$pb.TagNumber(4)
  $1.TypedKey ensureLocalConversationRecordKey() => $_ensure(3);

  @$pb.TagNumber(5)
  $fixnum.Int64 get expiration => $_getI64(4);
  @$pb.TagNumber(5)
  set expiration($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasExpiration() => $_has(4);
  @$pb.TagNumber(5)
  void clearExpiration() => clearField(5);

  @$pb.TagNumber(6)
  $core.List<$core.int> get invitation => $_getN(5);
  @$pb.TagNumber(6)
  set invitation($core.List<$core.int> v) { $_setBytes(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasInvitation() => $_has(5);
  @$pb.TagNumber(6)
  void clearInvitation() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get message => $_getSZ(6);
  @$pb.TagNumber(7)
  set message($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasMessage() => $_has(6);
  @$pb.TagNumber(7)
  void clearMessage() => clearField(7);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
