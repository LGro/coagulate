import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:veilid/veilid.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../tools/tools.dart';
import '../veilid_support/veilid_support.dart';
import '../entities/entities.dart';
import '../entities/proto.dart' as proto;
import 'logins.dart';

part 'local_accounts.g.dart';

// Local account manager
@riverpod
class LocalAccounts extends _$LocalAccounts
    with AsyncTableDBBacked<IList<LocalAccount>> {
  //////////////////////////////////////////////////////////////
  /// AsyncTableDBBacked
  @override
  String tableName() => "local_account_manager";
  @override
  String tableKeyName() => "local_accounts";
  @override
  IList<LocalAccount> valueFromJson(Object? obj) => obj != null
      ? IList<LocalAccount>.fromJson(
          obj, genericFromJson(LocalAccount.fromJson))
      : IList<LocalAccount>();
  @override
  Object? valueToJson(IList<LocalAccount> val) =>
      val.toJson((la) => la.toJson());

  /// Get all local account information
  @override
  FutureOr<IList<LocalAccount>> build() async {
    return await load();
  }

  //////////////////////////////////////////////////////////////
  /// Mutators and Selectors

  /// Reorder accounts
  Future<void> reorderAccount(int oldIndex, int newIndex) async {
    final localAccounts = state.requireValue;
    var removedItem = Output<LocalAccount>();
    final updated = localAccounts
        .removeAt(oldIndex, removedItem)
        .insert(newIndex, removedItem.value!);
    await store(updated);
    state = AsyncValue.data(updated);
  }

  /// Creates a new account associated with master identity
  Future<LocalAccount> newAccount(
      {required IdentityMaster identityMaster,
      required SecretKey identitySecret,
      EncryptionKeyType encryptionKeyType = EncryptionKeyType.none,
      String encryptionKey = "",
      required proto.Account account}) async {
    final veilid = await eventualVeilid.future;
    final localAccounts = state.requireValue;

    // Encrypt identitySecret with key
    late final Uint8List identitySecretBytes;
    late final Uint8List identitySecretSaltBytes;

    switch (encryptionKeyType) {
      case EncryptionKeyType.none:
        identitySecretBytes = identitySecret.decode();
        identitySecretSaltBytes = Uint8List(0);
      case EncryptionKeyType.pin:
      case EncryptionKeyType.password:
        final cs =
            await veilid.getCryptoSystem(identityMaster.identityRecordKey.kind);
        final ekbytes = Uint8List.fromList(utf8.encode(encryptionKey));
        final nonce = await cs.randomNonce();
        identitySecretSaltBytes = nonce.decode();
        SharedSecret sharedSecret =
            await cs.deriveSharedSecret(ekbytes, identitySecretSaltBytes);
        identitySecretBytes =
            await cs.cryptNoAuth(identitySecret.decode(), nonce, sharedSecret);
    }

    // Create local account object
    final localAccount = LocalAccount(
      identityMaster: identityMaster,
      identitySecretKeyBytes: identitySecretBytes,
      identitySecretSaltBytes: identitySecretSaltBytes,
      encryptionKeyType: encryptionKeyType,
      biometricsEnabled: false,
      hiddenAccount: false,
    );

    /////// Add account with profile to DHT

    // Create private routing context
    final dhtctx = (await veilid.routingContext())
        .withPrivacy()
        .withSequencing(Sequencing.ensureOrdered);

    // Open identity key for writing
    (await DHTRecord.openWrite(dhtctx, identityMaster.identityRecordKey,
            identityMaster.identityWriter(identitySecret)))
        .scope((identityRec) async {
      // Create new account to insert into identity
      (await DHTRecord.create(dhtctx)).deleteScope((accountRec) async {
        // Write account key
        await accountRec.eventualWriteProtobuf(account);

        // Update identity key to include account
        final newAccountRecordInfo = AccountRecordInfo(
            key: accountRec.key(), owner: accountRec.ownerKeyPair()!);

        await identityRec.eventualUpdateJson(Identity.fromJson,
            (oldIdentity) async {
          final accountRecords = IMapOfSets.from(oldIdentity.accountRecords)
              .add("com.veilid.veilidchat", newAccountRecordInfo)
              .asIMap();
          return oldIdentity.copyWith(accountRecords: accountRecords);
        });
      });
    });

    // Add local account object to internal store
    final newLocalAccounts = localAccounts.add(localAccount);
    await store(newLocalAccounts);
    state = AsyncValue.data(newLocalAccounts);

    // Return local account object
    return localAccount;
  }

  /// Remove an account and wipe the messages for this account from this device
  Future<bool> deleteAccount(TypedKey accountMasterRecordKey) async {
    final logins = ref.read(loginsProvider.notifier);
    await logins.logout(accountMasterRecordKey);

    final localAccounts = state.requireValue;
    final updated = localAccounts.removeWhere(
        (la) => la.identityMaster.masterRecordKey == accountMasterRecordKey);
    await store(updated);
    state = AsyncValue.data(updated);

    // xxx todo: wipe messages

    return true;
  }

  /// Import an account from another VeilidChat instance

  /// Recover an account with the master identity secret
}
