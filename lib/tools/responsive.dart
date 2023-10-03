import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

bool get isAndroid => !kIsWeb && Platform.isAndroid;
bool get isiOS => !kIsWeb && Platform.isIOS;
bool get isWeb => kIsWeb;
bool get isDesktop =>
    !isWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

const kMobileWidthCutoff = 479.0;

bool isMobileWidth(BuildContext context) =>
    MediaQuery.of(context).size.width < kMobileWidthCutoff;

bool responsiveVisibility({
  required BuildContext context,
  bool phone = true,
  bool tablet = true,
  bool tabletLandscape = true,
  bool desktop = true,
}) {
  final width = MediaQuery.of(context).size.width;
  if (width < kMobileWidthCutoff) {
    return phone;
  } else if (width < 767) {
    return tablet;
  } else if (width < 991) {
    return tabletLandscape;
  } else {
    return desktop;
  }
}
