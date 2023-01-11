import 'dart:async';
import 'package:veilid/veilid.dart';
import 'config.dart';
import 'veilid_log.dart';
import '../log/log.dart';
import '../state/state.dart';

class Processor {
  String _veilidVersion = "";
  bool _startedUp = false;
  Stream<VeilidUpdate>? _updateStream;
  Future<void>? _updateProcessor;

  Processor();

  Future<void> startup() async {
    if (_startedUp) {
      return;
    }

    try {
      _veilidVersion = Veilid.instance.veilidVersionString();
    } on Exception {
      _veilidVersion = 'Failed to get veilid version.';
    }

    // In case of hot restart shut down first
    try {
      await Veilid.instance.shutdownVeilidCore();
    } on Exception {
      //
    }

    var updateStream =
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
    var cs = ConnectionState.detached;
    var checkPublicInternet = false;
    switch (updateAttachment.state.state) {
      case AttachmentState.detached:
        cs = ConnectionState.detached;
        break;
      case AttachmentState.detaching:
        cs = ConnectionState.detaching;
        break;
      case AttachmentState.attaching:
        cs = ConnectionState.attaching;
        break;
      case AttachmentState.attachedWeak:
        checkPublicInternet = true;
        cs = ConnectionState.attachedWeak;
        break;
      case AttachmentState.attachedGood:
        checkPublicInternet = true;
        cs = ConnectionState.attachedGood;
        break;
      case AttachmentState.attachedStrong:
        checkPublicInternet = true;
        cs = ConnectionState.attachedStrong;
        break;
      case AttachmentState.fullyAttached:
        checkPublicInternet = true;
        cs = ConnectionState.fullyAttached;
        break;
      case AttachmentState.overAttached:
        checkPublicInternet = true;
        cs = ConnectionState.overAttached;
        break;
    }
    if (checkPublicInternet) {
      if (!updateAttachment.state.publicInternetReady) {
        cs = ConnectionState.attaching;
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
    var stream = _updateStream;
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
          log.info("AppMessage: ${update.json}");
        } else if (update is VeilidAppCall) {
          log.info("AppCall: ${update.json}");
        } else {
          log.trace("Update: ${update.json}");
        }
      }
    }
  }
}
