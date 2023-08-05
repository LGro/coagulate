import 'dart:typed_data';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:fixnum/fixnum.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../entities/local_account.dart';
import '../entities/proto.dart' as proto;
import '../entities/proto.dart'
    show
        Contact,
        ContactInvitation,
        ContactInvitationRecord,
        ContactRequest,
        ContactRequestPrivate,
        SignedContactInvitation;
import '../tools/tools.dart';
import '../veilid_support/veilid_support.dart';
import 'account.dart';

part 'contact.g.dart';

Future<void> deleteContactInvitation(
    {required ActiveAccountInfo activeAccountInfo,
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
        .delete();
    await (await pool.openOwned(
            proto.OwnedDHTRecordPointerProto.fromProto(
                contactInvitationRecord.localConversation),
            parent: accountRecordKey))
        .delete();
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

/// Get the active account contact list
@riverpod
Future<IList<Contact>?> fetchContactList(FetchContactListRef ref) async {
  // See if we've logged into this account or if it is locked
  final activeAccountInfo = await ref.watch(fetchActiveAccountProvider.future);
  if (activeAccountInfo == null) {
    return null;
  }
  final accountRecordKey =
      activeAccountInfo.userLogin.accountRecordInfo.accountRecord.recordKey;

  // Decode the contact list from the DHT
  IList<Contact> out = const IListConst([]);
  await (await DHTShortArray.openOwned(
          proto.OwnedDHTRecordPointerProto.fromProto(
              activeAccountInfo.account.contactList),
          parent: accountRecordKey))
      .scope((cList) async {
    for (var i = 0; i < cList.length; i++) {
      final cir = await cList.getItem(i);
      if (cir == null) {
        throw StateError('Failed to get contact');
      }
      out = out.add(Contact.fromBuffer(cir));
    }
  });

  return out;
}
