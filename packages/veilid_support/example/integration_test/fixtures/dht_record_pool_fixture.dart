import 'dart:async';

import 'package:async_tools/async_tools.dart';
import 'package:flutter/foundation.dart';
import 'package:veilid_support/veilid_support.dart';
import 'package:veilid_test/veilid_test.dart';

class DHTRecordPoolFixture implements TickerFixtureTickable {
  DHTRecordPoolFixture(
      {required this.tickerFixture, required this.updateProcessorFixture});

  static final _fixtureMutex = Mutex();
  UpdateProcessorFixture updateProcessorFixture;
  TickerFixture tickerFixture;

  Future<void> setUp({bool purge = true}) async {
    await _fixtureMutex.acquire();
    if (purge) {
      await Veilid.instance.debug('record purge local');
      await Veilid.instance.debug('record purge remote');
    }
    await DHTRecordPool.init(logger: debugPrintSynchronously);
    tickerFixture.register(this);
  }

  Future<void> tearDown() async {
    assert(_fixtureMutex.isLocked, 'should not tearDown without setUp');
    tickerFixture.unregister(this);
    await DHTRecordPool.close();

    final recordList = await Veilid.instance.debug('record list local');
    debugPrintSynchronously('DHT Record List:\n$recordList');

    _fixtureMutex.release();
  }

  @override
  Future<void> onTick() async {
    if (!updateProcessorFixture
        .processorConnectionState.isPublicInternetReady) {
      return;
    }
    await DHTRecordPool.instance.tick();
  }
}
