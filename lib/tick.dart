import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:veilid_support/veilid_support.dart';

import 'veilid_init.dart';
import 'veilid_processor/veilid_processor.dart';

class BackgroundTicker extends StatefulWidget {
  const BackgroundTicker({required this.builder, super.key});

  final Widget Function(BuildContext) builder;

  @override
  BackgroundTickerState createState() => BackgroundTickerState();
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<Widget Function(BuildContext p1)>.has(
        'builder', builder));
  }
}

class BackgroundTickerState extends State<BackgroundTicker> {
  Timer? _tickTimer;
  bool _inTick = false;

  @override
  void initState() {
    super.initState();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_inTick) {
        unawaited(_onTick());
      }
    });
  }

  @override
  void dispose() {
    final tickTimer = _tickTimer;
    if (tickTimer != null) {
      tickTimer.cancel();
    }

    super.dispose();
  }

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    return widget.builder(context);
  }

  Future<void> _onTick() async {
    // Don't tick until we are initialized
    if (!eventualInitialized.isCompleted) {
      return;
    }
    if (!ProcessorRepository
        .instance.processorConnectionState.isPublicInternetReady) {
      return;
    }

    _inTick = true;
    try {
      // Tick DHT record pool
      unawaited(DHTRecordPool.instance.tick());
    } finally {
      _inTick = false;
    }
  }
}
