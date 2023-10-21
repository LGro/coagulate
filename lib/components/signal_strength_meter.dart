import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signal_strength_indicator/signal_strength_indicator.dart';
import 'package:go_router/go_router.dart';

import '../providers/connection_state.dart';
import '../tools/tools.dart';
import '../veilid_support/veilid_support.dart';

class SignalStrengthMeterWidget extends ConsumerWidget {
  const SignalStrengthMeterWidget({super.key});

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;

    const iconSize = 16.0;
    final connState = ref.watch(connectionStateProvider);

    late final double value;
    late final Color color;
    late final Color inactiveColor;
    switch (connState.attachment.state) {
      case AttachmentState.detached:
        return Icon(Icons.signal_cellular_nodata,
            size: iconSize, color: scale.grayScale.text);
      case AttachmentState.detaching:
        return Icon(Icons.signal_cellular_off,
            size: iconSize, color: scale.grayScale.text);
      case AttachmentState.attaching:
        value = 0;
        color = scale.primaryScale.text;
      case AttachmentState.attachedWeak:
        value = 1;
        color = scale.primaryScale.text;
      case AttachmentState.attachedStrong:
        value = 2;
        color = scale.primaryScale.text;
      case AttachmentState.attachedGood:
        value = 3;
        color = scale.primaryScale.text;
      case AttachmentState.fullyAttached:
        value = 4;
        color = scale.primaryScale.text;
      case AttachmentState.overAttached:
        value = 4;
        color = scale.secondaryScale.subtleText;
    }
    inactiveColor = scale.grayScale.subtleText;

    return GestureDetector(
        onLongPress: () async {
          await context.push('/developer');
        },
        child: SignalStrengthIndicator.bars(
          value: value,
          activeColor: color,
          inactiveColor: inactiveColor,
          size: iconSize,
          barCount: 4,
          spacing: 1,
        ));
  }
}
