import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rxdart/subjects.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../tools/tools.dart';
import '../models/models.dart';

class ProcessorRepository {
  ProcessorRepository._()
      : startedUp = false,
        _updateValueChangeStreamController =
            BehaviorSubject<VeilidUpdateValueChange>(),
        _controllerConnectionState = StreamController.broadcast(sync: true),
        processorConnectionState = ProcessorConnectionState(
            attachment: const VeilidStateAttachment(
                state: AttachmentState.detached,
                publicInternetReady: false,
                localNetworkReady: false),
            network: VeilidStateNetwork(
                started: false,
                bpsDown: BigInt.zero,
                bpsUp: BigInt.zero,
                peers: []));

  //////////////////////////////////////////////////////////////
  /// Singleton initialization

  static ProcessorRepository instance = ProcessorRepository._();

  Future<void> startup() async {
    if (startedUp) {
      return;
    }

    var veilidVersion = '';

    try {
      veilidVersion = Veilid.instance.veilidVersionString();
    } on Exception {
      veilidVersion = 'Failed to get veilid version.';
    }

    log.info('Veilid version: $veilidVersion');

    // HACK: In case of hot restart shut down first
    try {
      await Veilid.instance.shutdownVeilidCore();
    } on Exception {
      // Do nothing on failure here
    }

    final updateStream = await Veilid.instance
        .startupVeilidCore(await getVeilidConfig(kIsWeb, 'Coagulate'));
    _updateSubscription = updateStream.listen((update) {
      if (update is VeilidLog) {
        processLog(update);
      } else if (update is VeilidUpdateAttachment) {
        processUpdateAttachment(update);
      } else if (update is VeilidUpdateConfig) {
        processUpdateConfig(update);
      } else if (update is VeilidUpdateNetwork) {
        processUpdateNetwork(update);
      } else if (update is VeilidAppMessage) {
        processAppMessage(update);
      } else if (update is VeilidAppCall) {
        log.info('AppCall: ${update.toJson()}');
      } else if (update is VeilidUpdateValueChange) {
        processUpdateValueChange(update);
      } else {
        log.trace('Update: ${update.toJson()}');
      }
    });

    startedUp = true;

    await Veilid.instance.attach();
  }

  Future<void> shutdown() async {
    if (!startedUp) {
      return;
    }
    await Veilid.instance.shutdownVeilidCore();
    await _updateSubscription?.cancel();
    _updateSubscription = null;

    startedUp = false;
  }

  Stream<VeilidUpdateValueChange> streamUpdateValueChange() =>
      _updateValueChangeStreamController.asBroadcastStream();

  Stream<ProcessorConnectionState> streamProcessorConnectionState() =>
      _controllerConnectionState.stream;

  void processUpdateAttachment(VeilidUpdateAttachment updateAttachment) {
    // Set connection meter and ui state for connection state
    processorConnectionState = processorConnectionState.copyWith(
        attachment: VeilidStateAttachment(
            state: updateAttachment.state,
            publicInternetReady: updateAttachment.publicInternetReady,
            localNetworkReady: updateAttachment.localNetworkReady));
  }

  void processUpdateConfig(VeilidUpdateConfig updateConfig) {
    log.debug('VeilidUpdateConfig: ${updateConfig.toJson()}');
  }

  void processUpdateNetwork(VeilidUpdateNetwork updateNetwork) {
    // Set connection meter and ui state for connection state
    processorConnectionState = processorConnectionState.copyWith(
        network: VeilidStateNetwork(
            started: updateNetwork.started,
            bpsDown: updateNetwork.bpsDown,
            bpsUp: updateNetwork.bpsUp,
            peers: updateNetwork.peers));
    _controllerConnectionState.add(processorConnectionState);
  }

  void processAppMessage(VeilidAppMessage appMessage) {
    log.debug('VeilidAppMessage: ${appMessage.toJson()}');
  }

  void processUpdateValueChange(VeilidUpdateValueChange updateValueChange) {
    log.debug('UpdateValueChange: ${updateValueChange.toJson()}');

    // Send value updates to DHTRecordPool
    DHTRecordPool.instance.processRemoteValueChange(updateValueChange);
    _updateValueChangeStreamController.add(updateValueChange);
  }

  ////////////////////////////////////////////

  StreamSubscription<VeilidUpdate>? _updateSubscription;
  final StreamController<ProcessorConnectionState> _controllerConnectionState;

  final BehaviorSubject<VeilidUpdateValueChange>
      _updateValueChangeStreamController;
  bool startedUp;
  ProcessorConnectionState processorConnectionState;
}
