import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:veilid_support/veilid_support.dart';

import 'tools/tools.dart';
import 'veilid_processor/veilid_processor.dart';

class CoagulateGlobalInit {
  CoagulateGlobalInit._();

  // Initialize Veilid
  Future<void> _initializeVeilid() async {
    // Init Veilid
    Veilid.instance.initializeVeilidCore(
        await getDefaultVeilidPlatformConfig(false, 'Coagulate'));

    // Veilid logging
    initVeilidLog(kDebugMode);

    // Startup Veilid
    await ProcessorRepository.instance.startup();

    // DHT Record Pool
    await DHTRecordPool.init(
        logger: (message) => log.debug('DHTRecordPool: $message'));
  }

  static Future<CoagulateGlobalInit> initialize() async {
    final coagulateGlobalInit = CoagulateGlobalInit._();

    log.info('Initializing Veilid');
    await coagulateGlobalInit._initializeVeilid();

    return coagulateGlobalInit;
  }
}
