import 'package:flutter/foundation.dart';
import 'package:integration_test/integration_test.dart';
import 'package:test/test.dart';
import 'package:veilid_support/veilid_support.dart';
import 'package:veilid_test/veilid_test.dart';

import 'fixtures/fixtures.dart';
import 'test_dht_log.dart';
import 'test_dht_record_pool.dart';
import 'test_dht_short_array.dart';
import 'test_persistent_queue.dart';
import 'test_table_db_array.dart';

void main() {
  final startTime = DateTime.now();

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final veilidFixture =
      DefaultVeilidFixture(programName: 'veilid_support integration test');
  final updateProcessorFixture =
      UpdateProcessorFixture(veilidFixture: veilidFixture);
  final tickerFixture =
      TickerFixture(updateProcessorFixture: updateProcessorFixture);
  final dhtRecordPoolFixture = DHTRecordPoolFixture(
      tickerFixture: tickerFixture,
      updateProcessorFixture: updateProcessorFixture);

  group(timeout: const Timeout(Duration(seconds: 240)), 'Started Tests', () {
    setUpAll(veilidFixture.setUp);
    tearDownAll(veilidFixture.tearDown);
    tearDownAll(() {
      final endTime = DateTime.now();
      debugPrintSynchronously('Duration: ${endTime.difference(startTime)}');
    });

    group('attached', () {
      setUpAll(veilidFixture.attach);
      tearDownAll(veilidFixture.detach);

      group('persistent_queue', () {
        test('persistent_queue:open_close', testPersistentQueueOpenClose);
        test('persistent_queue:add', testPersistentQueueAdd);
        test('persistent_queue:add_sync', testPersistentQueueAddSync);
        test('persistent_queue:add_persist', testPersistentQueueAddPersist);
        test('persistent_queue:add_sync_persist',
            testPersistentQueueAddSyncPersist);
      });

      group('dht_support', () {
        setUpAll(updateProcessorFixture.setUp);
        setUpAll(tickerFixture.setUp);
        tearDownAll(tickerFixture.tearDown);
        tearDownAll(updateProcessorFixture.tearDown);

        test('create_pool', testDHTRecordPoolCreate);

        group('dht_record_pool', () {
          setUpAll(dhtRecordPoolFixture.setUp);
          tearDownAll(dhtRecordPoolFixture.tearDown);

          test('dht_record_pool:create_delete', testDHTRecordCreateDelete);
          test('dht_record_pool:scopes', testDHTRecordScopes);
          test('dht_record_pool:deep_create_delete',
              testDHTRecordDeepCreateDelete);
        });

        group('dht_short_array', () {
          setUpAll(dhtRecordPoolFixture.setUp);
          tearDownAll(dhtRecordPoolFixture.tearDown);

          for (final stride in [256, 16 /*64, 32, 16, 8, 4, 2, 1 */]) {
            test('dht_short_array:create_stride_$stride',
                makeTestDHTShortArrayCreateDelete(stride: stride));
            test('dht_short_array:add_stride_$stride',
                makeTestDHTShortArrayAdd(stride: stride));
          }
        });

        group('dht_log', () {
          setUpAll(dhtRecordPoolFixture.setUp);
          tearDownAll(dhtRecordPoolFixture.tearDown);

          for (final stride in [256, 16 /*64, 32, 16, 8, 4, 2, 1 */]) {
            test('dht_log:create_stride_$stride',
                makeTestDHTLogCreateDelete(stride: stride));
            test(
              timeout: const Timeout(Duration(seconds: 480)),
              'dht_log:add_truncate_stride_$stride',
              makeTestDHTLogAddTruncate(stride: stride),
            );
          }
        });
      });

      group('table_db', () {
        group('table_db_array', () {
          test('table_db_array:create_delete', testTableDBArrayCreateDelete);

          group('table_db_array:add_get', () {
            for (final params in [
              //
              (99, 3, 15),
              (100, 4, 16),
              (101, 5, 17),
              //
              (511, 3, 127),
              (512, 4, 128),
              (513, 5, 129),
              //
              (4095, 3, 1023),
              (4096, 4, 1024),
              (4097, 5, 1025),
              //
              (65535, 3, 16383),
              (65536, 4, 16384),
              (65537, 5, 16385),
            ]) {
              final count = params.$1;
              final singles = params.$2;
              final batchSize = params.$3;

              test(
                timeout: const Timeout(Duration(seconds: 480)),
                'table_db_array:add_remove_count=${count}_batchSize=$batchSize',
                makeTestTableDBArrayAddGetClear(
                    count: count,
                    singles: singles,
                    batchSize: batchSize,
                    crypto: const VeilidCryptoPublic()),
              );
            }
          });

          group('table_db_array:insert', () {
            for (final params in [
              //
              (99, 3, 15),
              (100, 4, 16),
              (101, 5, 17),
              //
              (511, 3, 127),
              (512, 4, 128),
              (513, 5, 129),
              //
              (4095, 3, 1023),
              (4096, 4, 1024),
              (4097, 5, 1025),
              //
              (65535, 3, 16383),
              (65536, 4, 16384),
              (65537, 5, 16385),
            ]) {
              final count = params.$1;
              final singles = params.$2;
              final batchSize = params.$3;

              test(
                timeout: const Timeout(Duration(seconds: 480)),
                'table_db_array:insert_count=${count}_'
                'singles=${singles}_batchSize=$batchSize',
                makeTestTableDBArrayInsert(
                    count: count,
                    singles: singles,
                    batchSize: batchSize,
                    crypto: const VeilidCryptoPublic()),
              );
            }
          });

          group('table_db_array:remove', () {
            for (final params in [
              //
              (99, 3, 15),
              (100, 4, 16),
              (101, 5, 17),
              //
              (511, 3, 127),
              (512, 4, 128),
              (513, 5, 129),
              //
              (4095, 3, 1023),
              (4096, 4, 1024),
              (4097, 5, 1025),
              //
              (16383, 3, 4095),
              (16384, 4, 4096),
              (16385, 5, 4097),
            ]) {
              final count = params.$1;
              final singles = params.$2;
              final batchSize = params.$3;

              test(
                timeout: const Timeout(Duration(seconds: 480)),
                'table_db_array:remove_count=${count}_'
                'singles=${singles}_batchSize=$batchSize',
                makeTestTableDBArrayRemove(
                    count: count,
                    singles: singles,
                    batchSize: batchSize,
                    crypto: const VeilidCryptoPublic()),
              );
            }
          });
        });
      });
    });
  });
}
