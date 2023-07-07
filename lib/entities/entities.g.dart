// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entities.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Account _$$_AccountFromJson(Map<String, dynamic> json) => _$_Account(
      profile: Profile.fromJson(json['profile'] as Map<String, dynamic>),
      identity: Identity.fromJson(json['identity'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$_AccountToJson(_$_Account instance) =>
    <String, dynamic>{
      'profile': instance.profile.toJson(),
      'identity': instance.identity.toJson(),
    };

_$_Contact _$$_ContactFromJson(Map<String, dynamic> json) => _$_Contact(
      name: json['name'] as String,
      publicKey: Typed<FixedEncodedString43>.fromJson(json['public_key']),
      available: json['available'] as bool,
    );

Map<String, dynamic> _$$_ContactToJson(_$_Contact instance) =>
    <String, dynamic>{
      'name': instance.name,
      'public_key': instance.publicKey.toJson(),
      'available': instance.available,
    };

_$_Identity _$$_IdentityFromJson(Map<String, dynamic> json) => _$_Identity(
      identityPublicKey:
          Typed<FixedEncodedString43>.fromJson(json['identity_public_key']),
      masterPublicKey:
          Typed<FixedEncodedString43>.fromJson(json['master_public_key']),
      identitySignature:
          FixedEncodedString86.fromJson(json['identity_signature']),
      masterSignature: FixedEncodedString86.fromJson(json['master_signature']),
    );

Map<String, dynamic> _$$_IdentityToJson(_$_Identity instance) =>
    <String, dynamic>{
      'identity_public_key': instance.identityPublicKey.toJson(),
      'master_public_key': instance.masterPublicKey.toJson(),
      'identity_signature': instance.identitySignature.toJson(),
      'master_signature': instance.masterSignature.toJson(),
    };

_$_Profile _$$_ProfileFromJson(Map<String, dynamic> json) => _$_Profile(
      name: json['name'] as String,
      publicKey: Typed<FixedEncodedString43>.fromJson(json['public_key']),
      invisible: json['invisible'] as bool,
    );

Map<String, dynamic> _$$_ProfileToJson(_$_Profile instance) =>
    <String, dynamic>{
      'name': instance.name,
      'public_key': instance.publicKey.toJson(),
      'invisible': instance.invisible,
    };
