import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DefaultAppBar extends AppBar {
  DefaultAppBar(
      {required super.title, super.key, Widget? leading, super.actions})
      : super(
            leading: leading ??
                Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        color: Colors.black.withAlpha(32),
                        shape: BoxShape.circle),
                    child:
                        SvgPicture.asset('assets/images/vlogo.svg', height: 32)
                            .paddingAll(4)));
}
