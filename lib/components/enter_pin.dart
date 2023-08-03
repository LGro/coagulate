import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:pinput/pinput.dart';

import '../tools/tools.dart';

class EnterPinDialog extends ConsumerStatefulWidget {
  const EnterPinDialog({
    this.matchPin,
    this.description,
    super.key,
  });

  final String? matchPin;
  final String? description;

  @override
  EnterPinDialogState createState() => EnterPinDialogState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('matchPin', matchPin))
      ..add(StringProperty('description', description));
  }
}

class EnterPinDialogState extends ConsumerState<EnterPinDialog> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;
    final focusedBorderColor = scale.primaryScale.hoverBorder;
    final fillColor = scale.primaryScale.elementBackground;
    final borderColor = scale.primaryScale.border;

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: TextStyle(fontSize: 22, color: scale.primaryScale.text),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
    );

    /// Optionally you can use form to validate the Pinput
    return Dialog(
        backgroundColor: scale.grayScale.subtleBackground,
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.matchPin == null
                    ? translate('enter_pin_dialog.enter_pin')
                    : translate('enter_pin_dialog.reenter_pin'),
                style: theme.textTheme.titleLarge,
              ).paddingAll(16),
              Directionality(
                // Specify direction if desired
                textDirection: TextDirection.ltr,
                child: Pinput(
                  controller: pinController,
                  focusNode: focusNode,
                  autofocus: true,
                  defaultPinTheme: defaultPinTheme,
                  enableSuggestions: false,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  // validator: (widget.matchPin != null)
                  //     ? (value) => value == widget.matchPin
                  //         ? null
                  //         : translate('enter_pin_dialog.pin_does_not_match')
                  //     : null,
                  // onClipboardFound: (value) {
                  //   debugPrint('onClipboardFound: $value');
                  //   pinController.setText(value);
                  // },
                  hapticFeedbackType: HapticFeedbackType.lightImpact,
                  onCompleted: (pin) {
                    debugPrint('onCompleted: $pin');
                    Navigator.pop(context, pin);
                  },
                  onChanged: (value) {
                    debugPrint('onChanged: $value');
                  },
                  cursor: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 9),
                        width: 22,
                        height: 1,
                        color: focusedBorderColor,
                      ),
                    ],
                  ),
                  focusedPinTheme: defaultPinTheme.copyWith(
                    height: 68,
                    width: 64,
                    decoration: defaultPinTheme.decoration!.copyWith(
                      border: Border.all(color: borderColor),
                    ),
                  ),
                  errorText: '',
                  errorPinTheme: defaultPinTheme.copyWith(
                    decoration: BoxDecoration(
                      color: scale.errorScale.border,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ).paddingAll(16),
              ),
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
          'pinController', pinController))
      ..add(DiagnosticsProperty<FocusNode>('focusNode', focusNode))
      ..add(DiagnosticsProperty<GlobalKey<FormState>>('formKey', formKey));
  }
}
