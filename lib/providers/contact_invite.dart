import 'dart:typed_data';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:fixnum/fixnum.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../entities/identity.dart';
import '../entities/local_account.dart';
import '../entities/proto.dart' as proto;
import '../entities/proto.dart'
    show
        ContactInvitation,
        ContactInvitationRecord,
        ContactRequest,
        ContactRequestPrivate,
        ContactResponse,
        SignedContactInvitation,
        SignedContactResponse;
import '../log/loggy.dart';
import '../tools/tools.dart';
import '../veilid_support/veilid_support.dart';
import 'account.dart';
import 'conversation.dart';

part 'contact_invite.g.dart';

class AcceptedContact {
  AcceptedContact({
    required this.profile,
    required this.remoteIdentity,
    required this.remoteConversationKey,
    required this.localConversation,
  });

  proto.Profile profile;
  IdentityMaster remoteIdentity;
  TypedKey remoteConversationKey;
  OwnedDHTRecordPointer localConversation;
}

class AcceptedOrRejectedContact {
  AcceptedOrRejectedContact({required this.acceptedContact});
  AcceptedContact? acceptedContact;
}

Future<AcceptedOrRejectedContact?> checkAcceptRejectContact(
    {required ActiveAccountInfo activeAccountInfo,
    required ContactInvitationRecord contactInvitationRecord}) async {
  // Open the contact request inbox
  try {
    final pool = await DHTRecordPool.instance();
    final accountRecordKey =
        activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;
    final writerKey =
        proto.CryptoKeyProto.fromProto(contactInvitationRecord.writerKey);
    final writerSecret =
        proto.CryptoKeyProto.fromProto(contactInvitationRecord.writerSecret);
    final writer = TypedKeyPair(
        kind: contactInvitationRecord.contactRequestInbox.recordKey.kind,
        key: writerKey,
        secret: writerSecret);
    final acceptReject = await (await pool.openRead(
            proto.TypedKeyProto.fromProto(
                contactInvitationRecord.contactRequestInbox.recordKey),
            crypto: await DHTRecordCryptoPrivate.fromTypedKeyPair(writer),
            parent: accountRecordKey,
            defaultSubkey: 1))
        .scope((contactRequestInbox) async {
      //
      final signedContactResponse = await contactRequestInbox
          .getProtobuf(SignedContactResponse.fromBuffer, forceRefresh: true);
      if (signedContactResponse == null) {
        return null;
      }

      final contactResponseBytes =
          Uint8List.fromList(signedContactResponse.contactResponse);
      final contactResponse = ContactResponse.fromBuffer(contactResponseBytes);
      final contactIdentityMasterRecordKey = proto.TypedKeyProto.fromProto(
          contactResponse.identityMasterRecordKey);
      final cs = await pool.veilid.getCryptoSystem(
          contactInvitationRecord.contactRequestInbox.recordKey.kind);

      // Fetch the remote contact's account master
      final contactIdentityMaster = await openIdentityMaster(
          identityMasterRecordKey: contactIdentityMasterRecordKey);

      // Verify
      final signature = proto.SignatureProto.fromProto(
          signedContactResponse.identitySignature);
      try {
        await cs.verify(contactIdentityMaster.identityPublicKey,
            contactResponseBytes, signature);
      } on Exception catch (e) {
        log.error('Bad identity used, failed to verify: $e');
        return null;
      }

      // Pull profile from remote conversation key
      final remoteConversationKey =
          proto.TypedKeyProto.fromProto(contactResponse.remoteConversationKey);
      final remoteConversation = await readRemoteConversation(
          activeAccountInfo: activeAccountInfo,
          remoteConversationKey: remoteConversationKey);
      if (remoteConversation == null) {
        log.error('Remote conversation could not be read');
        return null;
      }
      final localConversation = proto.OwnedDHTRecordPointerProto.fromProto(
          contactInvitationRecord.localConversation);
      return AcceptedOrRejectedContact(
          acceptedContact: AcceptedContact(
              profile: remoteConversation.profile,
              remoteIdentity: contactIdentityMaster,
              remoteConversationKey: remoteConversationKey,
              localConversation: localConversation));
    });

    if (acceptReject == null) {
      return null;
    }

    // Delete invitation and return the accepted or rejected contact
    await deleteContactInvitation(
        accepted: acceptReject.acceptedContact != null,
        activeAccountInfo: activeAccountInfo,
        contactInvitationRecord: contactInvitationRecord);

    return acceptReject;
  } on Exception catch (e) {
    log.error('Exception in checkAcceptRejectContact: $e');
    return null;
  }
}

Future<void> deleteContactInvitation(
    {required bool accepted,
    required ActiveAccountInfo activeAccountInfo,
    required ContactInvitationRecord contactInvitationRecord}) async {
  final pool = await DHTRecordPool.instance();
  final accountRecordKey =
      activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;

  // Remove ContactInvitationRecord from account's list
  await (await DHTShortArray.openOwned(
          proto.OwnedDHTRecordPointerProto.fromProto(
              activeAccountInfo.account.contactInvitationRecords),
          parent: accountRecordKey))
      .scope((cirList) async {
    for (var i = 0; i < cirList.length; i++) {
      final item = await cirList.getItemProtobuf(
          proto.ContactInvitationRecord.fromBuffer, i);
      if (item == null) {
        throw StateError('Failed to get contact invitation record');
      }
      if (item.contactRequestInbox.recordKey ==
          contactInvitationRecord.contactRequestInbox.recordKey) {
        await cirList.tryRemoveItem(i);
        break;
      }
    }
    await (await pool.openOwned(
            proto.OwnedDHTRecordPointerProto.fromProto(
                contactInvitationRecord.contactRequestInbox),
            parent: accountRecordKey))
        .scope((contactRequestInbox) async {
      // Wipe out old invitation so it shows up as invalid
      await contactRequestInbox.tryWriteBytes(Uint8List(0));
      await contactRequestInbox.delete();
    });
    if (!accepted) {
      await (await pool.openOwned(
              proto.OwnedDHTRecordPointerProto.fromProto(
                  contactInvitationRecord.localConversation),
              parent: accountRecordKey))
          .delete();
    }
  });
}

Future<Uint8List> createContactInvitation(
    {required ActiveAccountInfo activeAccountInfo,
    required EncryptionKeyType encryptionKeyType,
    required String encryptionKey,
    required String message,
    required Timestamp? expiration}) async {
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
      .deleteScope((localConversation) async {
    // Make ContactRequestPrivate and encrypt with the writer secret
    final crpriv = ContactRequestPrivate()
      ..writerKey = writer.key.toProto()
      ..profile = activeAccountInfo.account.profile
      ..identityMasterRecordKey =
          activeAccountInfo.userLogin.accountMasterRecordKey.toProto()
      ..chatRecordKey = localConversation.key.toProto()
      ..expiration = expiration?.toInt64() ?? Int64.ZERO;
    final crprivbytes = crpriv.writeToBuffer();
    final encryptedContactRequestPrivate =
        await cs.encryptNoAuthWithNonce(crprivbytes, writer.secret);

    // Create ContactRequest and embed contactrequestprivate
    final creq = ContactRequest()
      ..encryptionKeyType = encryptionKeyType.toProto()
      ..private = encryptedContactRequestPrivate;

    // Create DHT unicast inbox for ContactRequest
    await (await pool.create(
            parent: accountRecordKey,
            schema: DHTSchema.smpl(
                oCnt: 1, members: [DHTSchemaMember(mCnt: 1, mKey: writer.key)]),
            crypto: const DHTRecordCryptoPublic()))
        .deleteScope((contactRequestInbox) async {
      // Store ContactRequest in owner subkey
      await contactRequestInbox.eventualWriteProtobuf(creq);

      // Create ContactInvitation and SignedContactInvitation
      final cinv = ContactInvitation()
        ..contactRequestInboxKey = contactRequestInbox.key.toProto()
        ..writerSecret = encryptedSecret;
      final cinvbytes = cinv.writeToBuffer();
      final scinv = SignedContactInvitation()
        ..contactInvitation = cinvbytes
        ..identitySignature =
            (await cs.sign(identityKey, identitySecret, cinvbytes)).toProto();
      signedContactInvitationBytes = scinv.writeToBuffer();

      // Create ContactInvitationRecord
      final cinvrec = ContactInvitationRecord()
        ..contactRequestInbox =
            contactRequestInbox.ownedDHTRecordPointer.toProto()
        ..writerKey = writer.key.toProto()
        ..writerSecret = writer.secret.toProto()
        ..localConversation = localConversation.ownedDHTRecordPointer.toProto()
        ..expiration = expiration?.toInt64() ?? Int64.ZERO
        ..invitation = signedContactInvitationBytes
        ..message = message;

      // Add ContactInvitationRecord to account's list
      // if this fails, don't keep retrying, user can try again later
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

class ValidContactInvitation {
  ValidContactInvitation(
      {required this.signedContactInvitation,
      required this.contactInvitation,
      required this.contactRequestInboxKey,
      required this.contactRequest,
      required this.contactRequestPrivate,
      required this.contactIdentityMaster,
      required this.writer});

  SignedContactInvitation signedContactInvitation;
  ContactInvitation contactInvitation;
  TypedKey contactRequestInboxKey;
  ContactRequest contactRequest;
  ContactRequestPrivate contactRequestPrivate;
  IdentityMaster contactIdentityMaster;
  KeyPair writer;
}

typedef GetEncryptionKeyCallback = Future<SecretKey> Function(
    EncryptionKeyType encryptionKeyType, Uint8List encryptedSecret);

Future<ValidContactInvitation> validateContactInvitation(Uint8List inviteData,
    GetEncryptionKeyCallback getEncryptionKeyCallback) async {
  final signedContactInvitation =
      proto.SignedContactInvitation.fromBuffer(inviteData);

  final contactInvitationBytes =
      Uint8List.fromList(signedContactInvitation.contactInvitation);
  final contactInvitation =
      proto.ContactInvitation.fromBuffer(contactInvitationBytes);

  final contactRequestInboxKey =
      proto.TypedKeyProto.fromProto(contactInvitation.contactRequestInboxKey);

  late final ValidContactInvitation out;

  final pool = await DHTRecordPool.instance();
  await (await pool.openRead(contactRequestInboxKey))
      .deleteScope((contactRequestInbox) async {
    //
    final contactRequest =
        await contactRequestInbox.getProtobuf(proto.ContactRequest.fromBuffer);
    // Decrypt contact request private
    final encryptionKeyType =
        EncryptionKeyType.fromProto(contactRequest!.encryptionKeyType);
    final writerSecret = await getEncryptionKeyCallback(
        encryptionKeyType, Uint8List.fromList(contactInvitation.writerSecret));

    final cs = await pool.veilid.getCryptoSystem(contactRequestInboxKey.kind);
    final contactRequestPrivateBytes = await cs.decryptNoAuthWithNonce(
        Uint8List.fromList(contactRequest.private), writerSecret);
    final contactRequestPrivate =
        proto.ContactRequestPrivate.fromBuffer(contactRequestPrivateBytes);
    final contactIdentityMasterRecordKey = proto.TypedKeyProto.fromProto(
        contactRequestPrivate.identityMasterRecordKey);

    // Fetch the account master
    final contactIdentityMaster = await openIdentityMaster(
        identityMasterRecordKey: contactIdentityMasterRecordKey);

    // Verify
    final signature = proto.SignatureProto.fromProto(
        signedContactInvitation.identitySignature);
    await cs.verify(contactIdentityMaster.identityPublicKey,
        contactInvitationBytes, signature);

    final writer = KeyPair(
        key: proto.CryptoKeyProto.fromProto(contactRequestPrivate.writerKey),
        secret: writerSecret);

    out = ValidContactInvitation(
        signedContactInvitation: signedContactInvitation,
        contactInvitation: contactInvitation,
        contactRequestInboxKey: contactRequestInboxKey,
        contactRequest: contactRequest,
        contactRequestPrivate: contactRequestPrivate,
        contactIdentityMaster: contactIdentityMaster,
        writer: writer);
  });

  return out;
}

Future<AcceptedContact?> acceptContactInvitation(
    ActiveAccountInfo activeAccountInfo,
    ValidContactInvitation validContactInvitation) async {
  final pool = await DHTRecordPool.instance();
  final accountRecordKey =
      activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;

  return (await pool.openWrite(validContactInvitation.contactRequestInboxKey,
          validContactInvitation.writer))
      .deleteScope((contactRequestInbox) async {
    final cs = await pool.veilid
        .getCryptoSystem(validContactInvitation.contactRequestInboxKey.kind);

    // Create local conversation key for this
    // contact and send via contact response
    return (await pool.create(parent: accountRecordKey))
        .deleteScope((localConversation) async {
      final contactResponse = ContactResponse()
        ..accept = true
        ..remoteConversationKey = localConversation.key.toProto()
        ..identityMasterRecordKey = activeAccountInfo
            .localAccount.identityMaster.masterRecordKey
            .toProto();
      final contactResponseBytes = contactResponse.writeToBuffer();

      final identitySignature = await cs.sign(
          activeAccountInfo.localAccount.identityMaster.identityPublicKey,
          activeAccountInfo.userLogin.identitySecret.value,
          contactResponseBytes);

      final signedContactResponse = SignedContactResponse()
        ..contactResponse = contactResponseBytes
        ..identitySignature = identitySignature.toProto();

      // Write the acceptance to the inbox
      if (await contactRequestInbox.tryWriteProtobuf(
              SignedContactResponse.fromBuffer, signedContactResponse,
              subkey: 1) !=
          null) {
        log.error('failed to accept contact invitation');
        await localConversation.delete();
        await contactRequestInbox.delete();
        return null;
      }
      return AcceptedContact(
        profile: validContactInvitation.contactRequestPrivate.profile,
        remoteIdentity: validContactInvitation.contactIdentityMaster,
        remoteConversationKey: proto.TypedKeyProto.fromProto(
            validContactInvitation.contactRequestPrivate.chatRecordKey),
        localConversation: localConversation.ownedDHTRecordPointer,
      );
    });
  });
}

Future<bool> rejectContactInvitation(ActiveAccountInfo activeAccountInfo,
    ValidContactInvitation validContactInvitation) async {
  final pool = await DHTRecordPool.instance();
  return (await pool.openWrite(validContactInvitation.contactRequestInboxKey,
          validContactInvitation.writer))
      .deleteScope((contactRequestInbox) async {
    final cs = await pool.veilid
        .getCryptoSystem(validContactInvitation.contactRequestInboxKey.kind);

    final contactResponse = ContactResponse()
      ..accept = false
      ..identityMasterRecordKey = activeAccountInfo
          .localAccount.identityMaster.masterRecordKey
          .toProto();
    final contactResponseBytes = contactResponse.writeToBuffer();

    final identitySignature = await cs.sign(
        activeAccountInfo.localAccount.identityMaster.identityPublicKey,
        activeAccountInfo.userLogin.identitySecret.value,
        contactResponseBytes);

    final signedContactResponse = SignedContactResponse()
      ..contactResponse = contactResponseBytes
      ..identitySignature = identitySignature.toProto();

    // Write the rejection to the invox
    if (await contactRequestInbox.tryWriteProtobuf(
            SignedContactResponse.fromBuffer, signedContactResponse,
            subkey: 1) !=
        null) {
      log.error('failed to reject contact invitation');
      return false;
    }
    return true;
  });
}

/// Get the active account contact invitation list
@riverpod
Future<IList<ContactInvitationRecord>?> fetchContactInvitationRecords(
    FetchContactInvitationRecordsRef ref) async {
  // See if we've logged into this account or if it is locked
  final activeAccountInfo = await ref.watch(fetchActiveAccountProvider.future);
  if (activeAccountInfo == null) {
    return null;
  }
  final accountRecordKey =
      activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;

  // Decode the contact invitation list from the DHT
  IList<ContactInvitationRecord> out = const IListConst([]);
  await (await DHTShortArray.openOwned(
          proto.OwnedDHTRecordPointerProto.fromProto(
              activeAccountInfo.account.contactInvitationRecords),
          parent: accountRecordKey))
      .scope((cirList) async {
    for (var i = 0; i < cirList.length; i++) {
      final cir = await cirList.getItem(i);
      if (cir == null) {
        throw StateError('Failed to get contact invitation record');
      }
      out = out.add(ContactInvitationRecord.fromBuffer(cir));
    }
  });

  return out;
}
