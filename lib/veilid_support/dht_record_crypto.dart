import 'dart:async';
import 'dart:typed_data';

import 'package:veilid/veilid.dart';

import 'veilid_init.dart';

abstract class DHTRecordCrypto {
  FutureOr<Uint8List> encrypt(Uint8List data, int subkey);
  FutureOr<Uint8List> decrypt(Uint8List data, int subkey);
}

////////////////////////////////////
/// Private DHT Record: Encrypted for a specific symmetric key
class DHTRecordCryptoPrivate implements DHTRecordCrypto {

  DHTRecordCryptoPrivate._(
      VeilidCryptoSystem cryptoSystem, SharedSecret secretKey)
      : _cryptoSystem = cryptoSystem,
        _secretKey = secretKey;
  final VeilidCryptoSystem _cryptoSystem;
  final SharedSecret _secretKey;

  static Future<DHTRecordCryptoPrivate> fromTypedKeyPair(
      TypedKeyPair typedKeyPair) async {
    final veilid = await eventualVeilid.future;
    final cryptoSystem = await veilid.getCryptoSystem(typedKeyPair.kind);
    final secretKey = typedKeyPair.secret;
    return DHTRecordCryptoPrivate._(cryptoSystem, secretKey);
  }

  static Future<DHTRecordCryptoPrivate> fromSecret(
      CryptoKind kind, SharedSecret secretKey) async {
    final veilid = await eventualVeilid.future;
    final cryptoSystem = await veilid.getCryptoSystem(kind);
    return DHTRecordCryptoPrivate._(cryptoSystem, secretKey);
  }

  @override
  FutureOr<Uint8List> encrypt(Uint8List data, int subkey) async {
    // generate nonce
    final nonce = await _cryptoSystem.randomNonce();
    // crypt and append nonce
    final b = BytesBuilder();
    b.add(await _cryptoSystem.cryptNoAuth(data, nonce, _secretKey));
    b.add(nonce.decode());
    return b.toBytes();
  }

  @override
  FutureOr<Uint8List> decrypt(Uint8List data, int subkey) async {
    // split off nonce from end
    if (data.length <= Nonce.decodedLength()) {
      throw const FormatException('not enough data to decrypt');
    }
    final nonce =
        Nonce.fromBytes(data.sublist(data.length - Nonce.decodedLength()));
    final encryptedData = data.sublist(0, data.length - Nonce.decodedLength());
    // decrypt
    return await _cryptoSystem.cryptNoAuth(encryptedData, nonce, _secretKey);
  }
}

////////////////////////////////////
/// Public DHT Record: No encryption
class DHTRecordCryptoPublic implements DHTRecordCrypto {
  const DHTRecordCryptoPublic();

  @override
  FutureOr<Uint8List> encrypt(Uint8List data, int subkey) => data;

  @override
  FutureOr<Uint8List> decrypt(Uint8List data, int subkey) => data;
}
