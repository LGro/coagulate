import 'dart:async';
import 'dart:typed_data';

import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:quickalert/quickalert.dart';

import '../entities/local_account.dart';
import '../providers/account.dart';
import '../providers/contact.dart';
import '../tools/tools.dart';
import '../veilid_support/veilid_support.dart';
import 'contact_invitation_display.dart';
import 'enter_pin.dart';

class SendInviteDialog extends ConsumerStatefulWidget {
  const SendInviteDialog({super.key});

  @override
  SendInviteDialogState createState() => SendInviteDialogState();
}

class SendInviteDialogState extends ConsumerState<SendInviteDialog> {
  final _messageTextController = TextEditingController(
      text: translate('send_invite_dialog.connect_with_me'));

  EncryptionKeyType _encryptionKeyType = EncryptionKeyType.none;
  String _encryptionKey = '';
  Timestamp? _expiration;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _onNoneEncryptionSelected(bool selected) async {
    setState(() {
      if (selected) {
        _encryptionKeyType = EncryptionKeyType.none;
      }
    });
  }

  Future<void> _onPinEncryptionSelected(bool selected) async {
    final description = translate('send_invite_dialog.pin_description');
    final pin = await showDialog<String>(
        context: context,
        builder: (context) => EnterPinDialog(description: description));
    if (pin == null) {
      return;
    }
    // ignore: use_build_context_synchronously
    if (!context.mounted) {
      return;
    }
    final matchpin = await showDialog<String>(
        context: context,
        builder: (context) => EnterPinDialog(
              matchPin: pin,
              description: description,
            ));
    if (matchpin == null) {
      return;
    } else if (pin == matchpin) {
      setState(() {
        _encryptionKeyType = EncryptionKeyType.pin;
        _encryptionKey = pin;
      });
    } else {
      // ignore: use_build_context_synchronously
      if (!context.mounted) {
        return;
      }
      showErrorToast(
          context, translate('send_invite_dialog.pin_does_not_match'));
      setState(() {
        _encryptionKeyType = EncryptionKeyType.none;
        _encryptionKey = '';
      });
    }
  }

  Future<void> _onPasswordEncryptionSelected(bool selected) async {
    setState(() {
      if (selected) {
        _encryptionKeyType = EncryptionKeyType.password;
      }
    });
  }

  Future<void> _onGenerateButtonPressed() async {
    final navigator = Navigator.of(context);

    // Start generation
    final activeAccountInfo = await ref.read(fetchActiveAccountProvider.future);
    if (activeAccountInfo == null) {
      navigator.pop();
      return;
    }
    final generator = createContactInvitation(
        activeAccountInfo: activeAccountInfo,
        encryptionKeyType: _encryptionKeyType,
        encryptionKey: _encryptionKey,
        message: _messageTextController.text,
        expiration: _expiration);
    // ignore: use_build_context_synchronously
    if (!context.mounted) {
      return;
    }
    await showDialog<void>(
        context: context,
        builder: (context) => ContactInvitationDisplayDialog(
              name: activeAccountInfo.localAccount.name,
              message: _messageTextController.text,
              generator: generator,
            ));
    // if (ret == null) {
    //   return;
    // }
    ref.invalidate(fetchContactInvitationRecordsProvider);
    navigator.pop();
  }

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    //final scale = theme.extension<ScaleScheme>()!;
    final textTheme = theme.textTheme;
    return SizedBox(
      height: 400,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              translate('send_invite_dialog.message_to_contact'),
            ).paddingAll(8),
            TextField(
              controller: _messageTextController,
              decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: translate('send_invite_dialog.enter_message_hint'),
                  labelText: translate('send_invite_dialog.message')),
            ).paddingAll(8),
            const SizedBox(height: 10),
            Text(translate('send_invite_dialog.protect_this_invitation'),
                    style: textTheme.labelLarge)
                .paddingAll(8),
            Wrap(spacing: 5, children: [
              ChoiceChip(
                label: Text(translate('send_invite_dialog.unlocked')),
                selected: _encryptionKeyType == EncryptionKeyType.none,
                onSelected: _onNoneEncryptionSelected,
              ),
              ChoiceChip(
                label: Text(translate('send_invite_dialog.numeric_pin')),
                selected: _encryptionKeyType == EncryptionKeyType.pin,
                onSelected: _onPinEncryptionSelected,
              ),
              ChoiceChip(
                label: Text(translate('send_invite_dialog.password')),
                selected: _encryptionKeyType == EncryptionKeyType.password,
                onSelected: _onPasswordEncryptionSelected,
              )
            ]).paddingAll(8),
            Container(
              width: double.infinity,
              height: 60,
              padding: const EdgeInsets.all(8),
              child: ElevatedButton(
                onPressed: _onGenerateButtonPressed,
                child: Text(
                  translate('send_invite_dialog.generate'),
                ),
              ),
            ),
            Text(translate('send_invite_dialog.note')).paddingAll(8),
            Text(
              translate('send_invite_dialog.note_text'),
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
