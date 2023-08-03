import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:radix_colors/radix_colors.dart';

import 'theme_service.dart';

enum RadixThemeColor {
  scarlet, // tomato + red + violet
  babydoll, // crimson + purple + pink
  vapor, // pink + cyan + plum
  gold, // yellow + amber + orange
  garden, // grass + orange + brown
  forest, // green + brown + amber
  arctic, // sky + teal + violet
  lapis, // blue + indigo + mint
  eggplant, // violet + purple + indigo
  lime, // lime + yellow + orange
  grim, // mauve + slate + sage
}

enum _RadixBaseColor {
  tomato,
  red,
  crimson,
  pink,
  plum,
  purple,
  violet,
  indigo,
  blue,
  sky,
  cyan,
  teal,
  mint,
  green,
  grass,
  lime,
  yellow,
  amber,
  orange,
  brown,
}

RadixColor _radixGraySteps(
    Brightness brightness, bool alpha, _RadixBaseColor baseColor) {
  switch (baseColor) {
    case _RadixBaseColor.tomato:
    case _RadixBaseColor.red:
    case _RadixBaseColor.crimson:
    case _RadixBaseColor.pink:
    case _RadixBaseColor.plum:
    case _RadixBaseColor.purple:
    case _RadixBaseColor.violet:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.mauveA
              : RadixColors.mauveA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.mauve
              : RadixColors.mauve);
    case _RadixBaseColor.indigo:
    case _RadixBaseColor.blue:
    case _RadixBaseColor.sky:
    case _RadixBaseColor.cyan:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.slateA
              : RadixColors.slateA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.slate
              : RadixColors.slate);
    case _RadixBaseColor.teal:
    case _RadixBaseColor.mint:
    case _RadixBaseColor.green:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.sageA
              : RadixColors.sageA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.sage
              : RadixColors.sage);
    case _RadixBaseColor.lime:
    case _RadixBaseColor.grass:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.oliveA
              : RadixColors.oliveA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.olive
              : RadixColors.olive);
    case _RadixBaseColor.yellow:
    case _RadixBaseColor.amber:
    case _RadixBaseColor.orange:
    case _RadixBaseColor.brown:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.sandA
              : RadixColors.sandA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.sand
              : RadixColors.sand);
  }
}

RadixColor _radixColorSteps(
    Brightness brightness, bool alpha, _RadixBaseColor baseColor) {
  switch (baseColor) {
    case _RadixBaseColor.tomato:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.tomatoA
              : RadixColors.tomatoA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.tomato
              : RadixColors.tomato);
    case _RadixBaseColor.red:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.redA
              : RadixColors.redA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.red
              : RadixColors.red);
    case _RadixBaseColor.crimson:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.crimsonA
              : RadixColors.crimsonA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.crimson
              : RadixColors.crimson);
    case _RadixBaseColor.pink:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.pinkA
              : RadixColors.pinkA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.pink
              : RadixColors.pink);
    case _RadixBaseColor.plum:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.plumA
              : RadixColors.plumA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.plum
              : RadixColors.plum);
    case _RadixBaseColor.purple:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.purpleA
              : RadixColors.purpleA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.purple
              : RadixColors.purple);
    case _RadixBaseColor.violet:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.violetA
              : RadixColors.violetA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.violet
              : RadixColors.violet);
    case _RadixBaseColor.indigo:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.indigoA
              : RadixColors.indigoA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.indigo
              : RadixColors.indigo);
    case _RadixBaseColor.blue:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.blueA
              : RadixColors.blueA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.blue
              : RadixColors.blue);
    case _RadixBaseColor.sky:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.skyA
              : RadixColors.skyA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.sky
              : RadixColors.sky);
    case _RadixBaseColor.cyan:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.cyanA
              : RadixColors.cyanA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.cyan
              : RadixColors.cyan);
    case _RadixBaseColor.teal:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.tealA
              : RadixColors.tealA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.teal
              : RadixColors.teal);
    case _RadixBaseColor.mint:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.mintA
              : RadixColors.mintA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.mint
              : RadixColors.mint);
    case _RadixBaseColor.green:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.greenA
              : RadixColors.greenA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.green
              : RadixColors.green);
    case _RadixBaseColor.grass:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.grassA
              : RadixColors.grassA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.grass
              : RadixColors.grass);
    case _RadixBaseColor.lime:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.limeA
              : RadixColors.limeA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.lime
              : RadixColors.lime);
    case _RadixBaseColor.yellow:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.yellowA
              : RadixColors.yellowA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.yellow
              : RadixColors.yellow);
    case _RadixBaseColor.amber:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.amberA
              : RadixColors.amberA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.amber
              : RadixColors.amber);
    case _RadixBaseColor.orange:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.orangeA
              : RadixColors.orangeA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.orange
              : RadixColors.orange);
    case _RadixBaseColor.brown:
      return alpha
          ? (brightness == Brightness.dark
              ? RadixColors.dark.brownA
              : RadixColors.brownA)
          : (brightness == Brightness.dark
              ? RadixColors.dark.brown
              : RadixColors.brown);
  }
}

extension ToScaleColor on RadixColor {
  ScaleColor toScale() => ScaleColor(
        appBackground: step1,
        subtleBackground: step2,
        elementBackground: step3,
        hoverElementBackground: step4,
        activedElementBackground: step5,
        subtleBorder: step6,
        border: step7,
        hoverBorder: step8,
        background: step9,
        hoverBackground: step10,
        subtleText: step11,
        text: step12,
      );
}

class RadixScheme {
  RadixScheme(
      {required this.primaryScale,
      required this.primaryAlphaScale,
      required this.secondaryScale,
      required this.tertiaryScale,
      required this.grayScale,
      required this.errorScale});

  RadixColor primaryScale;
  RadixColor primaryAlphaScale;
  RadixColor secondaryScale;
  RadixColor tertiaryScale;
  RadixColor grayScale;
  RadixColor errorScale;

  ScaleScheme toScale() => ScaleScheme(
        primaryScale: primaryScale.toScale(),
        primaryAlphaScale: primaryAlphaScale.toScale(),
        secondaryScale: secondaryScale.toScale(),
        tertiaryScale: tertiaryScale.toScale(),
        grayScale: grayScale.toScale(),
        errorScale: errorScale.toScale(),
      );
}

RadixScheme _radixScheme(Brightness brightness, RadixThemeColor themeColor) {
  late RadixScheme radixScheme;
  switch (themeColor) {
    // tomato + red + violet
    case RadixThemeColor.scarlet:
      radixScheme = RadixScheme(
          primaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.tomato),
          primaryAlphaScale:
              _radixColorSteps(brightness, true, _RadixBaseColor.tomato),
          secondaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.red),
          tertiaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.violet),
          grayScale: _radixGraySteps(brightness, false, _RadixBaseColor.tomato),
          errorScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.yellow));

    // crimson + purple + pink
    case RadixThemeColor.babydoll:
      radixScheme = RadixScheme(
          primaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.crimson),
          primaryAlphaScale:
              _radixColorSteps(brightness, true, _RadixBaseColor.crimson),
          secondaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.purple),
          tertiaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.pink),
          grayScale:
              _radixGraySteps(brightness, false, _RadixBaseColor.crimson),
          errorScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.orange));
    // pink + cyan + plum
    case RadixThemeColor.vapor:
      radixScheme = RadixScheme(
          primaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.pink),
          primaryAlphaScale:
              _radixColorSteps(brightness, true, _RadixBaseColor.pink),
          secondaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.cyan),
          tertiaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.plum),
          grayScale: _radixGraySteps(brightness, false, _RadixBaseColor.pink),
          errorScale: _radixColorSteps(brightness, false, _RadixBaseColor.red));
    // yellow + amber + orange
    case RadixThemeColor.gold:
      radixScheme = RadixScheme(
          primaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.yellow),
          primaryAlphaScale:
              _radixColorSteps(brightness, true, _RadixBaseColor.yellow),
          secondaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.amber),
          tertiaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.orange),
          grayScale: _radixGraySteps(brightness, false, _RadixBaseColor.yellow),
          errorScale: _radixColorSteps(brightness, false, _RadixBaseColor.red));
    // grass + orange + brown
    case RadixThemeColor.garden:
      radixScheme = RadixScheme(
          primaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.grass),
          primaryAlphaScale:
              _radixColorSteps(brightness, true, _RadixBaseColor.grass),
          secondaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.orange),
          tertiaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.brown),
          grayScale: _radixGraySteps(brightness, false, _RadixBaseColor.grass),
          errorScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.tomato));
    // green + brown + amber
    case RadixThemeColor.forest:
      radixScheme = RadixScheme(
          primaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.green),
          primaryAlphaScale:
              _radixColorSteps(brightness, true, _RadixBaseColor.green),
          secondaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.brown),
          tertiaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.amber),
          grayScale: _radixGraySteps(brightness, false, _RadixBaseColor.green),
          errorScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.tomato));
    // sky + teal + violet
    case RadixThemeColor.arctic:
      radixScheme = RadixScheme(
          primaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.sky),
          primaryAlphaScale:
              _radixColorSteps(brightness, true, _RadixBaseColor.sky),
          secondaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.teal),
          tertiaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.violet),
          grayScale: _radixGraySteps(brightness, false, _RadixBaseColor.sky),
          errorScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.crimson));
    // blue + indigo + mint
    case RadixThemeColor.lapis:
      radixScheme = RadixScheme(
          primaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.blue),
          primaryAlphaScale:
              _radixColorSteps(brightness, true, _RadixBaseColor.blue),
          secondaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.indigo),
          tertiaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.mint),
          grayScale: _radixGraySteps(brightness, false, _RadixBaseColor.blue),
          errorScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.crimson));
    // violet + purple + indigo
    case RadixThemeColor.eggplant:
      radixScheme = RadixScheme(
          primaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.violet),
          primaryAlphaScale:
              _radixColorSteps(brightness, true, _RadixBaseColor.violet),
          secondaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.purple),
          tertiaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.indigo),
          grayScale: _radixGraySteps(brightness, false, _RadixBaseColor.violet),
          errorScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.crimson));
    // lime + yellow + orange
    case RadixThemeColor.lime:
      radixScheme = RadixScheme(
          primaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.lime),
          primaryAlphaScale:
              _radixColorSteps(brightness, true, _RadixBaseColor.lime),
          secondaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.yellow),
          tertiaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.orange),
          grayScale: _radixGraySteps(brightness, false, _RadixBaseColor.lime),
          errorScale: _radixColorSteps(brightness, false, _RadixBaseColor.red));
    // mauve + slate + sage
    case RadixThemeColor.grim:
      radixScheme = RadixScheme(
          primaryScale:
              _radixGraySteps(brightness, false, _RadixBaseColor.tomato),
          primaryAlphaScale:
              _radixColorSteps(brightness, true, _RadixBaseColor.tomato),
          secondaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.indigo),
          tertiaryScale:
              _radixColorSteps(brightness, false, _RadixBaseColor.teal),
          grayScale: brightness == Brightness.dark
              ? RadixColors.dark.gray
              : RadixColors.gray,
          errorScale: _radixColorSteps(brightness, false, _RadixBaseColor.red));
  }
  return radixScheme;
}

ColorScheme _radixColorScheme(Brightness brightness, RadixScheme radix) =>
    ColorScheme(
      brightness: brightness,
      primary: radix.primaryScale.step9,
      onPrimary: radix.primaryScale.step12,
      primaryContainer: radix.primaryScale.step4,
      onPrimaryContainer: radix.primaryScale.step11,
      secondary: radix.secondaryScale.step9,
      onSecondary: radix.secondaryScale.step12,
      secondaryContainer: radix.secondaryScale.step3,
      onSecondaryContainer: radix.secondaryScale.step11,
      tertiary: radix.tertiaryScale.step9,
      onTertiary: radix.tertiaryScale.step12,
      tertiaryContainer: radix.tertiaryScale.step3,
      onTertiaryContainer: radix.tertiaryScale.step11,
      error: radix.errorScale.step9,
      onError: radix.errorScale.step12,
      errorContainer: radix.errorScale.step3,
      onErrorContainer: radix.errorScale.step11,
      background: radix.grayScale.step1,
      onBackground: radix.grayScale.step11,
      surface: radix.primaryScale.step1,
      onSurface: radix.primaryScale.step12,
      surfaceVariant: radix.secondaryScale.step2,
      onSurfaceVariant: radix.secondaryScale.step11,
      outline: radix.primaryScale.step7,
      outlineVariant: radix.primaryScale.step6,
      shadow: RadixColors.dark.gray.step1,
      scrim: radix.primaryScale.step9,
      inverseSurface: radix.primaryScale.step11,
      onInverseSurface: radix.primaryScale.step2,
      inversePrimary: radix.primaryScale.step10,
      surfaceTint: radix.primaryAlphaScale.step4,
    );

ThemeData radixGenerator(Brightness brightness, RadixThemeColor themeColor) {
  TextTheme? textTheme;
  final radix = _radixScheme(brightness, themeColor);
  final colorScheme = _radixColorScheme(brightness, radix);
  return ThemeData.from(
          colorScheme: colorScheme, textTheme: textTheme, useMaterial3: true)
      .copyWith(extensions: <ThemeExtension<dynamic>>[
    radix.toScale(),
  ]);
}
