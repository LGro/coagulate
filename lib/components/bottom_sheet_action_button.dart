import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BottomSheetActionButton extends ConsumerStatefulWidget {
  const BottomSheetActionButton(
      {required this.bottomSheetBuilder,
      required this.builder,
      this.foregroundColor,
      this.backgroundColor,
      this.shape,
      super.key});
  final Color? foregroundColor;
  final Color? backgroundColor;
  final ShapeBorder? shape;
  final Widget Function(BuildContext) builder;
  final Widget Function(BuildContext) bottomSheetBuilder;

  @override
  BottomSheetActionButtonState createState() => BottomSheetActionButtonState();
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(ObjectFlagProperty<Widget Function(BuildContext p1)>.has(
          'bottomSheetBuilder', bottomSheetBuilder))
      ..add(ColorProperty('foregroundColor', foregroundColor))
      ..add(ColorProperty('backgroundColor', backgroundColor))
      ..add(DiagnosticsProperty<ShapeBorder?>('shape', shape))
      ..add(ObjectFlagProperty<Widget? Function(BuildContext p1)>.has(
          'builder', builder));
  }
}

class BottomSheetActionButtonState
    extends ConsumerState<BottomSheetActionButton> {
  bool _showFab = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    //
    return _showFab
        ? FloatingActionButton(
            elevation: 0,
            hoverElevation: 0,
            shape: widget.shape,
            foregroundColor: widget.foregroundColor,
            backgroundColor: widget.backgroundColor,
            child: widget.builder(context),
            onPressed: () async {
              await showModalBottomSheet<void>(
                  context: context, builder: widget.bottomSheetBuilder);
            },
          )
        : Container();
  }

  void showFloatingActionButton(bool value) {
    setState(() {
      _showFab = value;
    });
  }
}
