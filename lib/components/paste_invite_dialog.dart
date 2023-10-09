import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../tools/tools.dart';
import '../veilid_support/veilid_support.dart';
import 'invite_dialog.dart';

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

  @override
  void initState() {
    super.initState();
  }

  Future<void> _onPasteChanged(
      String text,
      Future<void> Function({
        required Uint8List inviteData,
      }) validateInviteData) async {
    final lines = text.split('\n');
    if (lines.isEmpty) {
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
      return;
    }
    final inviteDataBase64 = lines
        .sublist(firstline, lastline)
        .join()
        .replaceAll(RegExp(r'[^A-Za-z0-9\-_]'), '');
    final inviteData = base64UrlNoPadDecode(inviteDataBase64);

    await validateInviteData(inviteData: inviteData);
  }

  void onValidationCancelled() {
    _pasteTextController.clear();
  }

  void onValidationSuccess() {
    //_pasteTextController.clear();
  }

  void onValidationFailed() {
    _pasteTextController.clear();
  }

  bool inviteControlIsValid() => _pasteTextController.text.isNotEmpty;

  Widget buildInviteControl(
      BuildContext context,
      InviteDialogState dialogState,
      Future<void> Function({required Uint8List inviteData})
          validateInviteData) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;
    //final textTheme = theme.textTheme;
    //final height = MediaQuery.of(context).size.height;

    final monoStyle = TextStyle(
      fontFamily: 'Source Code Pro',
      fontSize: 11,
      color: scale.primaryScale.text,
    );

    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text(
        translate('paste_invite_dialog.paste_invite_here'),
      ).paddingLTRB(0, 0, 0, 8),
      Container(
          constraints: const BoxConstraints(maxHeight: 200),
          child: TextField(
            enabled: !dialogState.isValidating,
            onChanged: (text) async =>
                _onPasteChanged(text, validateInviteData),
            style: monoStyle,
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
          )).paddingLTRB(0, 0, 0, 8)
    ]);
  }

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    return InviteDialog(
        onValidationCancelled: onValidationCancelled,
        onValidationSuccess: onValidationSuccess,
        onValidationFailed: onValidationFailed,
        inviteControlIsValid: inviteControlIsValid,
        buildInviteControl: buildInviteControl);
  }
}
