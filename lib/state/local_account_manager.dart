import 'dart:convert';
import 'dart:typed_data';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:veilid/veilid.dart';
import 'package:veilidchat/tools/tools.dart';

import '../entities/entities.dart';
import '../entities/proto.dart' as proto;

part 'local_account_manager.g.dart';

// Local account manager
class LocalAccountManager {
  final VeilidTableDB _localAccountsTable;
  final IList<LocalAccount> _localAccounts;

  const LocalAccountManager(
      {required VeilidTableDB localAccountsTable,
      required IList<LocalAccount> localAccounts})
      : _localAccountsTable = localAccountsTable,
        _localAccounts = localAccounts;

  /// Gets or creates a local account manager
  static Future<LocalAccountManager> open() async {
    final localAccountsTable =
        await Veilid.instance.openTableDB("local_account_manager", 1);
    final localAccounts =
        (await localAccountsTable.loadStringJson(0, "local_accounts") ??
            const IListConst([])) as IList<LocalAccount>;
    return LocalAccountManager(
        localAccountsTable: localAccountsTable, localAccounts: localAccounts);
  }

  /// Flush things to storage
  Future<void> flush() async {}

  /// Creates a new master identity and returns it with its secrets
  Future<IdentityMasterWithSecrets> newIdentityMaster() async {
    final dhtctx = (await Veilid.instance.routingContext())
        .withPrivacy()
        .withSequencing(Sequencing.ensureOrdered);
    DHTRecordDescriptor? masterRec;
    DHTRecordDescriptor? identityRec;
    try {
      masterRec = await dhtctx.createDHTRecord(const DHTSchema.dflt(oCnt: 1));
      identityRec = await dhtctx.createDHTRecord(const DHTSchema.dflt(oCnt: 1));
      final crypto = await Veilid.instance.bestCryptoSystem();
      assert(masterRec.key.kind == crypto.kind());
      assert(identityRec.key.kind == crypto.kind());

      // IdentityMaster
      final masterRecordKey = masterRec.key;
      final masterPublicKey = masterRec.owner;
      final masterSecret = masterRec.ownerSecret!;
      final masterSigBuf = masterRecordKey.decode()
        ..addAll(masterPublicKey.decode());

      final identityRecordKey = identityRec.key;
      final identityPublicKey = identityRec.owner;
      final identitySecret = identityRec.ownerSecret!;
      final identitySigBuf = identityRecordKey.decode()
        ..addAll(identityPublicKey.decode());

      final identitySignature =
          await crypto.sign(masterPublicKey, masterSecret, identitySigBuf);
      final masterSignature =
          await crypto.sign(identityPublicKey, identitySecret, masterSigBuf);

      final identityMaster = IdentityMaster(
          identityRecordKey: identityRecordKey,
          identityPublicKey: identityPublicKey,
          masterRecordKey: masterRecordKey,
          masterPublicKey: masterPublicKey,
          identitySignature: identitySignature,
          masterSignature: masterSignature);

      // Write identity master to master dht key
      final identityMasterBytes =
          Uint8List.fromList(utf8.encode(jsonEncode(identityMaster)));
      await dhtctx.setDHTValue(masterRecordKey, 0, identityMasterBytes);

      // Write empty identity to identity dht key
      const identity = Identity(accountKeyPairs: {});
      final identityBytes =
          Uint8List.fromList(utf8.encode(jsonEncode(identity)));
      await dhtctx.setDHTValue(identityRecordKey, 0, identityBytes);

      return IdentityMasterWithSecrets(
          identityMaster: identityMaster,
          masterSecret: masterSecret,
          identitySecret: identitySecret);
    } catch (e) {
      if (masterRec != null) {
        await dhtctx.deleteDHTRecord(masterRec.key);
      }
      if (identityRec != null) {
        await dhtctx.deleteDHTRecord(identityRec.key);
      }
      rethrow;
    }
  }

  Future<void> updateIdentityKey(
      VeilidRoutingContext dhtctx,
      TypedKey identityRecordKey,
      TypedKey accountRecordKey,
      KeyPair accountRecordOwner) async {
    // Get existing identity key
    ValueData? identityValueData =
        await dhtctx.getDHTValue(identityRecordKey, 0, true);
    if (identityValueData == null) {
      throw const FormatException("Identity does not exist");
    }
    var identity = identityValueData.readJsonData(Identity.fromJson);
xxx make back to bytes function and  do update loop and maybe make that a tool function too (consistentUpdate)
    // Update identity key to include account
    const identity = Identity(accountKeyPairs: {});
    final identityBytes = Uint8List.fromList(utf8.encode(jsonEncode(identity)));
    await dhtctx.setDHTValue(identityRec.key, 0, identityBytes);
  }

  /// Creates a new account associated with master identity
  Future<LocalAccount> newAccount(
      IdentityMaster identityMaster,
      SecretKey identitySecret,
      EncryptionKeyType encryptionKeyType,
      String encryptionKey,
      proto.Account account) async {
    // Encrypt identitySecret with key
    final cs = await Veilid.instance.bestCryptoSystem();
    final ekbytes = Uint8List.fromList(utf8.encode(encryptionKey));
    final nonce = await cs.randomNonce();
    final eksalt = nonce.decode();
    SharedSecret sharedSecret = await cs.deriveSharedSecret(ekbytes, eksalt);
    final identitySecretBytes =
        await cs.cryptNoAuth(identitySecret.decode(), nonce, sharedSecret);

    // Create local account object
    final localAccount = LocalAccount(
      identityMaster: identityMaster,
      identitySecretKeyBytes: identitySecretBytes,
      identitySecretSaltBytes: eksalt,
      encryptionKeyType: encryptionKeyType,
      biometricsEnabled: false,
      hiddenAccount: false,
    );

    // Add account with profile to DHT
    final dhtctx = (await Veilid.instance.routingContext())
        .withPrivacy()
        .withSequencing(Sequencing.ensureOrdered);
    DHTRecordDescriptor? identityRec;
    DHTRecordDescriptor? accountRec;
    try {
      identityRec = await dhtctx.openDHTRecord(identityMaster.identityRecordKey,
          identityMaster.identityWriter(identitySecret));
      accountRec = await dhtctx.createDHTRecord(const DHTSchema.dflt(oCnt: 1));
      final crypto = await Veilid.instance.bestCryptoSystem();
      assert(identityRec.key.kind == crypto.kind());
      assert(accountRec.key.kind == crypto.kind());

      // Write account key
      assert(await dhtctx.setDHTValue(
              accountRec.key, 0, account.writeToBuffer()) ==
          null);

      // Update identity key to include account
      await updateIdentityKey(dhtctx, identityRec.key, accountRec.key,
          KeyPair(key: accountRec.owner, secret: accountRec.ownerSecret!));
    } catch (e) {
      if (identityRec != null) {
        await dhtctx.closeDHTRecord(identityRec.key);
      }
      if (accountRec != null) {
        await dhtctx.deleteDHTRecord(accountRec.key);
      }
      rethrow;
    }

    // Add local account object to internal store

    // Return local account object
    return localAccount;
  }
}

@riverpod
Future<LocalAccountManager> localAccountManager(LocalAccountManagerRef ref) {
  return LocalAccountManager.open();
}
