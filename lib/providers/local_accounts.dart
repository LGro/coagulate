import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../entities/entities.dart';
import '../proto/proto.dart' as proto;
import '../tools/tools.dart';
import '../veilid_init.dart';
import '../veilid_support/veilid_support.dart';
import 'logins.dart';

part 'local_accounts.g.dart';

const String veilidChatAccountKey = 'com.veilid.veilidchat';

// Local account manager
@riverpod
class LocalAccounts extends _$LocalAccounts
    with AsyncTableDBBacked<IList<LocalAccount>> {
  //////////////////////////////////////////////////////////////
  /// AsyncTableDBBacked
  @override
  String tableName() => 'local_account_manager';
  @override
  String tableKeyName() => 'local_accounts';
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
    try {
      await eventualVeilid.future;
      return await load();
    } on Exception catch (e) {
      log.error('Failed to load LocalAccounts table: $e', e);
      return const IListConst([]);
    }
  }

  //////////////////////////////////////////////////////////////
  /// Mutators and Selectors

  /// Reorder accounts
  Future<void> reorderAccount(int oldIndex, int newIndex) async {
    final localAccounts = state.requireValue;
    final removedItem = Output<LocalAccount>();
    final updated = localAccounts
        .removeAt(oldIndex, removedItem)
        .insert(newIndex, removedItem.value!);
    await store(updated);
    state = AsyncValue.data(updated);
  }

  /// Creates a new Account associated with master identity
  /// Adds a logged-out LocalAccount to track its existence on this device
  Future<LocalAccount> newLocalAccount(
      {required IdentityMaster identityMaster,
      required SecretKey identitySecret,
      required String name,
      required String pronouns,
      EncryptionKeyType encryptionKeyType = EncryptionKeyType.none,
      String encryptionKey = ''}) async {
    final localAccounts = state.requireValue;

    // Add account with profile to DHT
    await identityMaster.addAccountToIdentity(
        identitySecret: identitySecret,
        accountKey: veilidChatAccountKey,
        createAccountCallback: (parent) async {
          // Make empty contact list
          final contactList = await (await DHTShortArray.create(parent: parent))
              .scope((r) async => r.record.ownedDHTRecordPointer);

          // Make empty contact invitation record list
          final contactInvitationRecords =
              await (await DHTShortArray.create(parent: parent))
                  .scope((r) async => r.record.ownedDHTRecordPointer);

          // Make empty chat record list
          final chatRecords = await (await DHTShortArray.create(parent: parent))
              .scope((r) async => r.record.ownedDHTRecordPointer);

          // Make account object
          final account = proto.Account()
            ..profile = (proto.Profile()
              ..name = name
              ..pronouns = pronouns)
            ..contactList = contactList.toProto()
            ..contactInvitationRecords = contactInvitationRecords.toProto()
            ..chatList = chatRecords.toProto();
          return account;
        });

    // Encrypt identitySecret with key
    final identitySecretBytes = await encryptSecretToBytes(
        secret: identitySecret,
        cryptoKind: identityMaster.identityRecordKey.kind,
        encryptionKey: encryptionKey,
        encryptionKeyType: encryptionKeyType);

    // Create local account object
    // Does not contain the account key or its secret
    // as that is not to be persisted, and only pulled from the identity key
    // and optionally decrypted with the unlock password
    final localAccount = LocalAccount(
      identityMaster: identityMaster,
      identitySecretBytes: identitySecretBytes,
      encryptionKeyType: encryptionKeyType,
      biometricsEnabled: false,
      hiddenAccount: false,
      name: name,
    );

    // Add local account object to internal store
    final newLocalAccounts = localAccounts.add(localAccount);
    await store(newLocalAccounts);
    state = AsyncValue.data(newLocalAccounts);

    // Return local account object
    return localAccount;
  }

  /// Remove an account and wipe the messages for this account from this device
  Future<bool> deleteLocalAccount(TypedKey accountMasterRecordKey) async {
    final logins = ref.read(loginsProvider.notifier);
    await logins.logout(accountMasterRecordKey);

    final localAccounts = state.requireValue;
    final updated = localAccounts.removeWhere(
        (la) => la.identityMaster.masterRecordKey == accountMasterRecordKey);
    await store(updated);
    state = AsyncValue.data(updated);

    // TO DO: wipe messages

    return true;
  }

  /// Import an account from another VeilidChat instance

  /// Recover an account with the master identity secret

  /// Delete an account from all devices
}

@riverpod
Future<LocalAccount?> fetchLocalAccount(FetchLocalAccountRef ref,
    {required TypedKey accountMasterRecordKey}) async {
  final localAccounts = await ref.watch(localAccountsProvider.future);
  try {
    return localAccounts.firstWhere(
        (e) => e.identityMaster.masterRecordKey == accountMasterRecordKey);
  } on Exception catch (e) {
    if (e is StateError) {
      return null;
    }
    rethrow;
  }
}
