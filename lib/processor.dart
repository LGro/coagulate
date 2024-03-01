import 'dart:async';

import 'package:veilid/veilid.dart';

import 'tools/tools.dart';
import 'veilid_support/src/config.dart';
import 'veilid_support/src/veilid_log.dart';

class Processor {
  Processor();
  String _veilidVersion = '';
  bool _startedUp = false;
  Stream<VeilidUpdate>? _updateStream;
  Future<void>? _updateProcessor;

  Future<void> startup() async {
    if (_startedUp) {
      return;
    }

    try {
      _veilidVersion = Veilid.instance.veilidVersionString();
    } on Exception {
      _veilidVersion = 'Failed to get veilid version.';
    }

    log.info('Veilid version: $_veilidVersion');

    // In case of hot restart shut down first
    try {
      await Veilid.instance.shutdownVeilidCore();
    } on Exception {}

    final updateStream =
        await Veilid.instance.startupVeilidCore(await getVeilidChatConfig());
    _updateStream = updateStream;
    _updateProcessor = processUpdates();
    _startedUp = true;

    await Veilid.instance.attach();
  }

  Future<void> shutdown() async {
    if (!_startedUp) {
      return;
    }
    await Veilid.instance.shutdownVeilidCore();
    if (_updateProcessor != null) {
      await _updateProcessor;
    }
    _updateProcessor = null;
    _updateStream = null;
    _startedUp = false;
  }

  Future<void> processUpdateAttachment(
      VeilidUpdateAttachment updateAttachment) async {
    //loggy.info("Attachment: ${updateAttachment.json}");
  }

  Future<void> processUpdateConfig(VeilidUpdateConfig updateConfig) async {
    //loggy.info("Config: ${updateConfig.json}");
  }

  Future<void> processUpdateNetwork(VeilidUpdateNetwork updateNetwork) async {
    //loggy.info("Network: ${updateNetwork.json}");
  }

  Future<void> processUpdates() async {
    final stream = _updateStream;
    if (stream != null) {
      await for (final update in stream) {
        if (update is VeilidLog) {
          await processLog(update);
        } else if (update is VeilidUpdateAttachment) {
          await processUpdateAttachment(update);
        } else if (update is VeilidUpdateConfig) {
          await processUpdateConfig(update);
        } else if (update is VeilidUpdateNetwork) {
          await processUpdateNetwork(update);
        } else if (update is VeilidAppMessage) {
          log.info('AppMessage: ${update.toJson()}');
        } else if (update is VeilidAppCall) {
          log.info('AppCall: ${update.toJson()}');
        } else {
          log.trace('Update: ${update.toJson()}');
        }
      }
    }
  }
}
