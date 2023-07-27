import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signal_strength_indicator/signal_strength_indicator.dart';

import '../tools/tools.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  static const path = '/home';

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  final _unfocusNode = FocusNode();
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
    // // On page load action.
    // SchedulerBinding.instance.addPostFrameCallback((_) async {
    //   await actions.initialize(
    //     context,
    //   );
    // });

    setupAnimations(
      animationsMap.values.where((anim) =>
          anim.trigger == AnimationTrigger.onActionTrigger ||
          !anim.applyInitialState),
      this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _unfocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      key: scaffoldKey,
      appBar: AppBar(title: const Text('VeilidChat')),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(_unfocusNode),
          child: Stack(
            children: [
              if (responsiveVisibility(
                context: context,
                phone: false,
              ))
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.66,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: const BoxDecoration(),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(0),
                                ),
                                child: Align(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            16, 0, 16, 0),
                                    child: Text(
                                      "current contact",
                                      // getJsonField(
                                      //   FFAppState().CurrentContact,
                                      //   r'''$.name''',
                                      // ).toString(),
                                      textAlign: TextAlign.start,
                                      // style: Theme.of(context)
                                      //     .textTheme....
                                      //     .override(
                                      //       fontFamily: 'Noto Sans',
                                      //       color: FlutterFlowTheme.of(context)
                                      //           .header,
                                      //     ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  height: 100,
                                  decoration: const BoxDecoration(),
                                  child: ChatComponentWidget(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // if (FFAppState().CurrentContact == null)
                        //   Container(
                        //     width: double.infinity,
                        //     height: double.infinity,
                        //     decoration: const BoxDecoration(),
                        //     child: NoContactComponentWidget(),
                        //   ),
                      ],
                    ),
                  ).animateOnActionTrigger(
                      animationsMap['containerOnActionTriggerAnimation']!,
                      hasBeenTriggered: hasContainerTriggered),
                ),
              if (responsiveVisibility(
                context: context,
                phone: false,
              ))
                Material(
                  color: Colors.transparent,
                  elevation: 4,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.34,
                    height: double.infinity,
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.34,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Theme.of(context).secondaryHeaderColor,
                            borderRadius: BorderRadius.circular(0),
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16, 8, 16, 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Align(
                                    alignment: AlignmentDirectional.centerStart,
                                    child: Text(
                                      'Contacts',
                                      textAlign: TextAlign.start,
                                      // style: Theme.of(context).dialogTheme.titleTextStyle
                                      //     .title2
                                      //     .override(
                                      //       fontFamily: 'Noto Sans',
                                      //       color: FlutterFlowTheme.of(context)
                                      //           .header,
                                      //     ),
                                    ),
                                  ),
                                ),
                                SignalStrengthIndicator.bars(
                                  value: .5, //_signalStrength,
                                  size: 50,
                                  barCount: 5,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: const BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 0,
                                  color: Color(0x33000000),
                                  offset: Offset(0, 0),
                                )
                              ],
                            ),
                            child: ContactListComponentWidget(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (responsiveVisibility(
                context: context,
                tablet: false,
                tabletLandscape: false,
                desktop: false,
              ))
                Material(
                  color: Colors.transparent,
                  elevation: 4,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            //color: Theme.of(context).secondaryColor,
                            borderRadius: BorderRadius.circular(0),
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16, 8, 16, 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  child: Align(
                                    alignment:
                                        const AlignmentDirectional(-1, 0),
                                    child: Text(
                                      'Contacts',
                                      textAlign: TextAlign.start,
                                      // style: FlutterFlowTheme.of(context)
                                      //     .title2
                                      //     .override(
                                      //       fontFamily: 'Noto Sans',
                                      //       color: FlutterFlowTheme.of(context)
                                      //           .header,
                                      //     ),
                                    ),
                                  ),
                                ),
                                SignalStrengthIndicator.bars(
                                  value: .5, //_signalStrength,
                                  size: 50,
                                  barCount: 5,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: const BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 0,
                                  color: Color(0x33000000),
                                  offset: Offset(0, 0),
                                )
                              ],
                            ),
                            child: ContactListComponentWidget(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ));
}
