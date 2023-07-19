import 'package:veilid/veilid.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../entities/entities.dart';
import '../entities/proto.dart' as proto;

import 'local_account_repository_impl.dart';

part 'local_account_repository.g.dart';

// Local account manager
abstract class LocalAccountRepository {
  /// Creates a new master identity and returns it with its secrets
  Future<IdentityMasterWithSecrets> newIdentityMaster();

  /// Creates a new account associated with master identity
  Future<LocalAccount> newAccount(
      IdentityMaster identityMaster,
      SecretKey identitySecret,
      EncryptionKeyType encryptionKeyType,
      String encryptionKey,
      proto.Account account);
}

@riverpod
Future<LocalAccountRepository> localAccountManager(
    LocalAccountManagerRef ref) async {
  return await LocalAccountRepositoryImpl.open();
}
