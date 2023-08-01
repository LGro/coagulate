import 'package:riverpod_annotation/riverpod_annotation.dart';

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

/// Get an account from the identity key and if it is logged in and we
/// have its secret available, return the account record contents
@riverpod
Future<AccountInfo> fetchAccount(FetchAccountRef ref,
    {required TypedKey accountMasterRecordKey}) async {
  // Get which local account we want to fetch the profile for
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

  // Pull the account DHT key, decode it and return it
  final pool = await DHTRecordPool.instance();
  final account = await (await pool.openOwned(
          login.accountRecordInfo.accountRecord,
          parent: localAccount.identityMaster.identityRecordKey))
      .scope((accountRec) => accountRec.getProtobuf(proto.Account.fromBuffer));
  if (account == null) {
    // Account could not be read or decrypted from DHT
    return AccountInfo(
        status: AccountInfoStatus.accountInvalid, active: active);
  }

  // Got account, decrypted and decoded
  return AccountInfo(
      status: AccountInfoStatus.accountReady, active: active, account: account);
}
