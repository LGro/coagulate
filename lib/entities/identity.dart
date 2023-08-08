import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../veilid_support/veilid_support.dart';
import 'proto.dart' as proto;

part 'identity.freezed.dart';
part 'identity.g.dart';

const String veilidChatAccountKey = 'com.veilid.veilidchat';

// AccountOwnerInfo is the key and owner info for the account dht key that is
// stored in the identity key
@freezed
class AccountRecordInfo with _$AccountRecordInfo {
  const factory AccountRecordInfo({
    // Top level account keys and secrets
    required OwnedDHTRecordPointer accountRecord,
  }) = _AccountRecordInfo;

  factory AccountRecordInfo.fromJson(dynamic json) =>
      _$AccountRecordInfoFromJson(json as Map<String, dynamic>);
}

// Identity Key points to accounts associated with this identity
// accounts field has a map of bundle id or uuid to account key pairs
// DHT Schema: DFLT(1)
// DHT Key (Private): identityRecordKey
// DHT Owner Key: identityPublicKey
// DHT Secret: identitySecretKey (stored encrypted
//    with unlock code in local table store)
@freezed
class Identity with _$Identity {
  const factory Identity({
    // Top level account keys and secrets
    required IMap<String, ISet<AccountRecordInfo>> accountRecords,
  }) = _Identity;

  factory Identity.fromJson(dynamic json) =>
      _$IdentityFromJson(json as Map<String, dynamic>);
}

// Identity Master key structure for created account
// Master key allows for regeneration of identity DHT record
// Bidirectional Master<->Identity signature allows for
// chain of identity ownership for account recovery process
//
// Backed by a DHT key at masterRecordKey, the secret is kept
// completely offline and only written to upon account recovery
//
// DHT Schema: DFLT(1)
// DHT Record Key (Public): masterRecordKey
// DHT Owner Key: masterPublicKey
// DHT Owner Secret: masterSecretKey (kept offline)
// Encryption: None
@freezed
class IdentityMaster with _$IdentityMaster {
  const factory IdentityMaster(
      {
      // Private DHT record storing identity account mapping
      required TypedKey identityRecordKey,
      // Public key of identity
      required PublicKey identityPublicKey,
      // Public DHT record storing this structure for account recovery
      required TypedKey masterRecordKey,
      // Public key of master identity used to sign identity keys for recovery
      required PublicKey masterPublicKey,
      // Signature of identityRecordKey and identityPublicKey by masterPublicKey
      required Signature identitySignature,
      // Signature of masterRecordKey and masterPublicKey by identityPublicKey
      required Signature masterSignature}) = _IdentityMaster;

  factory IdentityMaster.fromJson(dynamic json) =>
      _$IdentityMasterFromJson(json as Map<String, dynamic>);
}

extension IdentityMasterExtension on IdentityMaster {
  KeyPair identityWriter(SecretKey secret) =>
      KeyPair(key: identityPublicKey, secret: secret);

  KeyPair masterWriter(SecretKey secret) =>
      KeyPair(key: masterPublicKey, secret: secret);

  TypedKey identityPublicTypedKey() =>
      TypedKey(kind: identityRecordKey.kind, value: identityPublicKey);

  Future<AccountRecordInfo> readAccountFromIdentity(
      {required SharedSecret identitySecret}) async {
    // Read the identity key to get the account keys
    final pool = await DHTRecordPool.instance();

    final identityRecordCrypto = await DHTRecordCryptoPrivate.fromSecret(
        identityRecordKey.kind, identitySecret);

    late final AccountRecordInfo accountRecordInfo;
    await (await pool.openRead(identityRecordKey,
            parent: masterRecordKey, crypto: identityRecordCrypto))
        .scope((identityRec) async {
      final identity = await identityRec.getJson(Identity.fromJson);
      if (identity == null) {
        // Identity could not be read or decrypted from DHT
        throw StateError('identity could not be read');
      }
      final accountRecords = IMapOfSets.from(identity.accountRecords);
      final vcAccounts = accountRecords.get(veilidChatAccountKey);
      if (vcAccounts.length != 1) {
        // No veilidchat account, or multiple accounts
        // somehow associated with identity
        throw StateError('no single veilidchat account');
      }

      accountRecordInfo = vcAccounts.first;
    });

    return accountRecordInfo;
  }

  /// Creates a new Account associated with master identity and store it in the
  /// identity key.
  Future<void> newAccount({
    required SharedSecret identitySecret,
    required String name,
    required String title,
  }) async {
    final pool = await DHTRecordPool.instance();

    /////// Add account with profile to DHT

    // Open identity key for writing
    await (await pool.openWrite(
            identityRecordKey, identityWriter(identitySecret),
            parent: masterRecordKey))
        .scope((identityRec) async {
      // Create new account to insert into identity
      await (await pool.create(parent: identityRec.key))
          .deleteScope((accountRec) async {
        // Make empty contact list
        final contactList =
            await (await DHTShortArray.create(parent: accountRec.key))
                .scope((r) async => r.record.ownedDHTRecordPointer);

        // Make empty contact invitation record list
        final contactInvitationRecords =
            await (await DHTShortArray.create(parent: accountRec.key))
                .scope((r) async => r.record.ownedDHTRecordPointer);

        // Make empty chat record list
        final chatRecords =
            await (await DHTShortArray.create(parent: accountRec.key))
                .scope((r) async => r.record.ownedDHTRecordPointer);

        // Make account object
        final account = proto.Account()
          ..profile = (proto.Profile()
            ..name = name
            ..title = title)
          ..contactList = contactList.toProto()
          ..contactInvitationRecords = contactInvitationRecords.toProto()
          ..chatList = chatRecords.toProto();

        // Write account key
        await accountRec.eventualWriteProtobuf(account);

        // Update identity key to include account
        final newAccountRecordInfo = AccountRecordInfo(
            accountRecord: OwnedDHTRecordPointer(
                recordKey: accountRec.key, owner: accountRec.ownerKeyPair!));
        await identityRec.eventualUpdateJson(Identity.fromJson,
            (oldIdentity) async {
          final oldAccountRecords = IMapOfSets.from(oldIdentity.accountRecords);
          // Only allow one account per identity for veilidchat
          if (oldAccountRecords.get(veilidChatAccountKey).isNotEmpty) {
            throw StateError(
                'Only one account per identity allowed for VeilidChat');
          }
          final accountRecords = oldAccountRecords
              .add(veilidChatAccountKey, newAccountRecordInfo)
              .asIMap();
          return oldIdentity.copyWith(accountRecords: accountRecords);
        });
      });
    });
  }
}
