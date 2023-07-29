import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:signal_strength_indicator/signal_strength_indicator.dart';

import '../components/chat.dart';
import '../components/chat_list.dart';
import '../providers/window_control.dart';
import '../tools/tools.dart';
import 'main_pager/main_pager.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  static const path = '/home';

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  final _unfocusNode = FocusNode();

  final MultiSplitViewController _splitController = MultiSplitViewController(
      areas: [Area(minimalSize: 300, weight: 0.25), Area(minimalSize: 300)]);
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool hasContainerTriggered = false;
  final animationsMap = {
    'containerOnActionTriggerAnimation': AnimationInfo(
      trigger: AnimationTrigger.onActionTrigger,
      applyInitialState: false,
      effects: [
        MoveEffect(
          curve: Curves.bounceOut,
          delay: 0.ms,
          duration: 500.ms,
          begin: const Offset(100, 0),
          end: Offset.zero,
        ),
      ],
    ),
  };

  @override
  void initState() {
    super.initState();

    setupAnimations(
      animationsMap.values.where((anim) =>
          anim.trigger == AnimationTrigger.onActionTrigger ||
          !anim.applyInitialState),
      this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {});
      await ref.read(windowControlProvider.notifier).changeWindowSetup(
          TitleBarStyle.normal, OrientationCapability.normal);
    });
  }

  @override
  void dispose() {
    _unfocusNode.dispose();
    super.dispose();
  }

  // ignore: prefer_expression_function_bodies
  Widget buildPhone(BuildContext context) {
    //
    return Material(
        color: Colors.transparent, elevation: 4, child: MainPager());
  }

  // ignore: prefer_expression_function_bodies
  Widget buildTabletLeftPane(BuildContext context) {
    //
    return Material(
        color: Colors.transparent, elevation: 4, child: MainPager());
  }

  // ignore: prefer_expression_function_bodies
  Widget buildTabletRightPane(BuildContext context) {
    //
    return Chat();
  }

  // ignore: prefer_expression_function_bodies
  Widget buildTablet(BuildContext context) {
    final children = [
      buildTabletLeftPane(context),
      buildTabletRightPane(context),
    ];

    final multiSplitView = MultiSplitView(
        // onWeightChange: _onWeightChange,
        // onDividerTap: _onDividerTap,
        // onDividerDoubleTap: _onDividerDoubleTap,
        controller: _splitController,
        children: children);

    final theme = MultiSplitViewTheme(
        data: isDesktop
            ? MultiSplitViewThemeData(
                dividerThickness: 1,
                dividerPainter: DividerPainters.grooved2(thickness: 1))
            : MultiSplitViewThemeData(
                dividerThickness: 3,
                dividerPainter: DividerPainters.grooved2(thickness: 1)),
        child: multiSplitView);

    return theme;
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(windowControlProvider);

    return SafeArea(
        child: GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(_unfocusNode),
      child: responsiveVisibility(
        context: context,
        phone: false,
      )
          ? buildTablet(context)
          : buildPhone(context),
    ));
  }
}
