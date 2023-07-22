import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:veilid/veilid.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:veilidchat/providers/repositories.dart';

import '../veilid_support/veilid_support.dart';
import '../entities/entities.dart';

part 'logins.g.dart';

// Local account manager
@riverpod
class Logins extends _$Logins with AsyncTableDBBacked<ActiveLogins> {
  //////////////////////////////////////////////////////////////
  /// AsyncTableDBBacked
  @override
  String tableName() => "local_account_manager";
  @override
  String tableKeyName() => "active_logins";
  @override
  ActiveLogins reviveJson(Object? obj) => obj != null
      ? ActiveLogins.fromJson(obj as Map<String, dynamic>)
      : ActiveLogins.empty();

  /// Get all local account information
  @override
  FutureOr<ActiveLogins> build() async {
    return await load();
  }

  //////////////////////////////////////////////////////////////
  /// Mutators and Selectors

  Future<void> setActiveUserLogin(TypedKey accountMasterKey) async {
    final current = state.requireValue;
    for (final userLogin in current.userLogins) {
      if (userLogin.accountMasterRecordKey == accountMasterKey) {
        state = AsyncValue.data(
            current.copyWith(activeUserLogin: accountMasterKey));
        return;
      }
    }
    throw Exception("User not found");
  }

  Future<bool> loginWithNone(TypedKey accountMasterRecordKey) async {
    final localAccounts = ref.read(localAccountsProvider).requireValue;

    // Get account, throws if not found
    final localAccount = localAccounts.firstWhere(
        (la) => la.identityMaster.masterRecordKey == accountMasterRecordKey);

    // Log in with this local account

    // Derive key from password
    if (localAccount.encryptionKeyType != EncryptionKeyType.none) {
      throw Exception("Wrong authentication type");
    }

    final identitySecret =
        SecretKey.fromBytes(localAccount.identitySecretKeyBytes);

    // Validate this secret with the identity public key
    final cs = await Veilid.instance
        .getCryptoSystem(localAccount.identityMaster.identityRecordKey.kind);
    final keyOk = await cs.validateKeyPair(
        localAccount.identityMaster.identityPublicKey, identitySecret);
    if (!keyOk) {
      throw Exception("Identity is corrupted");
    }

    // Add to user logins and select it
    final current = state.requireValue;
    final now = Veilid.instance.now();
    final updated = current.copyWith(
        userLogins: current.userLogins.replaceFirstWhere(
            (ul) => ul.accountMasterRecordKey == accountMasterRecordKey,
            (ul) => ul != null
                ? ul.copyWith(lastActive: now)
                : UserLogin(
                    accountMasterKey: accountMasterRecordKey,
                    secretKey:
                        TypedSecret(kind: cs.kind(), value: identitySecret),
                    lastActive: now),
            addIfNotFound: true),
        activeUserLogin: accountMasterRecordKey);
    await store(updated);
    state = AsyncValue.data(updated);

    return true;
  }

  Future<bool> loginWithPasswordOrPin(
      TypedKey accountMasterRecordKey, String encryptionKey) async {
    final localAccounts = ref.read(localAccountsProvider).requireValue;

    // Get account, throws if not found
    final localAccount = localAccounts.firstWhere(
        (la) => la.identityMaster.masterRecordKey == accountMasterRecordKey);

    // Log in with this local account

    // Derive key from password
    if (localAccount.encryptionKeyType != EncryptionKeyType.password ||
        localAccount.encryptionKeyType != EncryptionKeyType.pin) {
      throw Exception("Wrong authentication type");
    }
    final cs = await Veilid.instance
        .getCryptoSystem(localAccount.identityMaster.identityRecordKey.kind);
    final ekbytes = Uint8List.fromList(utf8.encode(encryptionKey));
    final eksalt = localAccount.identitySecretSaltBytes;
    final nonce = Nonce.fromBytes(eksalt);
    SharedSecret sharedSecret = await cs.deriveSharedSecret(ekbytes, eksalt);
    final identitySecret = SecretKey.fromBytes(await cs.cryptNoAuth(
        localAccount.identitySecretKeyBytes, nonce, sharedSecret));

    // Validate this secret with the identity public key
    final keyOk = await cs.validateKeyPair(
        localAccount.identityMaster.identityPublicKey, identitySecret);
    if (!keyOk) {
      return false;
    }

    // Add to user logins and select it
    final current = state.requireValue;
    final now = Veilid.instance.now();
    final updated = current.copyWith(
        userLogins: current.userLogins.replaceFirstWhere(
            (ul) => ul.accountMasterRecordKey == accountMasterRecordKey,
            (ul) => ul != null
                ? ul.copyWith(lastActive: now)
                : UserLogin(
                    accountMasterKey: accountMasterRecordKey,
                    secretKey:
                        TypedSecret(kind: cs.kind(), value: identitySecret),
                    lastActive: now),
            addIfNotFound: true),
        activeUserLogin: accountMasterRecordKey);
    await store(updated);
    state = AsyncValue.data(updated);

    return true;
  }

  Future<void> logout() async {
    final current = state.requireValue;
    if (current.activeUserLogin == null) {
      return;
    }
    final updated = current.copyWith(
        activeUserLogin: null,
        userLogins: current.userLogins.removeWhere(
            (ul) => ul.accountMasterRecordKey == current.activeUserLogin));
    await store(updated);
    state = AsyncValue.data(updated);
  }

  Future<void> switchToAccount(TypedKey accountMasterRecordKey) async {
    final current = state.requireValue;
    final userLogin = current.userLogins.firstWhere(
        (ul) => ul.accountMasterRecordKey == accountMasterRecordKey);
    final updated =
        current.copyWith(activeUserLogin: userLogin.accountMasterRecordKey);
    await store(updated);
    state = AsyncValue.data(updated);
  }
}
