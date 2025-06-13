import 'dart:async';
import 'dart:convert';

import 'package:async_tools/async_tools.dart';
import 'package:collection/collection.dart';
import 'package:test/test.dart';
import 'package:veilid_support/veilid_support.dart';

Future<void> testPersistentQueueOpenClose() async {
  final pq = PersistentQueue(
      table: 'persistent_queue_integration_test',
      key: 'open_close',
      fromBuffer: (buf) => utf8.decode(buf),
      toBuffer: (s) => utf8.encode(s),
      closure: (elems) async {
        //
      });

  await pq.close();
}

Future<void> testPersistentQueueAdd() async {
  final added = <String>{};
  for (var n = 0; n < 100; n++) {
    final elem = 'FOOBAR #$n';
    added.add(elem);
  }

  final done = <String>{};
  final pq = PersistentQueue(
      table: 'persistent_queue_integration_test',
      key: 'add',
      fromBuffer: (buf) => utf8.decode(buf),
      toBuffer: (s) => utf8.encode(s),
      closure: (elems) async {
        done.addAll(elems);
      });

  var oddeven = false;
  for (final chunk in added.slices(10)) {
    if (!oddeven) {
      await chunk.map(pq.add).wait;
    } else {
      await pq.addAll(chunk);
    }
    oddeven = !oddeven;
  }

  await pq.close();

  expect(done, equals(added));
}

Future<void> testPersistentQueueAddSync() async {
  final added = <String>{};
  for (var n = 0; n < 100; n++) {
    final elem = 'FOOBAR #$n';
    added.add(elem);
  }

  final done = <String>{};
  final pq = PersistentQueue(
      table: 'persistent_queue_integration_test',
      key: 'add_sync',
      fromBuffer: (buf) => utf8.decode(buf),
      toBuffer: (s) => utf8.encode(s),
      closure: (elems) async {
        done.addAll(elems);
      });

  var oddeven = false;
  for (final chunk in added.slices(10)) {
    if (!oddeven) {
      await chunk.map((x) async {
        await asyncSleep(Duration.zero);
        pq.addSync(x);
      }).wait;
    } else {
      pq.addAllSync(chunk);
    }
    oddeven = !oddeven;
  }

  await pq.close();

  expect(done, equals(added));
}

Future<void> testPersistentQueueAddPersist() async {
  final added = <String>{};
  for (var n = 0; n < 100; n++) {
    final elem = 'FOOBAR #$n';
    added.add(elem);
  }

  final done = <String>{};

  late final PersistentQueue<String> pq;

  pq = PersistentQueue(
      table: 'persistent_queue_integration_test',
      key: 'add_persist',
      fromBuffer: (buf) => utf8.decode(buf),
      toBuffer: (s) => utf8.encode(s),
      closure: (elems) async {
        done.addAll(elems);
      });

  // Start it paused
  await pq.pause();

  // Add all elements
  var oddeven = false;

  for (final chunk in added.slices(10)) {
    if (!oddeven) {
      await chunk.map(pq.add).wait;
    } else {
      await pq.addAll(chunk);
    }
    oddeven = !oddeven;
  }

  // Close the persistent queue
  await pq.close();

  // Create a new persistent queue that processes the items
  final pq2 = PersistentQueue(
      table: 'persistent_queue_integration_test',
      key: 'add_persist',
      fromBuffer: (buf) => utf8.decode(buf),
      toBuffer: (s) => utf8.encode(s),
      closure: (elems) async {
        done.addAll(elems);
      });
  await pq2.waitEmpty;
  await pq2.close();

  expect(done, equals(added));
}

Future<void> testPersistentQueueAddSyncPersist() async {
  final added = <String>{};
  for (var n = 0; n < 100; n++) {
    final elem = 'FOOBAR #$n';
    added.add(elem);
  }

  final done = <String>{};

  late final PersistentQueue<String> pq;

  pq = PersistentQueue(
      table: 'persistent_queue_integration_test',
      key: 'add_persist',
      fromBuffer: (buf) => utf8.decode(buf),
      toBuffer: (s) => utf8.encode(s),
      closure: (elems) async {
        done.addAll(elems);
      });

  // Start it paused
  await pq.pause();

  // Add all elements
  var oddeven = false;

  for (final chunk in added.slices(10)) {
    if (!oddeven) {
      await chunk.map((x) async {
        await asyncSleep(Duration.zero);
        pq.addSync(x);
      }).wait;
    } else {
      pq.addAllSync(chunk);
    }
    oddeven = !oddeven;
  }

  // Close the persistent queue
  await pq.close();

  // Create a new persistent queue that processes the items
  final pq2 = PersistentQueue(
      table: 'persistent_queue_integration_test',
      key: 'add_persist',
      fromBuffer: (buf) => utf8.decode(buf),
      toBuffer: (s) => utf8.encode(s),
      closure: (elems) async {
        done.addAll(elems);
      });
  await pq2.waitEmpty;
  await pq2.close();

  expect(done, equals(added));
}
