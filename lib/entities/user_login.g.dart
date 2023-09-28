// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_login.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserLoginImpl _$$UserLoginImplFromJson(Map<String, dynamic> json) =>
    _$UserLoginImpl(
      accountMasterRecordKey: Typed<FixedEncodedString43>.fromJson(
          json['account_master_record_key']),
      identitySecret:
          Typed<FixedEncodedString43>.fromJson(json['identity_secret']),
      accountRecordInfo:
          AccountRecordInfo.fromJson(json['account_record_info']),
      lastActive: Timestamp.fromJson(json['last_active']),
    );

Map<String, dynamic> _$$UserLoginImplToJson(_$UserLoginImpl instance) =>
    <String, dynamic>{
      'account_master_record_key': instance.accountMasterRecordKey.toJson(),
      'identity_secret': instance.identitySecret.toJson(),
      'account_record_info': instance.accountRecordInfo.toJson(),
      'last_active': instance.lastActive.toJson(),
    };

_$ActiveLoginsImpl _$$ActiveLoginsImplFromJson(Map<String, dynamic> json) =>
    _$ActiveLoginsImpl(
      userLogins: IList<UserLogin>.fromJson(
          json['user_logins'], (value) => UserLogin.fromJson(value)),
      activeUserLogin: json['active_user_login'] == null
          ? null
          : Typed<FixedEncodedString43>.fromJson(json['active_user_login']),
    );

Map<String, dynamic> _$$ActiveLoginsImplToJson(_$ActiveLoginsImpl instance) =>
    <String, dynamic>{
      'user_logins': instance.userLogins.toJson(
        (value) => value.toJson(),
      ),
      'active_user_login': instance.activeUserLogin?.toJson(),
    };
