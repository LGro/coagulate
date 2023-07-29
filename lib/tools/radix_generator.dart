import 'package:flutter/material.dart';
import 'package:radix_colors/radix_colors.dart';

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

ColorScheme _radixColorScheme(
// ignore: prefer_expression_function_bodies
    Brightness brightness,
    RadixThemeColor themeColor) {
  late RadixColor primaryScale;
  late RadixColor primaryAlphaScale;
  late RadixColor secondaryScale;
  late RadixColor tertiaryScale;
  late RadixColor grayScale;
  late RadixColor errorScale;

  switch (themeColor) {
    // tomato + red + violet
    case RadixThemeColor.scarlet:
      primaryScale =
          _radixColorSteps(brightness, false, _RadixBaseColor.tomato);
      primaryAlphaScale =
          _radixColorSteps(brightness, true, _RadixBaseColor.tomato);
      secondaryScale = _radixColorSteps(brightness, false, _RadixBaseColor.red);
      tertiaryScale =
          _radixColorSteps(brightness, false, _RadixBaseColor.violet);
      grayScale = _radixGraySteps(brightness, false, _RadixBaseColor.tomato);
      errorScale = _radixColorSteps(brightness, false, _RadixBaseColor.yellow);
    // crimson + purple + pink
    case RadixThemeColor.babydoll:
      primaryScale =
          _radixColorSteps(brightness, false, _RadixBaseColor.crimson);
      primaryAlphaScale =
          _radixColorSteps(brightness, true, _RadixBaseColor.crimson);
      secondaryScale =
          _radixColorSteps(brightness, false, _RadixBaseColor.purple);
      tertiaryScale = _radixColorSteps(brightness, false, _RadixBaseColor.pink);
      grayScale = _radixGraySteps(brightness, false, _RadixBaseColor.crimson);
      errorScale = _radixColorSteps(brightness, false, _RadixBaseColor.orange);
    // pink + cyan + plum
    case RadixThemeColor.vapor:
      primaryScale = _radixColorSteps(brightness, false, _RadixBaseColor.pink);
      primaryAlphaScale =
          _radixColorSteps(brightness, true, _RadixBaseColor.pink);
      secondaryScale =
          _radixColorSteps(brightness, false, _RadixBaseColor.cyan);
      tertiaryScale = _radixColorSteps(brightness, false, _RadixBaseColor.plum);
      grayScale = _radixGraySteps(brightness, false, _RadixBaseColor.pink);
      errorScale = _radixColorSteps(brightness, false, _RadixBaseColor.red);
    // yellow + amber + orange
    case RadixThemeColor.gold:
      primaryScale =
          _radixColorSteps(brightness, false, _RadixBaseColor.yellow);
      primaryAlphaScale =
          _radixColorSteps(brightness, true, _RadixBaseColor.yellow);
      secondaryScale =
          _radixColorSteps(brightness, false, _RadixBaseColor.amber);
      tertiaryScale =
          _radixColorSteps(brightness, false, _RadixBaseColor.orange);
      grayScale = _radixGraySteps(brightness, false, _RadixBaseColor.yellow);
      errorScale = _radixColorSteps(brightness, false, _RadixBaseColor.red);
    // grass + orange + brown
    case RadixThemeColor.garden:
      primaryScale = _radixColorSteps(brightness, false, _RadixBaseColor.grass);
      primaryAlphaScale =
          _radixColorSteps(brightness, true, _RadixBaseColor.grass);
      secondaryScale =
          _radixColorSteps(brightness, false, _RadixBaseColor.orange);
      tertiaryScale =
          _radixColorSteps(brightness, false, _RadixBaseColor.brown);
      grayScale = _radixGraySteps(brightness, false, _RadixBaseColor.grass);
      errorScale = _radixColorSteps(brightness, false, _RadixBaseColor.tomato);
    // green + brown + amber
    case RadixThemeColor.forest:
      primaryScale = _radixColorSteps(brightness, false, _RadixBaseColor.green);
      primaryAlphaScale =
          _radixColorSteps(brightness, true, _RadixBaseColor.green);
      secondaryScale =
          _radixColorSteps(brightness, false, _RadixBaseColor.brown);
      tertiaryScale =
          _radixColorSteps(brightness, false, _RadixBaseColor.amber);
      grayScale = _radixGraySteps(brightness, false, _RadixBaseColor.green);
      errorScale = _radixColorSteps(brightness, false, _RadixBaseColor.tomato);
    // sky + teal + violet
    case RadixThemeColor.arctic:
      primaryScale = _radixColorSteps(brightness, false, _RadixBaseColor.sky);
      primaryAlphaScale =
          _radixColorSteps(brightness, true, _RadixBaseColor.sky);
      secondaryScale =
          _radixColorSteps(brightness, false, _RadixBaseColor.teal);
      tertiaryScale =
          _radixColorSteps(brightness, false, _RadixBaseColor.violet);
      grayScale = _radixGraySteps(brightness, false, _RadixBaseColor.sky);
      errorScale = _radixColorSteps(brightness, false, _RadixBaseColor.crimson);
    // blue + indigo + mint
    case RadixThemeColor.lapis:
      primaryScale = _radixColorSteps(brightness, false, _RadixBaseColor.blue);
      primaryAlphaScale =
          _radixColorSteps(brightness, true, _RadixBaseColor.blue);
      secondaryScale =
          _radixColorSteps(brightness, false, _RadixBaseColor.indigo);
      tertiaryScale = _radixColorSteps(brightness, false, _RadixBaseColor.mint);
      grayScale = _radixGraySteps(brightness, false, _RadixBaseColor.blue);
      errorScale = _radixColorSteps(brightness, false, _RadixBaseColor.crimson);
    // violet + purple + indigo
    case RadixThemeColor.eggplant:
      primaryScale =
          _radixColorSteps(brightness, false, _RadixBaseColor.violet);
      primaryAlphaScale =
          _radixColorSteps(brightness, true, _RadixBaseColor.violet);
      secondaryScale =
          _radixColorSteps(brightness, false, _RadixBaseColor.purple);
      tertiaryScale =
          _radixColorSteps(brightness, false, _RadixBaseColor.indigo);
      grayScale = _radixGraySteps(brightness, false, _RadixBaseColor.violet);
      errorScale = _radixColorSteps(brightness, false, _RadixBaseColor.crimson);
    // lime + yellow + orange
    case RadixThemeColor.lime:
      primaryScale = _radixColorSteps(brightness, false, _RadixBaseColor.lime);
      primaryAlphaScale =
          _radixColorSteps(brightness, true, _RadixBaseColor.lime);
      secondaryScale =
          _radixColorSteps(brightness, false, _RadixBaseColor.yellow);
      tertiaryScale =
          _radixColorSteps(brightness, false, _RadixBaseColor.orange);
      grayScale = _radixGraySteps(brightness, false, _RadixBaseColor.lime);
      errorScale = _radixColorSteps(brightness, false, _RadixBaseColor.red);
    // mauve + slate + sage
    case RadixThemeColor.grim:
      primaryScale = _radixGraySteps(brightness, false, _RadixBaseColor.tomato);
      primaryAlphaScale =
          _radixColorSteps(brightness, true, _RadixBaseColor.tomato);
      secondaryScale =
          _radixColorSteps(brightness, false, _RadixBaseColor.indigo);
      tertiaryScale = _radixColorSteps(brightness, false, _RadixBaseColor.teal);
      grayScale = brightness == Brightness.dark
          ? RadixColors.dark.gray
          : RadixColors.gray;
      errorScale = _radixColorSteps(brightness, false, _RadixBaseColor.red);
  }

  return ColorScheme(
    brightness: brightness,
    primary: primaryScale.step9,
    onPrimary: primaryScale.step12,
    primaryContainer: primaryScale.step3,
    onPrimaryContainer: primaryScale.step11,
    secondary: secondaryScale.step9,
    onSecondary: secondaryScale.step12,
    secondaryContainer: secondaryScale.step3,
    onSecondaryContainer: secondaryScale.step11,
    tertiary: tertiaryScale.step9,
    onTertiary: tertiaryScale.step12,
    tertiaryContainer: tertiaryScale.step3,
    onTertiaryContainer: tertiaryScale.step11,
    error: errorScale.step9,
    onError: errorScale.step12,
    errorContainer: errorScale.step3,
    onErrorContainer: errorScale.step11,
    background: primaryScale.step1, //gray scale?
    onBackground: primaryScale.step12,
    surface: primaryScale.step2, //gray scale?
    onSurface: primaryScale.step11,
    surfaceVariant: primaryScale.step3, //gray scale?
    onSurfaceVariant: primaryScale.step11,
    outline: primaryScale.step7,
    outlineVariant: primaryScale.step6,
    shadow: RadixColors.dark.gray.step1,
    scrim: primaryScale.step4,
    inverseSurface: primaryScale.step11,
    onInverseSurface: primaryScale.step2,
    inversePrimary: primaryScale.step10,
    surfaceTint: primaryAlphaScale.step9,
  );
}

ThemeData radixGenerator(Brightness brightness, RadixThemeColor themeColor) {
  TextTheme? textTheme;
  return ThemeData.from(
      colorScheme: _radixColorScheme(brightness, themeColor),
      textTheme: textTheme,
      useMaterial3: true);
}
