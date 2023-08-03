// ignore_for_file: prefer_expression_function_bodies

import 'dart:typed_data';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import '../entities/identity.dart';
import 'veilid_support.dart';

// Identity Master with secrets
// Not freezed because we never persist this class in its entirety
class IdentityMasterWithSecrets {
  IdentityMasterWithSecrets._(
      {required this.identityMaster,
      required this.masterSecret,
      required this.identitySecret});
  IdentityMaster identityMaster;
  SecretKey masterSecret;
  SecretKey identitySecret;

  /// Creates a new master identity and returns it with its secrets
  static Future<IdentityMasterWithSecrets> create() async {
    final pool = await DHTRecordPool.instance();

    // IdentityMaster DHT record is public/unencrypted
    return (await pool.create(crypto: const DHTRecordCryptoPublic()))
        .deleteScope((masterRec) async {
      // Identity record is private
      return (await pool.create(parent: masterRec.key))
          .scope((identityRec) async {
        // Make IdentityMaster
        final masterRecordKey = masterRec.key;
        final masterOwner = masterRec.ownerKeyPair!;
        final masterSigBuf = BytesBuilder()
          ..add(masterRecordKey.decode())
          ..add(masterOwner.key.decode());

        final identityRecordKey = identityRec.key;
        final identityOwner = identityRec.ownerKeyPair!;
        final identitySigBuf = BytesBuilder()
          ..add(identityRecordKey.decode())
          ..add(identityOwner.key.decode());

        assert(masterRecordKey.kind == identityRecordKey.kind,
            'new master and identity should have same cryptosystem');
        final crypto = await pool.veilid.getCryptoSystem(masterRecordKey.kind);

        final identitySignature =
            await crypto.signWithKeyPair(masterOwner, identitySigBuf.toBytes());
        final masterSignature =
            await crypto.signWithKeyPair(identityOwner, masterSigBuf.toBytes());

        final identityMaster = IdentityMaster(
            identityRecordKey: identityRecordKey,
            identityPublicKey: identityOwner.key,
            masterRecordKey: masterRecordKey,
            masterPublicKey: masterOwner.key,
            identitySignature: identitySignature,
            masterSignature: masterSignature);

        // Write identity master to master dht key
        await masterRec.eventualWriteJson(identityMaster);

        // Make empty identity
        const identity = Identity(accountRecords: IMapConst({}));

        // Write empty identity to identity dht key
        await identityRec.eventualWriteJson(identity);

        return IdentityMasterWithSecrets._(
            identityMaster: identityMaster,
            masterSecret: masterOwner.secret,
            identitySecret: identityOwner.secret);
      });
    });
  }

  /// Creates a new master identity and returns it with its secrets
  Future<void> delete() async {
    final pool = await DHTRecordPool.instance();
    await pool.deleteDeep(identityMaster.masterRecordKey);
  }
}
