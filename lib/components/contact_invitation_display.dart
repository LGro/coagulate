import 'dart:async';
import 'dart:math';

import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../tools/tools.dart';
import '../veilid_support/veilid_support.dart';

class ContactInvitationDisplayDialog extends ConsumerStatefulWidget {
  const ContactInvitationDisplayDialog({
    required this.name,
    required this.message,
    required this.generator,
    super.key,
  });

  final String name;
  final String message;
  final FutureOr<Uint8List> generator;

  @override
  ContactInvitationDisplayDialogState createState() =>
      ContactInvitationDisplayDialogState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('name', name))
      ..add(StringProperty('message', message))
      ..add(DiagnosticsProperty<FutureOr<Uint8List>?>('generator', generator));
  }
}

class ContactInvitationDisplayDialogState
    extends ConsumerState<ContactInvitationDisplayDialog> {
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  late final AutoDisposeFutureProvider<Uint8List?> _generateFutureProvider;

  @override
  void initState() {
    super.initState();

    _generateFutureProvider =
        AutoDisposeFutureProvider<Uint8List>((ref) async => widget.generator);
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  String makeTextInvite(String message, Uint8List data) {
    final invite = StringUtils.addCharAtPosition(
        base64UrlNoPadEncode(data), '\n', 40,
        repeat: true);
    final msg = message.isNotEmpty ? '$message\n' : '';
    return '$msg'
        '--- BEGIN VEILIDCHAT CONTACT INVITE ----\n'
        '$invite\n'
        '---- END VEILIDCHAT CONTACT INVITE -----\n';
  }

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    //final scale = theme.extension<ScaleScheme>()!;
    final textTheme = theme.textTheme;

    final signedContactInvitationBytesV = ref.watch(_generateFutureProvider);
    final cardsize =
        min<double>(MediaQuery.of(context).size.shortestSide - 48.0, 400);

    return Dialog(
        backgroundColor: Colors.white,
        child: ConstrainedBox(
            constraints: BoxConstraints(
                minWidth: cardsize,
                maxWidth: cardsize,
                minHeight: cardsize,
                maxHeight: cardsize),
            child: signedContactInvitationBytesV.when(
                loading: () => buildProgressIndicator(context),
                data: (data) {
                  if (data == null) {
                    Navigator.of(context).pop();
                    return const Text('');
                  }
                  return Form(
                      key: formKey,
                      child: Column(children: [
                        FittedBox(
                                child: Text(
                                    translate(
                                        'send_invite_dialog.contact_invitation'),
                                    style: textTheme.headlineSmall!
                                        .copyWith(color: Colors.black)))
                            .paddingAll(8),
                        FittedBox(
                                child: QrImageView.withQr(
                                    size: 300,
                                    qr: QrCode.fromUint8List(
                                        data: data,
                                        errorCorrectLevel:
                                            QrErrorCorrectLevel.L)))
                            .expanded(),
                        Text(widget.message,
                                softWrap: true,
                                style: textTheme.labelLarge!
                                    .copyWith(color: Colors.black))
                            .paddingAll(8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.copy),
                          label: Text(
                              translate('send_invite_dialog.copy_invitation')),
                          onPressed: () async {
                            showInfoToast(
                                context,
                                translate(
                                    'send_invite_dialog.invitation_copied'));
                            await Clipboard.setData(ClipboardData(
                                text: makeTextInvite(widget.message, data)));
                          },
                        ).paddingAll(16),
                      ]));
                },
                error: (e, s) {
                  Navigator.of(context).pop();
                  showErrorToast(context,
                      translate('send_invite_dialog.failed_to_generate'));
                  return const Text('');
                })));
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<FocusNode>('focusNode', focusNode))
      ..add(DiagnosticsProperty<GlobalKey<FormState>>('formKey', formKey));
  }
}
