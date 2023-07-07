import 'dart:typed_data';

import 'package:change_case/change_case.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:veilid/veilid.dart';

part 'entities.freezed.dart';
part 'entities.g.dart';

// A record of a chunk of messages as reconciled from a conversation
//
// DHT Key (Private): messagesKey
// DHT Secret: messagesSecret
// Encryption: Symmetric(messagesSecret)

@freezed
class Messages with _$Messages {
  const factory Messages(
      {required Profile profile,
      required Identity identity,
      required bool available}) = _Messages;

  factory Messages.fromJson(Map<String, dynamic> json) =>
      _$MessagesFromJson(json);
}

// A record of a 1-1 chat that is synchronized between
// two users. Backed up on a DHT key.
//
//
// DHT Key (UnicastOutbox): conversationPublicKey
// DHT Secret: conversationSecret
// Encryption: DH(IdentityA, IdentityB)

@freezed
class Conversation with _$Conversation {
  const factory Conversation(
      {required Profile profile,
      required Identity identity,
      required bool available}) = _Contact;

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);
}

// A record of a contact that has accepted a contact invitation
// Contains a copy of the most recent remote profile as well as
// a locally edited profile.
// Contains a copy of the most recent identity from the contact's
// Master identity dht key
// Contains
@freezed
class Contact with _$Contact {
  const factory Contact(
      {required Profile remoteProfile,
      required Profile localProfile,
      required Identity identity,
      required bool available}) = _Contact;

  factory Contact.fromJson(Map<String, dynamic> json) =>
      _$ContactFromJson(json);
}

// Publicly shared profile information for both contacts and accounts
// Contains:
// Name - Friendly name
// Title - Title of user
// Icon - Little picture to represent user in contact list
//
// DHT Key: None
// Encryption: None
@freezed
class Profile with _$Profile {
  const factory Profile({
    // Friendy name
    required String name,
    // Title of user
    required String title,
    // Status/away message
    required String status,
    // Icon data (png 128x128x24bit)
    required Uint8List icon,
  }) = _Profile;
  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}

// A record of an individual account
// DHT Key (Private): accountPublicKey
// DHT Secret: accountSecretKey
@freezed
class Account with _$Account {
  const factory Account({
    // The user's profile that gets shared with contacts
    required Profile profile,
    // Invisibility makes you always look 'Offline'
    required bool invisible,
    // Auto-away sets 'away' mode after an inactivity time
    required autoAwayTimeoutSec,
    // The contacts for this account
    required List<Contact>,

    xxx investigate immutable FIC lists and their use with freezed/jsonserializable, switch them here

  }) = _Account;

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);
}

// Identity Key points to accounts associated with this identity
// accounts field has a map of service name or uuid to account key pairs
// DHT Key (Private): identityPublicKey
// DHT Secret: identitySecretKey (stored encrypted with unlock code in local table store)
@freezed
class Identity with _$Identity {
  const factory Identity({
    // Top level account data key
    required TypedKey accountPublicKey,
    // Top level account data secret
    required SecretKey accountSecretKey,
  }) = _Identity;

  factory Identity.fromJson(Map<String, dynamic> json) =>
      _$IdentityFromJson(json);
}

// Identity Master key structure for created account
// Master key allows for regeneration of identity DHT record
// Bidirectional Master<->Identity signature allows for
// chain of identity ownership for account recovery process
//
// Backed by a DHT key at masterPublicKey, the secret is kept
// completely offline and only written to upon account recovery
//
// DHT Key (Public): masterPublicKey
// DHT Secret: masterSecretKey (kept offline)
// Encryption: None
@freezed
class IdentityMaster with _$IdentityMaster {
  const factory IdentityMaster(
      {required TypedKey identityPublicKey,
      required TypedKey masterPublicKey,
      required Signature identitySignature,
      required Signature masterSignature}) = _IdentityMaster;

  factory IdentityMaster.fromJson(Map<String, dynamic> json) =>
      _$IdentityMasterFromJson(json);
}

// Local account identitySecretKey is potentially encrypted with a key
// using the following mechanisms
// * None : no key, bytes are unencrypted
// * Pin : Code is a numeric pin (4-256 numeric digits) hashed with Argon2
// * Password: Code is a UTF-8 string that is hashed with Argon2
enum EncryptionKeyType {
  none,
  pin,
  password;

  String toJson() => name.toPascalCase();
  factory EncryptionKeyType.fromJson(String j) =>
      EncryptionKeyType.values.byName(j.toCamelCase());
}

// Local Accounts are stored in a table locally and not backed by a DHT key
// and represents the accounts that have been added/imported
// on the current device.
// Stores a copy of the IdentityMaster associated with the account
// and the identitySecretKey optionally encrypted by an unlock code
// This is the root of the account information tree for VeilidChat
//
@freezed
class LocalAccount with _$LocalAccount {
  const factory LocalAccount({
    // The master key record for the account, containing the identityPublicKey
    required IdentityMaster identityMaster,
    // The encrypted identity secret that goes with the identityPublicKey
    required Uint8List identitySecretKeyBytes,
    // The kind of encryption input used on the account
    required EncryptionKeyType encryptionKeyType,
    // If account is not hidden, password can be retrieved via
    required bool biometricsEnabled,
    // Keep account hidden unless account password is entered
    // (tries all hidden accounts with auth method (no biometrics))
    required bool hiddenAccount,
  }) = _LocalAccount;

  factory LocalAccount.fromJson(Map<String, dynamic> json) =>
      _$LocalAccountFromJson(json);
}

// Each theme supports light and dark mode, optionally selected by the
// operating system
enum DarkModePreference {
  system,
  light,
  dark;

  String toJson() => name.toPascalCase();
  factory DarkModePreference.fromJson(String j) =>
      DarkModePreference.values.byName(j.toCamelCase());
}

// Lock preference changes how frequently the messenger locks its
// interface and requires the identitySecretKey to be entered (pin/password/etc)
@freezed
class LockPreference with _$LockPreference {
  const factory LockPreference({
    required int inactivityLockSecs,
    required bool lockWhenSwitching,
    required bool lockWithSystemLock,
  }) = _LockPreference;

  factory LockPreference.fromJson(Map<String, dynamic> json) =>
      _$LockPreferenceFromJson(json);
}

// Preferences are stored in a table locally and globally affect all
// accounts imported/added and the app in general
@freezed
class Preferences with _$Preferences {
  const factory Preferences({
    required DarkModePreference darkMode,
    required Uuid activeTheme,
    required LockPreference locking,
  }) = _Preferences;

  factory Preferences.fromJson(Map<String, dynamic> json) =>
      _$PreferencesFromJson(json);
}

// Themes are stored in a table locally and referenced by their UUID
@freezed
class Theme with _$Theme {
  const factory Theme({
    required Uuid uuid,
    required String name,
    required Map<DarkModePreference, ThemeData> modeData,
  }) = _Theme;

  factory Theme.fromJson(Map<String, dynamic> json) => _$ThemeFromJson(json);
}
