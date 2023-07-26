import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:veilid/veilid.dart';

import 'processor.dart';
import 'veilid_log.dart';

part 'veilid_init.g.dart';

Future<String> getVeilidVersion() async {
  String veilidVersion;
  try {
    veilidVersion = Veilid.instance.veilidVersionString();
  } on Exception {
    veilidVersion = 'Failed to get veilid version.';
  }
  return veilidVersion;
}

// Initialize Veilid
// Call only once.
void _initVeilid() {
  if (kIsWeb) {
    const platformConfig = VeilidWASMConfig(
        logging: VeilidWASMConfigLogging(
            performance: VeilidWASMConfigLoggingPerformance(
                enabled: true,
                level: VeilidConfigLogLevel.debug,
                logsInTimings: true,
                logsInConsole: false),
            api: VeilidWASMConfigLoggingApi(
                enabled: true, level: VeilidConfigLogLevel.info)));
    Veilid.instance.initializeVeilidCore(platformConfig.toJson());
  } else {
    const platformConfig = VeilidFFIConfig(
        logging: VeilidFFIConfigLogging(
            terminal: VeilidFFIConfigLoggingTerminal(
              enabled: false,
              level: VeilidConfigLogLevel.debug,
            ),
            otlp: VeilidFFIConfigLoggingOtlp(
                enabled: false,
                level: VeilidConfigLogLevel.trace,
                grpcEndpoint: '192.168.1.40:4317',
                serviceName: 'VeilidChat'),
            api: VeilidFFIConfigLoggingApi(
                enabled: true, level: VeilidConfigLogLevel.info)));
    Veilid.instance.initializeVeilidCore(platformConfig.toJson());
  }
}

Completer<Veilid> eventualVeilid = Completer<Veilid>();
Processor processor = Processor();

Future<void> initializeVeilid() async {
  // Ensure this runs only once
  if (eventualVeilid.isCompleted) {
    return;
  }

  // Init Veilid
  _initVeilid();

  // Veilid logging
  initVeilidLog();

  // Startup Veilid
  await processor.startup();

  // Share the initialized veilid instance to the rest of the app
  eventualVeilid.complete(Veilid.instance);
}

// Expose the Veilid instance as a FutureProvider
@riverpod
FutureOr<Veilid> veilidInstance(VeilidInstanceRef ref) async =>
    await eventualVeilid.future;
