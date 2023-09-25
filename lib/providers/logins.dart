import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../entities/entities.dart';
import '../log/loggy.dart';
import '../tools/tools.dart';
import '../veilid_support/veilid_support.dart';
import 'local_accounts.dart';

part 'logins.g.dart';

// Local account manager
@riverpod
class Logins extends _$Logins with AsyncTableDBBacked<ActiveLogins> {
  //////////////////////////////////////////////////////////////
  /// AsyncTableDBBacked
  @override
  String tableName() => 'local_account_manager';
  @override
  String tableKeyName() => 'active_logins';
  @override
  ActiveLogins valueFromJson(Object? obj) => obj != null
      ? ActiveLogins.fromJson(obj as Map<String, dynamic>)
      : ActiveLogins.empty();
  @override
  Object? valueToJson(ActiveLogins val) => val.toJson();

  /// Get all local account information
  @override
  FutureOr<ActiveLogins> build() async {
    try {
      return await load();
    } on Exception catch (e) {
      log.error('Failed to load ActiveLogins table: $e');
      return const ActiveLogins(userLogins: IListConst([]));
    }
  }

  //////////////////////////////////////////////////////////////
  /// Mutators and Selectors

  Future<void> switchToAccount(TypedKey? accountMasterRecordKey) async {
    final current = state.requireValue;
    if (accountMasterRecordKey != null) {
      // Assert the specified record key can be found, will throw if not
      final _ = current.userLogins.firstWhere(
          (ul) => ul.accountMasterRecordKey == accountMasterRecordKey);
    }
    final updated = current.copyWith(activeUserLogin: accountMasterRecordKey);
    await store(updated);
    state = AsyncValue.data(updated);
  }

  Future<bool> _decryptedLogin(
      IdentityMaster identityMaster, SecretKey identitySecret) async {
    final veilid = await eventualVeilid.future;
    final cs =
        await veilid.getCryptoSystem(identityMaster.identityRecordKey.kind);
    final keyOk = await cs.validateKeyPair(
        identityMaster.identityPublicKey, identitySecret);
    if (!keyOk) {
      throw Exception('Identity is corrupted');
    }

    // Read the identity key to get the account keys
    final accountRecordInfo = await identityMaster.readAccountFromIdentity(
        identitySecret: identitySecret);

    // Add to user logins and select it
    final current = state.requireValue;
    final now = veilid.now();
    final updated = current.copyWith(
        userLogins: current.userLogins.replaceFirstWhere(
            (ul) => ul.accountMasterRecordKey == identityMaster.masterRecordKey,
            (ul) => ul != null
                ? ul.copyWith(lastActive: now)
                : UserLogin(
                    accountMasterRecordKey: identityMaster.masterRecordKey,
                    identitySecret:
                        TypedSecret(kind: cs.kind(), value: identitySecret),
                    accountRecordInfo: accountRecordInfo,
                    lastActive: now),
            addIfNotFound: true),
        activeUserLogin: identityMaster.masterRecordKey);
    await store(updated);
    state = AsyncValue.data(updated);

    return true;
  }

  Future<bool> login(TypedKey accountMasterRecordKey,
      EncryptionKeyType encryptionKeyType, String encryptionKey) async {
    final localAccounts = ref.read(localAccountsProvider).requireValue;

    // Get account, throws if not found
    final localAccount = localAccounts.firstWhere(
        (la) => la.identityMaster.masterRecordKey == accountMasterRecordKey);

    // Log in with this local account

    // Derive key from password
    if (localAccount.encryptionKeyType != encryptionKeyType) {
      throw Exception('Wrong authentication type');
    }

    final identitySecret = await decryptSecretFromBytes(
      secretBytes: localAccount.identitySecretBytes,
      cryptoKind: localAccount.identityMaster.identityRecordKey.kind,
      encryptionKeyType: localAccount.encryptionKeyType,
      encryptionKey: encryptionKey,
    );

    // Validate this secret with the identity public key and log in
    return _decryptedLogin(localAccount.identityMaster, identitySecret);
  }

  Future<void> logout(TypedKey? accountMasterRecordKey) async {
    final current = state.requireValue;
    final logoutUser = accountMasterRecordKey ?? current.activeUserLogin;
    if (logoutUser == null) {
      return;
    }
    final updated = current.copyWith(
        activeUserLogin: current.activeUserLogin == logoutUser
            ? null
            : current.activeUserLogin,
        userLogins: current.userLogins
            .removeWhere((ul) => ul.accountMasterRecordKey == logoutUser));
    await store(updated);
    state = AsyncValue.data(updated);
  }
}

@riverpod
Future<UserLogin?> fetchLogin(FetchLoginRef ref,
    {required TypedKey accountMasterRecordKey}) async {
  final activeLogins = await ref.watch(loginsProvider.future);
  try {
    return activeLogins.userLogins
        .firstWhere((e) => e.accountMasterRecordKey == accountMasterRecordKey);
  } on Exception catch (e) {
    if (e is StateError) {
      return null;
    }
    rethrow;
  }
}
