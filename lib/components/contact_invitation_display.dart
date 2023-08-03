import 'dart:async';
import 'dart:ffi';

import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../tools/tools.dart';

class ContactInvitationDisplayDialog extends ConsumerStatefulWidget {
  const ContactInvitationDisplayDialog({
    required this.name,
    required this.message,
    required this.generator,
    super.key,
  });

  final String name;
  final String message;
  final Future<Uint8List> generator;

  @override
  ContactInvitationDisplayDialogState createState() =>
      ContactInvitationDisplayDialogState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('name', name))
      ..add(StringProperty('message', message))
      ..add(DiagnosticsProperty<Future<Uint8List>?>('generator', generator));
  }
}

class ContactInvitationDisplayDialogState
    extends ConsumerState<ContactInvitationDisplayDialog> {
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  late final FutureProvider<Uint8List?> _generateFutureProvider;

  @override
  void initState() {
    super.initState();

    _generateFutureProvider =
        FutureProvider<Uint8List>((ref) async => widget.generator);
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;
    final signedContactInvitationBytesV = ref.watch(_generateFutureProvider);
    final cardsize = MediaQuery.of(context).size.shortestSide - 24;

    return Dialog(
        backgroundColor: Colors.white,
        child: SizedBox(
            width: cardsize,
            height: cardsize,
            child: signedContactInvitationBytesV.when(
                loading: () => waitingPage(context),
                data: (data) => Form(
                    key: formKey,
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Text("Contact Invitation")])),
                error: (e, s) {
                  Navigator.of(context).pop();
                  showErrorToast(
                      context, "Failed to generate contact invitation: $e");
                  return Text("");
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
