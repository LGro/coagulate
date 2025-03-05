import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension LocalizationExt on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this)!;
}

extension StringExtension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}

String extractAllValuesToString(dynamic value) {
  if (value is Map) {
    return value.values.map(extractAllValuesToString).join('|');
  } else if (value is List) {
    return value.map(extractAllValuesToString).join('|');
  } else {
    return value.toString();
  }
}

Widget roundPictureOrPlaceholder(List<int>? picture, {double? radius}) =>
    ClipOval(
        child: Image.memory(
      Uint8List.fromList(picture ?? []),
      gaplessPlayback: true,
      width: (radius == null) ? null : radius * 2,
      height: (radius == null) ? null : radius * 2,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          CircleAvatar(radius: radius, child: const Icon(Icons.person)),
    ));
