import 'dart:typed_data';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:protobuf/protobuf.dart';

import '../veilid_support.dart';
import 'veilid_log.dart';

part 'identity.freezed.dart';
part 'identity.g.dart';

// Identity errors
enum IdentityException implements Exception {
  readError('identity could not be read'),
  noAccount('no account record info'),
  limitExceeded('too many items for the limit'),
  invalid('identity is corrupted or secret is invalid');

  const IdentityException(this.message);
  final String message;

  @override
  String toString() => 'IdentityException($name): $message';
}

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
  /// Deletes a master identity and the identity record under it
  Future<void> delete() async {
    final pool = DHTRecordPool.instance;
    await (await pool.openRead(masterRecordKey)).delete();
  }

  Future<VeilidCryptoSystem> get identityCrypto =>
      Veilid.instance.getCryptoSystem(identityRecordKey.kind);

  Future<VeilidCryptoSystem> get masterCrypto =>
      Veilid.instance.getCryptoSystem(masterRecordKey.kind);

  KeyPair identityWriter(SecretKey secret) =>
      KeyPair(key: identityPublicKey, secret: secret);

  KeyPair masterWriter(SecretKey secret) =>
      KeyPair(key: masterPublicKey, secret: secret);

  TypedKey identityPublicTypedKey() =>
      TypedKey(kind: identityRecordKey.kind, value: identityPublicKey);

  Future<VeilidCryptoSystem> validateIdentitySecret(
      SecretKey identitySecret) async {
    final cs = await identityCrypto;
    final keyOk = await cs.validateKeyPair(identityPublicKey, identitySecret);
    if (!keyOk) {
      throw IdentityException.invalid;
    }
    return cs;
  }

  Future<List<AccountRecordInfo>> readAccountsFromIdentity(
      {required SharedSecret identitySecret,
      required String accountKey}) async {
    // Read the identity key to get the account keys
    final pool = DHTRecordPool.instance;

    final identityRecordCrypto = await DHTRecordCryptoPrivate.fromSecret(
        identityRecordKey.kind, identitySecret);

    late final List<AccountRecordInfo> accountRecordInfo;
    await (await pool.openRead(identityRecordKey,
            parent: masterRecordKey, crypto: identityRecordCrypto))
        .scope((identityRec) async {
      final identity = await identityRec.getJson(Identity.fromJson);
      if (identity == null) {
        // Identity could not be read or decrypted from DHT
        throw IdentityException.readError;
      }
      final accountRecords = IMapOfSets.from(identity.accountRecords);
      final vcAccounts = accountRecords.get(accountKey);

      accountRecordInfo = vcAccounts.toList();
    });

    return accountRecordInfo;
  }

  /// Creates a new Account associated with master identity and store it in the
  /// identity key.
  Future<AccountRecordInfo> addAccountToIdentity<T extends GeneratedMessage>({
    required SharedSecret identitySecret,
    required String accountKey,
    required Future<T> Function(TypedKey parent) createAccountCallback,
    int maxAccounts = 1,
  }) async {
    final pool = DHTRecordPool.instance;

    /////// Add account with profile to DHT

    // Open identity key for writing
    veilidLoggy.debug('Opening master identity');
    return (await pool.openWrite(
            identityRecordKey, identityWriter(identitySecret),
            parent: masterRecordKey))
        .scope((identityRec) async {
      // Create new account to insert into identity
      veilidLoggy.debug('Creating new account');
      return (await pool.create(parent: identityRec.key))
          .deleteScope((accountRec) async {
        final account = await createAccountCallback(accountRec.key);
        // Write account key
        veilidLoggy.debug('Writing account record');
        await accountRec.eventualWriteProtobuf(account);

        // Update identity key to include account
        final newAccountRecordInfo = AccountRecordInfo(
            accountRecord: OwnedDHTRecordPointer(
                recordKey: accountRec.key, owner: accountRec.ownerKeyPair!));

        veilidLoggy.debug('Updating identity with new account');
        await identityRec.eventualUpdateJson(Identity.fromJson,
            (oldIdentity) async {
          if (oldIdentity == null) {
            throw IdentityException.readError;
          }
          final oldAccountRecords = IMapOfSets.from(oldIdentity.accountRecords);

          if (oldAccountRecords.get(accountKey).length >= maxAccounts) {
            throw IdentityException.limitExceeded;
          }
          final accountRecords =
              oldAccountRecords.add(accountKey, newAccountRecordInfo).asIMap();
          return oldIdentity.copyWith(accountRecords: accountRecords);
        });

        return newAccountRecordInfo;
      });
    });
  }
}

// Identity Master with secrets
// Not freezed because we never persist this class in its entirety
class IdentityMasterWithSecrets {
  IdentityMasterWithSecrets._(
      {required this.identityMaster,
      required this.masterSecret,
      required this.identitySecret});
  IdentityMaster identityMaster;
  SecretKey masterSecret;
  SecretKey identitySecret;

  /// Delete a master identity with secrets
  Future<void> delete() async => identityMaster.delete();

  /// Creates a new master identity and returns it with its secrets
  static Future<IdentityMasterWithSecrets> create() async {
    final pool = DHTRecordPool.instance;

    // IdentityMaster DHT record is public/unencrypted
    veilidLoggy.debug('Creating master identity record');
    return (await pool.create(crypto: const DHTRecordCryptoPublic()))
        .deleteScope((masterRec) async {
      veilidLoggy.debug('Creating identity record');
      // Identity record is private
      return (await pool.create(parent: masterRec.key))
          .scope((identityRec) async {
        // Make IdentityMaster
        final masterRecordKey = masterRec.key;
        final masterOwner = masterRec.ownerKeyPair!;
        final masterSigBuf = BytesBuilder()
          ..add(masterRecordKey.decode())
          ..add(masterOwner.key.decode());

        final identityRecordKey = identityRec.key;
        final identityOwner = identityRec.ownerKeyPair!;
        final identitySigBuf = BytesBuilder()
          ..add(identityRecordKey.decode())
          ..add(identityOwner.key.decode());

        assert(masterRecordKey.kind == identityRecordKey.kind,
            'new master and identity should have same cryptosystem');
        final crypto = await pool.veilid.getCryptoSystem(masterRecordKey.kind);

        final identitySignature =
            await crypto.signWithKeyPair(masterOwner, identitySigBuf.toBytes());
        final masterSignature =
            await crypto.signWithKeyPair(identityOwner, masterSigBuf.toBytes());

        final identityMaster = IdentityMaster(
            identityRecordKey: identityRecordKey,
            identityPublicKey: identityOwner.key,
            masterRecordKey: masterRecordKey,
            masterPublicKey: masterOwner.key,
            identitySignature: identitySignature,
            masterSignature: masterSignature);

        // Write identity master to master dht key
        await masterRec.eventualWriteJson(identityMaster);

        // Make empty identity
        const identity = Identity(accountRecords: IMapConst({}));

        // Write empty identity to identity dht key
        await identityRec.eventualWriteJson(identity);

        return IdentityMasterWithSecrets._(
            identityMaster: identityMaster,
            masterSecret: masterOwner.secret,
            identitySecret: identityOwner.secret);
      });
    });
  }
}

/// Opens an existing master identity and validates it
Future<IdentityMaster> openIdentityMaster(
    {required TypedKey identityMasterRecordKey}) async {
  final pool = DHTRecordPool.instance;

  // IdentityMaster DHT record is public/unencrypted
  return (await pool.openRead(identityMasterRecordKey))
      .deleteScope((masterRec) async {
    final identityMaster =
        (await masterRec.getJson(IdentityMaster.fromJson, forceRefresh: true))!;

    // Validate IdentityMaster
    final masterRecordKey = masterRec.key;
    final masterOwnerKey = masterRec.owner;
    final masterSigBuf = BytesBuilder()
      ..add(masterRecordKey.decode())
      ..add(masterOwnerKey.decode());
    final masterSignature = identityMaster.masterSignature;

    final identityRecordKey = identityMaster.identityRecordKey;
    final identityOwnerKey = identityMaster.identityPublicKey;
    final identitySigBuf = BytesBuilder()
      ..add(identityRecordKey.decode())
      ..add(identityOwnerKey.decode());
    final identitySignature = identityMaster.identitySignature;

    assert(masterRecordKey.kind == identityRecordKey.kind,
        'new master and identity should have same cryptosystem');
    final crypto = await pool.veilid.getCryptoSystem(masterRecordKey.kind);

    await crypto.verify(
        masterOwnerKey, identitySigBuf.toBytes(), identitySignature);
    await crypto.verify(
        identityOwnerKey, masterSigBuf.toBytes(), masterSignature);

    return identityMaster;
  });
}
