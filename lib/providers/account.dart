import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:veilid/veilid.dart';

import '../entities/entities.dart';
import '../entities/proto.dart' as proto;
import '../veilid_support/veilid_support.dart';

import 'local_accounts.dart';
import 'logins.dart';

part 'account.g.dart';

enum AccountInfoStatus {
  noAccount,
  accountInvalid,
  accountLocked,
  accountReady,
}

class AccountInfo {
  AccountInfo({
    required this.status,
    required this.active,
    this.account,
  });

  AccountInfoStatus status;
  bool active;
  proto.Account? account;
}

@riverpod
Future<AccountInfo> fetchAccount(FetchAccountRef ref,
    {required TypedKey accountMasterRecordKey}) async {
  // Get which local account we want to fetch the profile for
  final veilid = await eventualVeilid.future;
  final localAccount = await ref.watch(
      fetchLocalAccountProvider(accountMasterRecordKey: accountMasterRecordKey)
          .future);
  if (localAccount == null) {
    // Local account does not exist
    return AccountInfo(status: AccountInfoStatus.noAccount, active: false);
  }

  // See if we've logged into this account or if it is locked
  final activeUserLogin = await ref.watch(loginsProvider.future
      .select((value) async => (await value).activeUserLogin));
  final active = activeUserLogin == accountMasterRecordKey;

  final login = await ref.watch(
      fetchLoginProvider(accountMasterRecordKey: accountMasterRecordKey)
          .future);
  if (login == null) {
    // Account was locked
    return AccountInfo(status: AccountInfoStatus.accountLocked, active: active);
  }

  // Read the identity key to get the account keys
  final dhtctx = (await veilid.routingContext())
      .withPrivacy()
      .withSequencing(Sequencing.ensureOrdered);
  final identityRecordCrypto = await DHTRecordCryptoPrivate.fromSecret(
      localAccount.identityMaster.identityRecordKey.kind,
      login.identitySecret.value);

  late final TypedKey accountRecordKey;
  late final KeyPair accountRecordOwner;

  await (await DHTRecord.openRead(
          dhtctx, localAccount.identityMaster.identityRecordKey,
          crypto: identityRecordCrypto))
      .scope((identityRec) async {
    final identity = await identityRec.getJson(Identity.fromJson);
    if (identity == null) {
      // Identity could not be read or decrypted from DHT
      return AccountInfo(
          status: AccountInfoStatus.accountInvalid, active: active);
    }
    final accountRecords = IMapOfSets.from(identity.accountRecords);
    final vcAccounts = accountRecords.get(veilidChatAccountKey);
    if (vcAccounts.length != 1) {
      // No veilidchat account, or multiple accounts
      // somehow associated with identity
      return AccountInfo(
          status: AccountInfoStatus.accountInvalid, active: active);
    }
    final accountRecordInfo = vcAccounts.first;
    accountRecordKey = accountRecordInfo.key;
    accountRecordOwner = accountRecordInfo.owner;
  });

  // Pull the account DHT key, decode it and return it
  final accountRecordCrypto = await DHTRecordCryptoPrivate.fromSecret(
      accountRecordKey.kind, accountRecordOwner.secret);
  late final proto.Account account;
  await (await DHTRecord.openRead(dhtctx, accountRecordKey,
          crypto: accountRecordCrypto))
      .scope((accountRec) async {
    final protoAccount = await accountRec.getProtobuf(proto.Account.fromBuffer);
    if (protoAccount == null) {
      // Account could not be read or decrypted from DHT
      return AccountInfo(
          status: AccountInfoStatus.accountInvalid, active: active);
    }
    account = protoAccount;
  });

  // Got account, decrypted and decoded
  return AccountInfo(
      status: AccountInfoStatus.accountReady, active: active, account: account);
}
