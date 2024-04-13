import 'dart:async';

import 'package:flutter/material.dart';
import 'package:veilid_support/veilid_support.dart';

import 'veilid_processor/veilid_processor.dart';

class BackgroundTicker extends StatefulWidget {
  const BackgroundTicker({required this.child, super.key});

  final Widget child;

  @override
  BackgroundTickerState createState() => BackgroundTickerState();
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
    return widget.child;
  }

  Future<void> _onTick() async {
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
