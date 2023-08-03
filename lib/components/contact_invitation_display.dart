import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../tools/tools.dart';

class ContactInvitationDisplayDialog extends ConsumerStatefulWidget {
  const ContactInvitationDisplayDialog({
    super.key,
  });

  // EncryptionKeyType _encryptionKeyType = EncryptionKeyType.none;
  // _encryptionKey = '';

  @override
  ContactInvitationDisplayDialogState createState() =>
      ContactInvitationDisplayDialogState();
}

class ContactInvitationDisplayDialogState
    extends ConsumerState<ContactInvitationDisplayDialog> {
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  Future<void>? _generateFuture;

  @override
  void initState() {
    super.initState();
    if (_generateFuture == null) {
      _generateFuture = _generate();
    }
  }

  Future<void> _generate() async {
    // Generate invitation

    setState(() {
      _generateFuture = null;
    });
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

    final cardsize = MediaQuery.of(context).size.shortestSide - 24;
    //

    return Dialog(
        backgroundColor: Colors.white,
        child: SizedBox(
            width: cardsize,
            height: cardsize,
            child: Form(
                    key: formKey,
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Text("Contact Invitation")]))
                .withModalHUD(context, _generateFuture != null)));
  }
}
