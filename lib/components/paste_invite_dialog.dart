import 'dart:async';

import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../entities/local_account.dart';
import '../providers/account.dart';
import '../providers/contact.dart';
import '../providers/contact_invite.dart';
import '../tools/tools.dart';
import '../veilid_support/veilid_support.dart';
import 'enter_pin.dart';
import 'profile_widget.dart';

class PasteInviteDialog extends ConsumerStatefulWidget {
  const PasteInviteDialog({super.key});

  @override
  PasteInviteDialogState createState() => PasteInviteDialogState();

  static Future<void> show(BuildContext context) async {
    await showStyledDialog<void>(
        context: context,
        title: translate('paste_invite_dialog.title'),
        child: const PasteInviteDialog());
  }
}

class PasteInviteDialogState extends ConsumerState<PasteInviteDialog> {
  final _pasteTextController = TextEditingController();

  ValidContactInvitation? _validInvitation;
  bool _validatingPaste = false;
  bool _isAccepting = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _onAccept() async {
    final navigator = Navigator.of(context);

    setState(() {
      _isAccepting = true;
    });
    final activeAccountInfo = await ref.read(fetchActiveAccountProvider.future);
    if (activeAccountInfo == null) {
      setState(() {
        _isAccepting = false;
      });
      navigator.pop();
      return;
    }
    final validInvitation = _validInvitation;
    if (validInvitation != null) {
      final acceptedContact =
          await acceptContactInvitation(activeAccountInfo, validInvitation);
      if (acceptedContact != null) {
        // initiator when accept is received will create
        // contact in the case of a 'note to self'
        final isSelf =
            activeAccountInfo.localAccount.identityMaster.identityPublicKey ==
                acceptedContact.remoteIdentity.identityPublicKey;
        if (!isSelf) {
          await createContact(
            activeAccountInfo: activeAccountInfo,
            profile: acceptedContact.profile,
            remoteIdentity: acceptedContact.remoteIdentity,
            remoteConversationRecordKey:
                acceptedContact.remoteConversationRecordKey,
            localConversationRecordKey:
                acceptedContact.localConversationRecordKey,
          );
        }
        ref
          ..invalidate(fetchContactInvitationRecordsProvider)
          ..invalidate(fetchContactListProvider);
      } else {
        if (context.mounted) {
          showErrorToast(context, 'contact_invite.failed_to_accept');
        }
      }
    }
    setState(() {
      _isAccepting = false;
    });
    navigator.pop();
  }

  Future<void> _onReject() async {
    final navigator = Navigator.of(context);

    setState(() {
      _isAccepting = true;
    });
    final activeAccountInfo = await ref.read(fetchActiveAccountProvider.future);
    if (activeAccountInfo == null) {
      setState(() {
        _isAccepting = false;
      });
      navigator.pop();
      return;
    }
    final validInvitation = _validInvitation;
    if (validInvitation != null) {
      if (await rejectContactInvitation(activeAccountInfo, validInvitation)) {
        // do nothing right now
      } else {
        if (context.mounted) {
          showErrorToast(context, 'contact_invite.failed_to_reject');
        }
      }
    }
    setState(() {
      _isAccepting = false;
    });
    navigator.pop();
  }

  Future<void> _onPasteChanged(String text) async {
    try {
      final lines = text.split('\n');
      if (lines.isEmpty) {
        setState(() {
          _validatingPaste = false;
          _validInvitation = null;
        });
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
        setState(() {
          _validatingPaste = false;
          _validInvitation = null;
        });
        return;
      }
      final inviteDataBase64 = lines.sublist(firstline, lastline).join();
      final inviteData = base64UrlNoPadDecode(inviteDataBase64);

      final activeAccountInfo =
          await ref.read(fetchActiveAccountProvider.future);
      if (activeAccountInfo == null) {
        setState(() {
          _validatingPaste = false;
          _validInvitation = null;
        });
        return;
      }
      final contactInvitationRecords =
          await ref.read(fetchContactInvitationRecordsProvider.future);

      setState(() {
        _validatingPaste = true;
        _validInvitation = null;
      });
      final validatedContactInvitation = await validateContactInvitation(
          activeAccountInfo: activeAccountInfo,
          contactInvitationRecords: contactInvitationRecords,
          inviteData: inviteData,
          getEncryptionKeyCallback:
              (cs, encryptionKeyType, encryptedSecret) async {
            String encryptionKey;
            switch (encryptionKeyType) {
              case EncryptionKeyType.none:
                encryptionKey = '';
              case EncryptionKeyType.pin:
                final description =
                    translate('contact_invite.protected_with_pin');
                if (!context.mounted) {
                  return null;
                }
                final pin = await showDialog<String>(
                    context: context,
                    builder: (context) =>
                        EnterPinDialog(description: description));
                if (pin == null) {
                  return null;
                }
                encryptionKey = pin;
              case EncryptionKeyType.password:
                final description =
                    translate('contact_invite.protected_with_pin');
                if (!context.mounted) {
                  return null;
                }
                final password = await showDialog<String>(
                    context: context,
                    builder: (context) =>
                        EnterPinDialog(description: description));
                if (password == null) {
                  return null;
                }
                encryptionKey = password;
            }
            return decryptSecretFromBytes(
                secretBytes: encryptedSecret,
                cryptoKind: cs.kind(),
                encryptionKeyType: encryptionKeyType,
                encryptionKey: encryptionKey);
          });

      // Check if validation was cancelled
      if (validatedContactInvitation == null) {
        setState(() {
          _validatingPaste = false;
          _validInvitation = null;
        });
        return;
      }

      // Verify expiration
      // xxx

      setState(() {
        _validatingPaste = false;
        _validInvitation = validatedContactInvitation;
      });
    } on ContactInviteInvalidKeyException catch (e) {
      String errorText;
      switch (e.type) {
        case EncryptionKeyType.none:
          errorText = translate('contact_invite.invalid_invitation');
        case EncryptionKeyType.password:
          errorText = translate('contact_invite.invalid_pin');
        case EncryptionKeyType.pin:
          errorText = translate('contact_invite.invalid_password');
      }
      if (context.mounted) {
        showErrorToast(context, errorText);
      }
      setState(() {
        _validatingPaste = false;
        _validInvitation = null;
      });
    } on Exception catch (_) {
      setState(() {
        _validatingPaste = false;
        _validInvitation = null;
      });
      rethrow;
    }
  }

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    //final scale = theme.extension<ScaleScheme>()!;
    final textTheme = theme.textTheme;
    //final height = MediaQuery.of(context).size.height;

    if (_isAccepting) {
      return SizedBox(height: 400, child: waitingPage(context));
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 400, maxWidth: 400),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              translate('paste_invite_dialog.paste_invite_here'),
            ).paddingLTRB(0, 0, 0, 8),
            Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: TextField(
                  enabled: !_validatingPaste,
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
                )).paddingLTRB(0, 0, 0, 8),
            if (_validatingPaste)
              Column(children: [
                Text(translate('contact_invite.validating'))
                    .paddingLTRB(0, 0, 0, 8),
                buildProgressIndicator(context),
              ]).paddingAll(16).toCenter(),
            if (_validInvitation == null &&
                !_validatingPaste &&
                _pasteTextController.text.isNotEmpty)
              Column(children: [
                Text(translate('contact_invite.invalid_invitation')),
                const Icon(Icons.error)
              ]).paddingAll(16).toCenter(),
            if (_validInvitation != null && !_validatingPaste)
              Column(children: [
                Container(
                        constraints: const BoxConstraints(maxHeight: 64),
                        width: double.infinity,
                        child: ProfileWidget(
                            name: _validInvitation!
                                .contactRequestPrivate.profile.name,
                            title: _validInvitation!
                                .contactRequestPrivate.profile.title))
                    .paddingLTRB(0, 0, 0, 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle),
                      label: Text(translate('button.accept')),
                      onPressed: _onAccept,
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.cancel),
                      label: Text(translate('button.reject')),
                      onPressed: _onReject,
                    )
                  ],
                ),
              ])
          ],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
  }
}
