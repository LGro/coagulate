import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_translate/flutter_translate.dart';
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
    title: Text(translate('toast.error')),
    description: Text(message),
  ).show(context);
}

void showInfoToast(BuildContext context, String message) {
  MotionToast.info(
    title: Text(translate('toast.info')),
    description: Text(message),
  ).show(context);
}

Widget styledTitleContainer(
    {required BuildContext context,
    required String title,
    required Widget child}) {
  final theme = Theme.of(context);
  final scale = theme.extension<ScaleScheme>()!;
  final textTheme = theme.textTheme;

  return Container(
      decoration: ShapeDecoration(
          color: scale.primaryScale.subtleBorder,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          )),
      child: Column(children: [
        Text(
          title,
          style: textTheme.titleMedium!
              .copyWith(color: scale.primaryScale.subtleText),
        ).paddingLTRB(4, 4, 4, 0),
        DecoratedBox(
                decoration: ShapeDecoration(
                    color: scale.primaryScale.subtleBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    )),
                child: child)
            .paddingAll(4)
            .expanded()
      ]));
}

Future<T?> showStyledDialog<T>(
    {required BuildContext context,
    required String title,
    required Widget child}) async {
  final theme = Theme.of(context);
  final scale = theme.extension<ScaleScheme>()!;
  final textTheme = theme.textTheme;

  return showDialog<T>(
      context: context,
      builder: (context) => AlertDialog(
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          contentPadding: const EdgeInsets.all(4),
          backgroundColor: scale.primaryScale.border,
          title: Text(
            title,
            style: textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          titlePadding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
          content: DecoratedBox(
              decoration: ShapeDecoration(
                  color: scale.primaryScale.border,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16))),
              child: DecoratedBox(
                  decoration: ShapeDecoration(
                      color: scale.primaryScale.subtleBackground,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: child.paddingAll(0)))));
}
