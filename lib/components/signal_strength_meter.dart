import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:signal_strength_indicator/signal_strength_indicator.dart';

import '../providers/connection_state.dart';
import '../tools/tools.dart';

class SignalStrengthMeterWidget extends ConsumerWidget {
  const SignalStrengthMeterWidget({super.key});

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;

    const iconSize = 16.0;
    final connState = ref.watch(globalConnectionStateProvider).asData?.value;
    if (connState == null) {
      return const Icon(Icons.signal_cellular_off, size: iconSize);
    }
    late final double value;
    late final Color color;
    late final Color inactiveColor;
    switch (connState) {
      case GlobalConnectionState.detached:
        return Icon(Icons.signal_cellular_nodata,
            size: iconSize, color: scale.grayScale.text);
      case GlobalConnectionState.detaching:
        return Icon(Icons.signal_cellular_off,
            size: iconSize, color: scale.grayScale.text);
      case GlobalConnectionState.attaching:
        value = 0;
        color = scale.primaryScale.text;
      case GlobalConnectionState.attachedWeak:
        value = 1;
        color = scale.primaryScale.text;
      case GlobalConnectionState.attachedStrong:
        value = 2;
        color = scale.primaryScale.text;
      case GlobalConnectionState.attachedGood:
        value = 3;
        color = scale.primaryScale.text;
      case GlobalConnectionState.fullyAttached:
        value = 4;
        color = scale.primaryScale.text;
      case GlobalConnectionState.overAttached:
        value = 4;
        color = scale.secondaryScale.subtleText;
    }
    inactiveColor = scale.grayScale.subtleText;

    return SignalStrengthIndicator.bars(
      value: value,
      activeColor: color,
      inactiveColor: inactiveColor,
      size: iconSize,
      barCount: 4,
      spacing: 1,
    );
  }
}
