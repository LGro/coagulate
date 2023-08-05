import 'dart:typed_data';
import '../entities/local_account.dart';
import '../veilid_support/veilid_support.dart';

Future<Uint8List> encryptSecretToBytes(
    {required SecretKey secret,
    required CryptoKind cryptoKind,
    EncryptionKeyType encryptionKeyType = EncryptionKeyType.none,
    String encryptionKey = ''}) async {
  final veilid = await eventualVeilid.future;

  late final Uint8List identitySecretBytes;
  switch (encryptionKeyType) {
    case EncryptionKeyType.none:
      identitySecretBytes = secret.decode();
    case EncryptionKeyType.pin:
    case EncryptionKeyType.password:
      final cs = await veilid.getCryptoSystem(cryptoKind);

      identitySecretBytes =
          await cs.encryptNoAuthWithPassword(secret.decode(), encryptionKey);
  }
  return identitySecretBytes;
}
