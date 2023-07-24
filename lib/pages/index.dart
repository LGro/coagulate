import 'package:flutter/material.dart';
import 'package:radix_colors/radix_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../tools/desktop_control.dart';

class IndexPage extends StatelessWidget {
  const IndexPage({super.key});
  static const path = '/';

  @override
  Widget build(BuildContext context) {
    enableTitleBar(false);
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
                    Expanded(
                        flex: 2,
                        child: SvgPicture.asset(
                          "assets/images/icon.svg",
                        )),
                    Expanded(
                        flex: 1,
                        child: SvgPicture.asset(
                          "assets/images/title.svg",
                        ))
                  ]))),
    ));
  }
}
