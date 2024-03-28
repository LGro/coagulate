// Copyright 2023 The Veilid Chat Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:veilid_support/veilid_support.dart';

import 'tools/tools.dart';
import 'veilid_processor/veilid_processor.dart';

final Completer<void> eventualInitialized = Completer<void>();

// Initialize Veilid
Future<void> initializeVeilid() async {
  // Init Veilid
  Veilid.instance
      .initializeVeilidCore(getDefaultVeilidPlatformConfig(false, 'Coagulate'));

  // Veilid logging
  initVeilidLog(kDebugMode);

  // Startup Veilid
  await ProcessorRepository.instance.startup();

  // DHT Record Pool
  await DHTRecordPool.init();
}

Future<void> initializeVeilidChat() async {
  log.info('Initializing Veilid');
  await initializeVeilid();

  eventualInitialized.complete();
}
