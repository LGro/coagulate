import 'dart:convert';
import 'dart:typed_data';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import '../src/veilid_log.dart';
import '../veilid_support.dart';

Uint8List identityCryptoDomain = utf8.encode('identity');

/// SuperIdentity creator with secret
/// Not freezed because we never persist this class in its entirety.
class WritableSuperIdentity {
  WritableSuperIdentity._({
    required this.superIdentity,
    required this.superSecret,
    required this.identitySecret,
  });

  static Future<WritableSuperIdentity> create() async {
    final pool = DHTRecordPool.instance;

    // SuperIdentity DHT record is public/unencrypted
    veilidLoggy.debug('Creating super identity record');
    return (await pool.createRecord(
            debugName: 'WritableSuperIdentity::create::SuperIdentityRecord',
            crypto: const VeilidCryptoPublic()))
        .deleteScope((superRec) async {
      final superRecordKey = superRec.key;
      final superPublicKey = superRec.ownerKeyPair!.key;
      final superSecret = superRec.ownerKeyPair!.secret;

      return _createIdentityInstance(
          superRecordKey: superRecordKey,
          superPublicKey: superPublicKey,
          superSecret: superSecret,
          closure: (identityInstance, identitySecret) async {
            final signature = await _createSuperIdentitySignature(
              recordKey: superRecordKey,
              publicKey: superPublicKey,
              secretKey: superSecret,
              currentInstanceSignature: identityInstance.signature,
              deprecatedInstancesSignatures: [],
              deprecatedSuperRecordKeys: [],
            );

            final superIdentity = SuperIdentity(
                recordKey: superRecordKey,
                publicKey: superPublicKey,
                currentInstance: identityInstance,
                deprecatedInstances: [],
                deprecatedSuperRecordKeys: [],
                signature: signature);

            // Write superidentity to dht record
            await superRec.eventualWriteJson(superIdentity);

            return WritableSuperIdentity._(
                superIdentity: superIdentity,
                superSecret: superSecret,
                identitySecret: identitySecret);
          });
    });
  }

  ////////////////////////////////////////////////////////////////////////////
  // Public Interface

  /// Delete a super identity with secrets
  Future<void> delete() async => superIdentity.delete();

  /// Produce a recovery key for this superIdentity
  Uint8List get recoveryKey => (BytesBuilder()
        ..add(superIdentity.recordKey.decode())
        ..add(superSecret.decode()))
      .toBytes();

  /// xxx: migration support, new identities, reveal identity secret etc

  ////////////////////////////////////////////////////////////////////////////
  /// Private Implementation

  static Future<Signature> _createSuperIdentitySignature({
    required TypedKey recordKey,
    required Signature currentInstanceSignature,
    required List<Signature> deprecatedInstancesSignatures,
    required List<TypedKey> deprecatedSuperRecordKeys,
    required PublicKey publicKey,
    required SecretKey secretKey,
  }) async {
    final cs = await Veilid.instance.getCryptoSystem(recordKey.kind);
    final sigBytes = SuperIdentity.signatureBytes(
        recordKey: recordKey,
        currentInstanceSignature: currentInstanceSignature,
        deprecatedInstancesSignatures: deprecatedInstancesSignatures,
        deprecatedSuperRecordKeys: deprecatedSuperRecordKeys);
    return cs.sign(publicKey, secretKey, sigBytes);
  }

  static Future<T> _createIdentityInstance<T>({
    required TypedKey superRecordKey,
    required PublicKey superPublicKey,
    required SecretKey superSecret,
    required Future<T> Function(IdentityInstance, SecretKey) closure,
  }) async {
    final pool = DHTRecordPool.instance;
    veilidLoggy.debug('Creating identity instance record');
    // Identity record is private
    return (await pool.createRecord(
            debugName: 'SuperIdentityWithSecrets::create::IdentityRecord',
            parent: superRecordKey))
        .deleteScope((identityRec) async {
      final identityRecordKey = identityRec.key;
      assert(superRecordKey.kind == identityRecordKey.kind,
          'new super and identity should have same cryptosystem');
      final identityPublicKey = identityRec.ownerKeyPair!.key;
      final identitySecretKey = identityRec.ownerKeyPair!.secret;

      // Make encrypted secret key
      final cs = await Veilid.instance.getCryptoSystem(identityRecordKey.kind);

      final encryptionKey = await cs.deriveSharedSecret(
          superSecret.decode(), identityPublicKey.decode());
      final encryptedSecretKey = await cs.encryptNoAuthWithNonce(
          identitySecretKey.decode(), encryptionKey);

      // Make supersignature
      final superSigBuf = BytesBuilder()
        ..add(superRecordKey.decode())
        ..add(superPublicKey.decode());

      final superSignature = await cs.signWithKeyPair(
          identityRec.ownerKeyPair!, superSigBuf.toBytes());

      // Make signature
      final signature = await IdentityInstance.createIdentitySignature(
          recordKey: identityRecordKey,
          publicKey: identityPublicKey,
          encryptedSecretKey: encryptedSecretKey,
          superSignature: superSignature,
          superPublicKey: superPublicKey,
          superSecret: superSecret);

      // Make empty identity
      const identity = Identity(accountRecords: IMapConst({}));

      // Write empty identity to identity dht key
      await identityRec.eventualWriteJson(identity);

      final identityInstance = IdentityInstance(
          recordKey: identityRecordKey,
          publicKey: identityPublicKey,
          encryptedSecretKey: encryptedSecretKey,
          superSignature: superSignature,
          signature: signature);

      return closure(identityInstance, identitySecretKey);
    });
  }

  SuperIdentity superIdentity;
  SecretKey superSecret;
  SecretKey identitySecret;
}
