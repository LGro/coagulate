import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:quickalert/quickalert.dart';

extension BorderExt on Widget {
  DecoratedBox debugBorder() => DecoratedBox(
      decoration: BoxDecoration(border: Border.all(color: Colors.redAccent)),
      child: this);
}

extension ModalProgressExt on Widget {
  BlurryModalProgressHUD withModalHUD(BuildContext context, bool isLoading) =>
      BlurryModalProgressHUD(
          inAsyncCall: isLoading,
          blurEffectIntensity: 4,
          progressIndicator: buildProgressIndicator(context),
          color: Theme.of(context).shadowColor,
          child: this);
}

Widget buildProgressIndicator(BuildContext context) => SpinKitFoldingCube(
      color: Theme.of(context).highlightColor,
      size: 90,
    );

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
