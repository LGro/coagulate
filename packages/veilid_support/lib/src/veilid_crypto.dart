import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import '../../../veilid_support.dart';

abstract class VeilidCrypto {
  Future<Uint8List> encrypt(Uint8List data);
  Future<Uint8List> decrypt(Uint8List data);
}

////////////////////////////////////
/// Encrypted for a specific symmetric key
class VeilidCryptoPrivate implements VeilidCrypto {
  VeilidCryptoPrivate._(VeilidCryptoSystem cryptoSystem, SharedSecret secretKey)
      : _cryptoSystem = cryptoSystem,
        _secret = secretKey;
  final VeilidCryptoSystem _cryptoSystem;
  final SharedSecret _secret;

  static Future<VeilidCryptoPrivate> fromTypedKey(
      TypedKey typedSecret, String domain) async {
    final cryptoSystem =
        await Veilid.instance.getCryptoSystem(typedSecret.kind);
    final keyMaterial = Uint8List.fromList(
        [...typedSecret.value.decode(), ...utf8.encode(domain)]);
    final secretKey = await cryptoSystem.generateHash(keyMaterial);
    return VeilidCryptoPrivate._(cryptoSystem, secretKey);
  }

  static Future<VeilidCryptoPrivate> fromTypedKeyPair(
      TypedKeyPair typedKeyPair, String domain) async {
    final typedSecret =
        TypedKey(kind: typedKeyPair.kind, value: typedKeyPair.secret);
    return fromTypedKey(typedSecret, domain);
  }

  static Future<VeilidCryptoPrivate> fromSharedSecret(
      CryptoKind kind, SharedSecret sharedSecret) async {
    final cryptoSystem = await Veilid.instance.getCryptoSystem(kind);
    return VeilidCryptoPrivate._(cryptoSystem, sharedSecret);
  }

  @override
  Future<Uint8List> encrypt(Uint8List data) =>
      _cryptoSystem.encryptNoAuthWithNonce(data, _secret);

  @override
  Future<Uint8List> decrypt(Uint8List data) =>
      _cryptoSystem.decryptNoAuthWithNonce(data, _secret);
}

////////////////////////////////////
/// No encryption
class VeilidCryptoPublic implements VeilidCrypto {
  const VeilidCryptoPublic();

  @override
  Future<Uint8List> encrypt(Uint8List data) async => data;

  @override
  Future<Uint8List> decrypt(Uint8List data) async => data;
}
