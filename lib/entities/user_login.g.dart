// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_login.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_UserLogin _$$_UserLoginFromJson(Map<String, dynamic> json) => _$_UserLogin(
      accountMasterRecordKey: Typed<FixedEncodedString43>.fromJson(
          json['account_master_record_key']),
      identitySecret:
          Typed<FixedEncodedString43>.fromJson(json['identity_secret']),
      lastActive: Timestamp.fromJson(json['last_active']),
    );

Map<String, dynamic> _$$_UserLoginToJson(_$_UserLogin instance) =>
    <String, dynamic>{
      'account_master_record_key': instance.accountMasterRecordKey.toJson(),
      'identity_secret': instance.identitySecret.toJson(),
      'last_active': instance.lastActive.toJson(),
    };

_$_ActiveLogins _$$_ActiveLoginsFromJson(Map<String, dynamic> json) =>
    _$_ActiveLogins(
      userLogins: IList<UserLogin>.fromJson(
          json['user_logins'], UserLogin.fromJson),
      activeUserLogin: json['active_user_login'] == null
          ? null
          : Typed<FixedEncodedString43>.fromJson(json['active_user_login']),
    );

Map<String, dynamic> _$$_ActiveLoginsToJson(_$_ActiveLogins instance) =>
    <String, dynamic>{
      'user_logins': instance.userLogins.toJson(
        (value) => value.toJson(),
      ),
      'active_user_login': instance.activeUserLogin?.toJson(),
    };
