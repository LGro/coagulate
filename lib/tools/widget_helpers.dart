import 'package:flutter/material.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

extension BorderExt on Widget {
  Container debugBorder() {
    return Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.redAccent)),
        child: this);
  }
}

extension ModalProgressExt on Widget {
  BlurryModalProgressHUD withModalHUD(BuildContext context, bool isLoading) {
    return BlurryModalProgressHUD(
        inAsyncCall: isLoading,
        blurEffectIntensity: 4,
        progressIndicator: SpinKitFoldingCube(
          color: Theme.of(context).highlightColor,
          size: 90.0,
        ),
        dismissible: false,
        opacity: 0.3,
        color: Theme.of(context).shadowColor,
        child: this);
  }
}
