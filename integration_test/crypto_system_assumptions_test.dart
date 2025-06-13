import 'dart:convert';

import 'package:coagulate/veilid_init.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veilid_support/veilid_support.dart';

void main() {
  setUp(() async {
    await CoagulateGlobalInit.initialize();
  });

  test('DH derived symmetric key is consistent across derivations and parties',
      () async {
    final cryptoSystem = await DHTRecordPool.instance.veilid.bestCryptoSystem();
    final kpA = await cryptoSystem
        .generateKeyPair()
        .then((kp) => TypedKeyPair.fromKeyPair(cryptoSystem.kind(), kp));
    final kpB = await cryptoSystem
        .generateKeyPair()
        .then((kp) => TypedKeyPair.fromKeyPair(cryptoSystem.kind(), kp));

    final secA1 = await cryptoSystem.generateSharedSecret(
        kpB.key, kpA.secret, utf8.encode('my_domain'));
    final secA2 = await cryptoSystem.generateSharedSecret(
        kpB.key, kpA.secret, utf8.encode('my_domain'));
    final secB = await cryptoSystem.generateSharedSecret(
        kpA.key, kpB.secret, utf8.encode('my_domain'));
    expect(secA1 == secA2, true);
    expect(secA1 == secB, true);
  });

  test('DH key exchange', () async {
    final cryptoSystem = await DHTRecordPool.instance.veilid.bestCryptoSystem();
    final kpA = await cryptoSystem
        .generateKeyPair()
        .then((kp) => TypedKeyPair.fromKeyPair(cryptoSystem.kind(), kp));
    final kpB = await cryptoSystem
        .generateKeyPair()
        .then((kp) => TypedKeyPair.fromKeyPair(cryptoSystem.kind(), kp));

    final secA = await cryptoSystem.generateSharedSecret(
        kpB.key, kpA.secret, utf8.encode('my_domain'));
    final secB = await cryptoSystem.generateSharedSecret(
        kpA.key, kpB.secret, utf8.encode('my_domain'));

    final payload = utf8.encode('hello');
    final ce =
        await VeilidCryptoPrivate.fromSharedSecret(cryptoSystem.kind(), secA);
    final encForB = await ce.encrypt(payload);

    final cd =
        await VeilidCryptoPrivate.fromSharedSecret(cryptoSystem.kind(), secB);
    final dec = await cd.decrypt(encForB);
    expect(dec, payload);
  });
}
