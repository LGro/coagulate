import 'dart:typed_data';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:veilid/veilid.dart';

import '../entities/identity.dart';
import 'veilid_support.dart';

// Identity Master with secrets
// Not freezed because we never persist this class in its entirety
class IdentityMasterWithSecrets {
  IdentityMaster identityMaster;
  SecretKey masterSecret;
  SecretKey identitySecret;
  IdentityMasterWithSecrets(
      {required this.identityMaster,
      required this.masterSecret,
      required this.identitySecret});

  Future<void> delete() async {
    final veilid = await eventualVeilid.future;
    final dhtctx = (await veilid.routingContext())
        .withPrivacy()
        .withSequencing(Sequencing.ensureOrdered);
    await dhtctx.deleteDHTRecord(identityMaster.masterRecordKey);
    await dhtctx.deleteDHTRecord(identityMaster.identityRecordKey);
  }
}

/// Creates a new master identity and returns it with its secrets
Future<IdentityMasterWithSecrets> newIdentityMaster() async {
  final veilid = await eventualVeilid.future;
  final dhtctx = (await veilid.routingContext())
      .withPrivacy()
      .withSequencing(Sequencing.ensureOrdered);

  // IdentityMaster DHT record is public/unencrypted
  return (await DHTRecord.create(dhtctx, crypto: const DHTRecordCryptoPublic()))
      .deleteScope((masterRec) async {
    // Identity record is private
    return (await DHTRecord.create(dhtctx)).deleteScope((identityRec) async {
      // Make IdentityMaster
      final masterRecordKey = masterRec.key();
      final masterOwner = masterRec.ownerKeyPair()!;
      final masterSigBuf = BytesBuilder();
      masterSigBuf.add(masterRecordKey.decode());
      masterSigBuf.add(masterOwner.key.decode());

      final identityRecordKey = identityRec.key();
      final identityOwner = identityRec.ownerKeyPair()!;
      final identitySigBuf = BytesBuilder();
      identitySigBuf.add(identityRecordKey.decode());
      identitySigBuf.add(identityOwner.key.decode());

      assert(masterRecordKey.kind == identityRecordKey.kind);
      final crypto = await veilid.getCryptoSystem(masterRecordKey.kind);

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

      return IdentityMasterWithSecrets(
          identityMaster: identityMaster,
          masterSecret: masterOwner.secret,
          identitySecret: identityOwner.secret);
    });
  });
}
