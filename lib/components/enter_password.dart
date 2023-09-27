import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../tools/tools.dart';

class EnterPasswordDialog extends ConsumerStatefulWidget {
  const EnterPasswordDialog({
    this.matchPass,
    this.description,
    super.key,
  });

  final String? matchPass;
  final String? description;

  @override
  EnterPasswordDialogState createState() => EnterPasswordDialogState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('reenter', matchPass))
      ..add(StringProperty('description', description));
  }
}

class EnterPasswordDialogState extends ConsumerState<EnterPasswordDialog> {
  final passwordController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    passwordController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;

    return Dialog(
        backgroundColor: scale.grayScale.subtleBackground,
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.matchPass == null
                    ? translate('enter_password_dialog.enter_password')
                    : translate('enter_password_dialog.reenter_password'),
                style: theme.textTheme.titleLarge,
              ).paddingAll(16),
              TextField(
                  controller: passwordController,
                  focusNode: focusNode,
                  autofocus: true,
                  enableSuggestions: false,
                  obscureText:
                      !_passwordVisible, //This will obscure text dynamically
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.singleLineFormatter
                  ],
                  onSubmitted: (password) {
                    Navigator.pop(context, password);
                  },
                  onChanged: (_) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    prefixIcon: widget.matchPass == null
                        ? null
                        : Icon(Icons.check_circle,
                            color: passwordController.text == widget.matchPass
                                ? scale.primaryScale.background
                                : scale.grayScale.subtleBackground),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: scale.primaryScale.text,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  )).paddingAll(16),
              if (widget.description != null)
                SizedBox(
                    width: 400,
                    child: Text(
                      widget.description!,
                      textAlign: TextAlign.center,
                    ).paddingAll(16))
            ],
          ),
        ));
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<TextEditingController>(
          'passwordController', passwordController))
      ..add(DiagnosticsProperty<FocusNode>('focusNode', focusNode))
      ..add(DiagnosticsProperty<GlobalKey<FormState>>('formKey', formKey));
  }
}
