import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';

class DefaultAppBar extends AppBar {
  DefaultAppBar(BuildContext context,
      {super.key, required super.title, Widget? leading, List<Widget>? actions})
      : super(
            leading: leading ??
                Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        color: Colors.black.withAlpha(32),
                        shape: BoxShape.circle),
                    child: SvgPicture.asset("assets/images/vlogo.svg",
                        height: 48)),
            actions: (actions ?? <Widget>[])
              ..add(
                IconButton(
                  icon: const Icon(Icons.settings),
                  tooltip: translate('app_bar.settings_tooltip'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            'Accessibility and language options coming soon')));
                  },
                ),
              ));
}
