import 'dart:async';

import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:quickalert/quickalert.dart';

import '../entities/local_account.dart';
import '../providers/account.dart';
import '../providers/contact.dart';
import '../providers/contact_invite.dart';
import '../tools/tools.dart';
import '../veilid_support/veilid_support.dart';
import 'enter_pin.dart';
import 'profile_widget.dart';

class ScanInviteDialog extends ConsumerStatefulWidget {
  const ScanInviteDialog({super.key});

  @override
  ScanInviteDialogState createState() => ScanInviteDialogState();
}

class ScanInviteDialogState extends ConsumerState<ScanInviteDialog> {
  final _pasteTextController = TextEditingController();

  EncryptionKeyType _encryptionKeyType = EncryptionKeyType.none;
  String _encryptionKey = '';
  Timestamp? _expiration;
  ValidContactInvitation? _validInvitation;
  bool _validatingPaste = false;
  bool _isAccepting = false;

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
        await createContact(
          activeAccountInfo: activeAccountInfo,
          profile: acceptedContact.profile,
          remoteIdentity: acceptedContact.remoteIdentity,
          remoteConversationRecordKey:
              acceptedContact.remoteConversationRecordKey,
          localConversationRecordKey:
              acceptedContact.localConversationRecordKey,
        );
        ref
          ..invalidate(fetchContactInvitationRecordsProvider)
          ..invalidate(fetchContactListProvider);
      } else {
        if (context.mounted) {
          showErrorToast(context, 'paste_invite_dialog.failed_to_accept');
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
          showErrorToast(context, 'paste_invite_dialog.failed_to_reject');
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

      setState(() {
        _validatingPaste = true;
        _validInvitation = null;
      });
      final validatedContactInvitation = await validateContactInvitation(
          inviteData, (encryptionKeyType, encryptedSecret) async {
        switch (encryptionKeyType) {
          case EncryptionKeyType.none:
            return SecretKey.fromBytes(encryptedSecret);
          case EncryptionKeyType.pin:
            //xxx
            return SecretKey.fromBytes(encryptedSecret);
          case EncryptionKeyType.password:
            //xxx
            return SecretKey.fromBytes(encryptedSecret);
        }
      });
      // Verify expiration
      // xxx

      setState(() {
        _validatingPaste = false;
        _validInvitation = validatedContactInvitation;
      });
    } on Exception catch (_) {
      setState(() {
        _validatingPaste = false;
        _validInvitation = null;
      });
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
      constraints: const BoxConstraints(maxHeight: 400),
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
                ).paddingAll(8)),
            if (_validatingPaste)
              Column(children: [
                Text(translate('paste_invite_dialog.validating')),
                buildProgressIndicator(context),
              ]),
            if (_validInvitation == null &&
                !_validatingPaste &&
                _pasteTextController.text.isNotEmpty)
              Column(children: [
                Text(translate('paste_invite_dialog.invalid_invitation')),
                const Icon(Icons.error)
              ]).paddingAll(16).toCenter(),
            if (_validInvitation != null && !_validatingPaste)
              Column(children: [
                ProfileWidget(
                    name: _validInvitation!.contactRequestPrivate.profile.name,
                    title:
                        _validInvitation!.contactRequestPrivate.profile.title),
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
