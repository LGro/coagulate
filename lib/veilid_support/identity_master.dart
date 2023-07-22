import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:veilid/veilid.dart';

import '../entities/identity.dart';
import 'veilid_support.dart';

/// Creates a new master identity and returns it with its secrets
Future<IdentityMasterWithSecrets> newIdentityMaster() async {
  final crypto = await Veilid.instance.bestCryptoSystem();
  final dhtctx = (await Veilid.instance.routingContext())
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
      final masterSigBuf = masterRecordKey.decode()
        ..addAll(masterOwner.key.decode());

      final identityRecordKey = identityRec.key();
      final identityOwner = identityRec.ownerKeyPair()!;
      final identitySigBuf = identityRecordKey.decode()
        ..addAll(identityOwner.key.decode());

      final identitySignature =
          await crypto.signWithKeyPair(masterOwner, identitySigBuf);
      final masterSignature =
          await crypto.signWithKeyPair(identityOwner, masterSigBuf);

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
