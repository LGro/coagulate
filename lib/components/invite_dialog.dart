import 'dart:async';
import 'dart:typed_data';

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
import 'enter_password.dart';
import 'enter_pin.dart';
import 'profile_widget.dart';

class InviteDialog extends ConsumerStatefulWidget {
  const InviteDialog(
      {required this.onValidationCancelled,
      required this.onValidationSuccess,
      required this.onValidationFailed,
      required this.inviteControlIsValid,
      required this.buildInviteControl,
      super.key});

  final void Function() onValidationCancelled;
  final void Function() onValidationSuccess;
  final void Function() onValidationFailed;
  final bool Function() inviteControlIsValid;
  final Widget Function(
      BuildContext context,
      InviteDialogState dialogState,
      Future<void> Function({required Uint8List inviteData})
          validateInviteData) buildInviteControl;

  @override
  InviteDialogState createState() => InviteDialogState();
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(ObjectFlagProperty<void Function()>.has(
          'onValidationCancelled', onValidationCancelled))
      ..add(ObjectFlagProperty<void Function()>.has(
          'onValidationSuccess', onValidationSuccess))
      ..add(ObjectFlagProperty<void Function()>.has(
          'onValidationFailed', onValidationFailed))
      ..add(ObjectFlagProperty<void Function()>.has(
          'inviteControlIsValid', inviteControlIsValid))
      ..add(ObjectFlagProperty<
              Widget Function(
                  BuildContext context,
                  InviteDialogState dialogState,
                  Future<void> Function({required Uint8List inviteData})
                      validateInviteData)>.has(
          'buildInviteControl', buildInviteControl));
  }
}

class InviteDialogState extends ConsumerState<InviteDialog> {
  ValidContactInvitation? _validInvitation;
  bool _isValidating = false;
  bool _isAccepting = false;

  @override
  void initState() {
    super.initState();
  }

  bool get isValidating => _isValidating;
  bool get isAccepting => _isAccepting;

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
          showErrorToast(context, 'invite_dialog.failed_to_accept');
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
          showErrorToast(context, 'invite_dialog.failed_to_reject');
        }
      }
    }
    setState(() {
      _isAccepting = false;
    });
    navigator.pop();
  }

  Future<void> _validateInviteData({
    required Uint8List inviteData,
  }) async {
    try {
      final activeAccountInfo =
          await ref.read(fetchActiveAccountProvider.future);
      if (activeAccountInfo == null) {
        setState(() {
          _isValidating = false;
          _validInvitation = null;
        });
        return;
      }
      final contactInvitationRecords =
          await ref.read(fetchContactInvitationRecordsProvider.future);

      setState(() {
        _isValidating = true;
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
                    translate('invite_dialog.protected_with_pin');
                if (!context.mounted) {
                  return null;
                }
                final pin = await showDialog<String>(
                    context: context,
                    builder: (context) => EnterPinDialog(
                        reenter: false, description: description));
                if (pin == null) {
                  return null;
                }
                encryptionKey = pin;
              case EncryptionKeyType.password:
                final description =
                    translate('invite_dialog.protected_with_password');
                if (!context.mounted) {
                  return null;
                }
                final password = await showDialog<String>(
                    context: context,
                    builder: (context) =>
                        EnterPasswordDialog(description: description));
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
          _isValidating = false;
          _validInvitation = null;
          widget.onValidationCancelled();
        });
        return;
      }

      // Verify expiration
      // xxx

      setState(() {
        widget.onValidationSuccess();
        _isValidating = false;
        _validInvitation = validatedContactInvitation;
      });
    } on ContactInviteInvalidKeyException catch (e) {
      String errorText;
      switch (e.type) {
        case EncryptionKeyType.none:
          errorText = translate('invite_dialog.invalid_invitation');
        case EncryptionKeyType.pin:
          errorText = translate('invite_dialog.invalid_pin');
        case EncryptionKeyType.password:
          errorText = translate('invite_dialog.invalid_password');
      }
      if (context.mounted) {
        showErrorToast(context, errorText);
      }
      setState(() {
        _isValidating = false;
        _validInvitation = null;
        widget.onValidationFailed();
      });
    } on Exception catch (e) {
      log.debug('exception: $e', e);
      setState(() {
        _isValidating = false;
        _validInvitation = null;
        widget.onValidationFailed();
      });
      rethrow;
    }
  }

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    // final scale = theme.extension<ScaleScheme>()!;
    // final textTheme = theme.textTheme;
    // final height = MediaQuery.of(context).size.height;

    if (_isAccepting) {
      return SizedBox(
              height: 300,
              width: 300,
              child: buildProgressIndicator(context).toCenter())
          .paddingAll(16);
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 400, maxWidth: 400),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              widget.buildInviteControl(context, this, _validateInviteData),
              if (_isValidating)
                Column(children: [
                  Text(translate('invite_dialog.validating'))
                      .paddingLTRB(0, 0, 0, 16),
                  buildProgressIndicator(context).paddingAll(16),
                ]).toCenter(),
              if (_validInvitation == null &&
                  !_isValidating &&
                  widget.inviteControlIsValid())
                Column(children: [
                  Text(translate('invite_dialog.invalid_invitation')),
                  const Icon(Icons.error)
                ]).paddingAll(16).toCenter(),
              if (_validInvitation != null && !_isValidating)
                Column(children: [
                  Container(
                      constraints: const BoxConstraints(maxHeight: 64),
                      width: double.infinity,
                      child: ProfileWidget(
                        name: _validInvitation!
                            .contactRequestPrivate.profile.name,
                        pronouns: _validInvitation!
                            .contactRequestPrivate.profile.pronouns,
                      )).paddingLTRB(0, 0, 0, 8),
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
            ]),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<bool>('isValidating', isValidating))
      ..add(DiagnosticsProperty<bool>('isAccepting', isAccepting));
  }
}
