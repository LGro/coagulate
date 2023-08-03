import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:quickalert/quickalert.dart';

import 'theme_service.dart';

extension BorderExt on Widget {
  DecoratedBox debugBorder() => DecoratedBox(
      decoration: BoxDecoration(border: Border.all(color: Colors.redAccent)),
      child: this);
}

extension ModalProgressExt on Widget {
  BlurryModalProgressHUD withModalHUD(BuildContext context, bool isLoading) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;

    return BlurryModalProgressHUD(
        inAsyncCall: isLoading,
        blurEffectIntensity: 4,
        progressIndicator: buildProgressIndicator(context),
        color: scale.tertiaryScale.appBackground.withAlpha(64),
        child: this);
  }
}

Widget buildProgressIndicator(BuildContext context) {
  final theme = Theme.of(context);
  final scale = theme.extension<ScaleScheme>()!;
  return SpinKitFoldingCube(
    color: scale.tertiaryScale.background,
    size: 80,
  );
}

Widget waitingPage(BuildContext context) => ColoredBox(
    color: Theme.of(context).scaffoldBackgroundColor,
    child: Center(child: buildProgressIndicator(context)));

Future<void> showErrorModal(
    BuildContext context, String title, String text) async {
  await QuickAlert.show(
    context: context,
    type: QuickAlertType.error,
    title: title,
    text: text,
    //backgroundColor: Colors.black,
    //titleColor: Colors.white,
    //textColor: Colors.white,
  );
}

void showErrorToast(BuildContext context, String message) {
  MotionToast.error(
    title: Text("Error"),
    description: Text(message),
  ).show(context);
}
