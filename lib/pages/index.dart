import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:radix_colors/radix_colors.dart';

import '../providers/window_control.dart';

class IndexPage extends ConsumerWidget {
  const IndexPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(windowControlProvider);

    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final monoTextStyle = textTheme.labelSmall!
        .copyWith(fontFamily: 'Source Code Pro', fontSize: 11);
    final emojiTextStyle = textTheme.labelSmall!
        .copyWith(fontFamily: 'Noto Color Emoji', fontSize: 11);

    return Scaffold(
        body: DecoratedBox(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
            RadixColors.dark.plum.step4,
            RadixColors.dark.plum.step2,
          ])),
      child: Center(
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Hack to preload fonts
                    Offstage(child: Text('🧱', style: emojiTextStyle)),
                    // Hack to preload fonts
                    Offstage(child: Text('A', style: monoTextStyle)),
                    // Splash Screen
                    Expanded(
                        flex: 2,
                        child: SvgPicture.asset(
                          'assets/images/icon.svg',
                        )),
                    Expanded(
                        child: SvgPicture.asset(
                      'assets/images/title.svg',
                    ))
                  ]))),
    ));
  }
}
