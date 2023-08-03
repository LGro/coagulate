import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../entities/local_account.dart';
import '../entities/proto.dart' as proto;
import '../entities/user_login.dart';
import '../tools/tools.dart';
import '../veilid_support/veilid_support.dart';
import 'account.dart';

Future<Uint8List> createContactInvitation(
    ActiveAccountInfo activeAccountInfo,
    EncryptionKeyType encryptionKeyType,
    String encryptionKey,
    Timestamp expiration) async {
  final pool = await DHTRecordPool.instance();
  final accountRecordKey =
      activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;
  final identityKey =
      activeAccountInfo.localAccount.identityMaster.identityPublicKey;
  final identitySecret = activeAccountInfo.userLogin.identitySecret.value;

  // Generate writer keypair to share with new contact
  final cs = await pool.veilid.bestCryptoSystem();
  final writer = await cs.generateKeyPair();

  // Encrypt the writer secret with the encryption key
  final encryptedSecret = await encryptSecretToBytes(
      secret: writer.secret,
      cryptoKind: cs.kind(),
      encryptionKey: encryptionKey,
      encryptionKeyType: encryptionKeyType);

  // Create local chat DHT record with the account record key as its parent
  // Do not set the encryption of this key yet as it will not yet be written
  // to and it will be eventually encrypted with the DH of the contact's
  // identity key
  late final Uint8List signedContactInvitationBytes;
  await (await pool.create(parent: accountRecordKey))
      .deleteScope((localChatRecord) async {
    // Make ContactRequestPrivate and encrypt with the writer secret
    final crpriv = proto.ContactRequestPrivate()
      ..writerKey = writer.key.toProto()
      ..profile = activeAccountInfo.account.profile
      ..accountMasterRecordKey =
          activeAccountInfo.userLogin.accountMasterRecordKey.toProto()
      ..chatRecordKey = localChatRecord.key.toProto()
      ..expiration = expiration.toInt64();
    final crprivbytes = crpriv.writeToBuffer();
    final encryptedContactRequestPrivate =
        await cs.encryptNoAuthWithNonce(crprivbytes, writer.secret);

    // Create ContactRequest and embed contactrequestprivate
    final creq = proto.ContactRequest()
      ..encryptionKeyType = encryptionKeyType.toProto()
      ..private = encryptedContactRequestPrivate;

    // Create DHT unicast inbox for ContactRequest
    await (await pool.create(
            parent: accountRecordKey,
            schema: DHTSchema.smpl(
                oCnt: 1, members: [DHTSchemaMember(mCnt: 1, mKey: writer.key)]),
            crypto: const DHTRecordCryptoPublic()))
        .deleteScope((inboxRecord) async {
      // Store ContactRequest in owner subkey
      await inboxRecord.eventualWriteProtobuf(creq);

      // Create ContactInvitation and SignedContactInvitation
      final cinv = proto.ContactInvitation()
        ..contactRequestRecordKey = inboxRecord.key.toProto()
        ..writerSecret = encryptedSecret;
      final cinvbytes = cinv.writeToBuffer();
      final scinv = proto.SignedContactInvitation()
        ..contactInvitation = cinvbytes
        ..identitySignature =
            (await cs.sign(identityKey, identitySecret, cinvbytes)).toProto();
      signedContactInvitationBytes = scinv.writeToBuffer();

      // Create ContactInvitationRecord
      final cinvrec = proto.ContactInvitationRecord()
        ..contactRequestRecordKey = inboxRecord.key.toProto()
        ..writerKey = writer.key.toProto()
        ..writerSecret = writer.secret.toProto()
        ..chatRecordKey = localChatRecord.key.toProto()
        ..expiration = expiration.toInt64()
        ..invitation = signedContactInvitationBytes;

      // Add ContactInvitationRecord to local table
      await (await DHTShortArray.openOwned(
              proto.OwnedDHTRecordPointerProto.fromProto(
                  activeAccountInfo.account.contactInvitationRecords),
              parent: accountRecordKey))
          .scope((cirList) async {
        if (await cirList.tryAddItem(cinvrec.writeToBuffer()) == false) {
          throw StateError('Failed to add contact invitation record');
        }
      });
    });
  });

  return signedContactInvitationBytes;
}
