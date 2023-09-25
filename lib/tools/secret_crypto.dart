import 'dart:typed_data';
import '../entities/local_account.dart';
import '../veilid_support/veilid_support.dart';

Future<Uint8List> encryptSecretToBytes(
    {required SecretKey secret,
    required CryptoKind cryptoKind,
    EncryptionKeyType encryptionKeyType = EncryptionKeyType.none,
    String encryptionKey = ''}) async {
  final veilid = await eventualVeilid.future;

  late final Uint8List secretBytes;
  switch (encryptionKeyType) {
    case EncryptionKeyType.none:
      secretBytes = secret.decode();
    case EncryptionKeyType.pin:
    case EncryptionKeyType.password:
      final cs = await veilid.getCryptoSystem(cryptoKind);

      secretBytes =
          await cs.encryptAeadWithPassword(secret.decode(), encryptionKey);
  }
  return secretBytes;
}

Future<SecretKey> decryptSecretFromBytes(
    {required Uint8List secretBytes,
    required CryptoKind cryptoKind,
    EncryptionKeyType encryptionKeyType = EncryptionKeyType.none,
    String encryptionKey = ''}) async {
  final veilid = await eventualVeilid.future;

  late final SecretKey secret;
  switch (encryptionKeyType) {
    case EncryptionKeyType.none:
      secret = SecretKey.fromBytes(secretBytes);
    case EncryptionKeyType.pin:
    case EncryptionKeyType.password:
      final cs = await veilid.getCryptoSystem(cryptoKind);

      secret = SecretKey.fromBytes(
          await cs.decryptAeadWithPassword(secretBytes, encryptionKey));
  }
  return secret;
}
