import 'dart:convert';
import 'dart:typed_data';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:veilid/veilid.dart';

import '../tools/tools.dart';
import '../entities/entities.dart';
import '../entities/proto.dart' as proto;

import 'local_account_repository.dart';

// Local account manager
class LocalAccountRepositoryImpl extends LocalAccountRepository {
  IList<LocalAccount> _localAccounts;

  static const localAccountManagerTable = "local_account_manager";
  static const localAccountsKey = "local_accounts";

  LocalAccountRepositoryImpl._({required IList<LocalAccount> localAccounts})
      : _localAccounts = localAccounts;

  /// Gets or creates a local account manager
  static Future<LocalAccountRepository> open() async {
    // Load accounts from tabledb
    final localAccounts =
        await tableScope(localAccountManagerTable, (tdb) async {
      final localAccountsJson = await tdb.loadStringJson(0, localAccountsKey);
      return localAccountsJson != null
          ? IList<LocalAccount>.fromJson(
              localAccountsJson, genericFromJson(LocalAccount.fromJson))
          : IList<LocalAccount>();
    });

    return LocalAccountRepositoryImpl._(localAccounts: localAccounts);
  }

  /// Store things back to storage
  Future<void> flush() async {
    await tableScope(localAccountManagerTable, (tdb) async {
      await tdb.storeStringJson(0, localAccountsKey, _localAccounts);
    });
  }

  /// Creates a new master identity and returns it with its secrets
  @override
  Future<IdentityMasterWithSecrets> newIdentityMaster() async {
    final crypto = await Veilid.instance.bestCryptoSystem();
    final dhtctx = (await Veilid.instance.routingContext())
        .withPrivacy()
        .withSequencing(Sequencing.ensureOrdered);

    return (await DHTRecord.create(dhtctx)).deleteScope((masterRec) async {
      return (await DHTRecord.create(dhtctx)).deleteScope((identityRec) async {
        // Make IdentityMaster
        final masterRecordKey = masterRec.key();
        final masterOwner = masterRec.ownerKeyPair()!;
        final masterSigBuf = masterRecordKey.decode()
          ..addAll(masterOwner.key.decode());

        final identityRecordKey = identityRec.key();
        final identityOwner = identityRec.ownerKeyPair()!;
        final identitySigBuf = identityRecordKey.decode()
          ..addAll(identityOwner.key.decode());

        final identitySignature =
            await crypto.signWithKeyPair(masterOwner, identitySigBuf);
        final masterSignature =
            await crypto.signWithKeyPair(identityOwner, masterSigBuf);

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

        return IdentityMasterWithSecrets(
            identityMaster: identityMaster,
            masterSecret: masterOwner.secret,
            identitySecret: identityOwner.secret);
      });
    });
  }

  /// Creates a new account associated with master identity
  @override
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

    /////// Add account with profile to DHT

    // Create private routing context
    final dhtctx = (await Veilid.instance.routingContext())
        .withPrivacy()
        .withSequencing(Sequencing.ensureOrdered);

    // Open identity key for writing
    (await DHTRecord.open(dhtctx, identityMaster.identityRecordKey,
            identityMaster.identityWriter(identitySecret)))
        .scope((identityRec) async {
      // Create new account to insert into identity
      (await DHTRecord.create(dhtctx)).deleteScope((accountRec) async {
        // Write account key
        await accountRec.eventualWriteProtobuf(account);

        // Update identity key to include account
        final newAccountRecordOwner = accountRec.ownerKeyPair()!;
        final newAccountRecordInfo = AccountRecordInfo(
            key: accountRec.key(), owner: newAccountRecordOwner);

        await identityRec.eventualUpdateJson(Identity.fromJson,
            (oldIdentity) async {
          final accountRecords = IMapOfSets.from(oldIdentity.accountRecords)
              .add("VeilidChat", newAccountRecordInfo)
              .asIMap();
          return oldIdentity.copyWith(accountRecords: accountRecords);
        });
      });
    });

    // Add local account object to internal store

    // Return local account object
    return localAccount;
  }
}
