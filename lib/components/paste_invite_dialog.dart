import 'dart:async';
import 'dart:typed_data';

import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:quickalert/quickalert.dart';

import '../entities/local_account.dart';
import '../entities/proto.dart' as proto;
import '../providers/account.dart';
import '../providers/contact.dart';
import '../tools/tools.dart';
import '../veilid_support/veilid_support.dart';
import 'contact_invitation_display.dart';
import 'enter_pin.dart';

class PasteInviteDialog extends ConsumerStatefulWidget {
  const PasteInviteDialog({super.key});

  @override
  PasteInviteDialogState createState() => PasteInviteDialogState();
}

class PasteInviteDialogState extends ConsumerState<PasteInviteDialog> {
  final _pasteTextController = TextEditingController();
  final _messageTextController = TextEditingController();

  EncryptionKeyType _encryptionKeyType = EncryptionKeyType.none;
  String _encryptionKey = '';
  Timestamp? _expiration;
  proto.SignedContactInvitation? _validInvitation;

  @override
  void initState() {
    super.initState();
  }

  // Future<void> _onNoneEncryptionSelected(bool selected) async {
  //   setState(() {
  //     if (selected) {
  //       _encryptionKeyType = EncryptionKeyType.none;
  //     }
  //   });
  // }

  // Future<void> _onPinEncryptionSelected(bool selected) async {
  //   final description = translate('receive_invite_dialog.pin_description');
  //   final pin = await showDialog<String>(
  //       context: context,
  //       builder: (context) => EnterPinDialog(description: description));
  //   if (pin == null) {
  //     return;
  //   }
  //   // ignore: use_build_context_synchronously
  //   if (!context.mounted) {
  //     return;
  //   }
  //   final matchpin = await showDialog<String>(
  //       context: context,
  //       builder: (context) => EnterPinDialog(
  //             matchPin: pin,
  //             description: description,
  //           ));
  //   if (matchpin == null) {
  //     return;
  //   } else if (pin == matchpin) {
  //     setState(() {
  //       _encryptionKeyType = EncryptionKeyType.pin;
  //       _encryptionKey = pin;
  //     });
  //   } else {
  //     // ignore: use_build_context_synchronously
  //     if (!context.mounted) {
  //       return;
  //     }
  //     showErrorToast(
  //         context, translate('receive_invite_dialog.pin_does_not_match'));
  //     setState(() {
  //       _encryptionKeyType = EncryptionKeyType.none;
  //       _encryptionKey = '';
  //     });
  //   }
  // }

  // Future<void> _onPasswordEncryptionSelected(bool selected) async {
  //   setState(() {
  //     if (selected) {
  //       _encryptionKeyType = EncryptionKeyType.password;
  //     }
  //   });
  // }

  Future<void> _onPasteChanged(String text) async {
    try {
      final lines = text.split('\n');
      if (lines.isEmpty) {
        _validInvitation = null;
        return;
      }

      var firstline =
          lines.indexWhere((element) => element.contains('BEGIN VEILIDCHAT'));
      firstline += 1;

      var lastline =
          lines.indexWhere((element) => element.contains('END VEILIDCHAT'));
      if (lastline == -1) {
        lastline = lines.length;
      }
      if (lastline <= firstline) {
        _validInvitation = null;
        return;
      }
      final inviteDataBase64 = lines.sublist(firstline, lastline).join();
      final inviteData = base64UrlNoPadDecode(inviteDataBase64);
      final signedContactInvitation =
          proto.SignedContactInvitation.fromBuffer(inviteData);

      final contactInvitationBytes =
          Uint8List.fromList(signedContactInvitation.contactInvitation);
      final contactInvitation =
          proto.ContactInvitation.fromBuffer(contactInvitationBytes);

      final contactRequestInboxKey = proto.TypedKeyProto.fromProto(
          contactInvitation.contactRequestInboxKey);

      // xxx should ensure contact request is not from ourselves
      // xxx or implement as 'note to self' but this could be done more carefully
      // xxx this operation gets the wrong parent. can we allow opening dht records
      // xxx that we already have open for readonly?

      // xxx test on multiple devices

      // Open context request inbox subkey zero to get the contact request object
      final pool = await DHTRecordPool.instance();
      await (await pool.openRead(contactRequestInboxKey))
          .deleteScope((contactRequestInbox) async {
        //
        final contactRequest = await contactRequestInbox
            .getProtobuf(proto.ContactRequest.fromBuffer);
        // Decrypt contact request private
        final encryptionKeyType =
            EncryptionKeyType.fromProto(contactRequest!.encryptionKeyType);
        late final SecretKey writerSecret;
        switch (encryptionKeyType) {
          case EncryptionKeyType.none:
            writerSecret = SecretKey.fromBytes(
                Uint8List.fromList(contactInvitation.writerSecret));
          case EncryptionKeyType.pin:
          //
          case EncryptionKeyType.password:
          //
        }
        final cs =
            await pool.veilid.getCryptoSystem(contactRequestInboxKey.kind);
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

        // Verify expiration
        //xxx
        _validInvitation = signedContactInvitation;
      });
    } on Exception catch (_) {
      _validInvitation = null;
    }
  }

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    //final scale = theme.extension<ScaleScheme>()!;
    final textTheme = theme.textTheme;
    final height = MediaQuery.of(context).size.height;

    return SizedBox(
      height: 400,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              translate('paste_invite_dialog.paste_invite_here'),
            ).paddingAll(8),
            Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: TextField(
                  onChanged: _onPasteChanged,
                  style: textTheme.labelSmall!
                      .copyWith(fontFamily: 'Victor Mono', fontSize: 11),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  controller: _pasteTextController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '--- BEGIN VEILIDCHAT CONTACT INVITE ----\n'
                        'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n'
                        '---- END VEILIDCHAT CONTACT INVITE -----\n',
                    //labelText: translate('paste_invite_dialog.paste')
                  ),
                ).paddingAll(8)),
            if (_validInvitation != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle),
                    label: Text(translate('button.accept')),
                    onPressed: () {
                      //
                    },
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.cancel),
                    label: Text(translate('button.reject')),
                    onPressed: () {
                      //
                    },
                  )
                ],
              ),
            TextField(
              enabled: false,
              controller: _messageTextController,
              style: Theme.of(context).textTheme.bodySmall,
            ).paddingAll(8),
          ],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<TextEditingController>(
        'messageTextController', _messageTextController));
  }
}
