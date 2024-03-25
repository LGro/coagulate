// Copyright 2023 The Veilid Chat Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0
import 'dart:async';

import 'processor.dart';
import 'veilid_support/veilid_support.dart';

Future<String> getVeilidVersion() async {
  String veilidVersion;
  try {
    veilidVersion = Veilid.instance.veilidVersionString();
  } on Exception {
    veilidVersion = 'Failed to get veilid version.';
  }
  return veilidVersion;
}

// Initialize Veilid. Call only once.
void _initVeilid() {
  const platformConfig = VeilidFFIConfig(
      logging: VeilidFFIConfigLogging(
          terminal: VeilidFFIConfigLoggingTerminal(
            enabled: false,
            level: VeilidConfigLogLevel.debug,
          ),
          otlp: VeilidFFIConfigLoggingOtlp(
              enabled: false,
              level: VeilidConfigLogLevel.debug,
              grpcEndpoint: '127.0.0.1:4317',
              serviceName: 'Coagulate'),
          api: VeilidFFIConfigLoggingApi(
              enabled: true, level: VeilidConfigLogLevel.debug)));
  Veilid.instance.initializeVeilidCore(platformConfig.toJson());
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
