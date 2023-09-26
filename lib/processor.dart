import 'dart:async';

import 'package:veilid/veilid.dart';

import 'log/log.dart';
import 'providers/connection_state.dart';
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
    } on Exception {
      //
    }

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

    // Set connection meter and ui state for connection state
    var cs = GlobalConnectionState.detached;
    var checkPublicInternet = false;
    switch (updateAttachment.state) {
      case AttachmentState.detached:
        cs = GlobalConnectionState.detached;
        break;
      case AttachmentState.detaching:
        cs = GlobalConnectionState.detaching;
        break;
      case AttachmentState.attaching:
        cs = GlobalConnectionState.attaching;
        break;
      case AttachmentState.attachedWeak:
        checkPublicInternet = true;
        cs = GlobalConnectionState.attachedWeak;
        break;
      case AttachmentState.attachedGood:
        checkPublicInternet = true;
        cs = GlobalConnectionState.attachedGood;
        break;
      case AttachmentState.attachedStrong:
        checkPublicInternet = true;
        cs = GlobalConnectionState.attachedStrong;
        break;
      case AttachmentState.fullyAttached:
        checkPublicInternet = true;
        cs = GlobalConnectionState.fullyAttached;
        break;
      case AttachmentState.overAttached:
        checkPublicInternet = true;
        cs = GlobalConnectionState.overAttached;
        break;
    }
    if (checkPublicInternet) {
      if (!updateAttachment.publicInternetReady) {
        cs = GlobalConnectionState.attaching;
      }
    }

    globalConnectionState.add(cs);
  }

  Future<void> processUpdateConfig(VeilidUpdateConfig updateConfig) async {
    //loggy.info("Config: ${updateConfig.json}");
    // xxx: store in flutterflow local state? do we need this for anything?
  }

  Future<void> processUpdateNetwork(VeilidUpdateNetwork updateNetwork) async {
    //loggy.info("Network: ${updateNetwork.json}");
    // xxx: store in flutterflow local state? do we need this for anything?
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
