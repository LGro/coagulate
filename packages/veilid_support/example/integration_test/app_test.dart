import 'package:flutter/foundation.dart';
import 'package:integration_test/integration_test.dart';
import 'package:test/test.dart';
import 'package:veilid_support/veilid_support.dart';
import 'package:veilid_test/veilid_test.dart';

import 'fixtures/fixtures.dart';
import 'test_dht_log.dart';
import 'test_dht_record_pool.dart';
import 'test_dht_short_array.dart';
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

    group('Attached Tests', () {
      setUpAll(veilidFixture.attach);
      tearDownAll(veilidFixture.detach);

      group('DHT Support Tests', () {
        setUpAll(updateProcessorFixture.setUp);
        setUpAll(tickerFixture.setUp);
        tearDownAll(tickerFixture.tearDown);
        tearDownAll(updateProcessorFixture.tearDown);

        test('create pool', testDHTRecordPoolCreate);

        group('DHTRecordPool Tests', () {
          setUpAll(dhtRecordPoolFixture.setUp);
          tearDownAll(dhtRecordPoolFixture.tearDown);

          test('create/delete record', testDHTRecordCreateDelete);
          test('record scopes', testDHTRecordScopes);
          test('create/delete deep record', testDHTRecordDeepCreateDelete);
        });

        group('DHTShortArray Tests', () {
          setUpAll(dhtRecordPoolFixture.setUp);
          tearDownAll(dhtRecordPoolFixture.tearDown);

          for (final stride in [256, 16 /*64, 32, 16, 8, 4, 2, 1 */]) {
            test('create shortarray stride=$stride',
                makeTestDHTShortArrayCreateDelete(stride: stride));
            test('add shortarray stride=$stride',
                makeTestDHTShortArrayAdd(stride: stride));
          }
        });

        group('DHTLog Tests', () {
          setUpAll(dhtRecordPoolFixture.setUp);
          tearDownAll(dhtRecordPoolFixture.tearDown);

          for (final stride in [256, 16 /*64, 32, 16, 8, 4, 2, 1 */]) {
            test('create log stride=$stride',
                makeTestDHTLogCreateDelete(stride: stride));
            test(
              timeout: const Timeout(Duration(seconds: 480)),
              'add/truncate log stride=$stride',
              makeTestDHTLogAddTruncate(stride: stride),
            );
          }
        });
      });

      group('TableDB Tests', () {
        group('TableDBArray Tests', () {
          // test('create/delete TableDBArray', testTableDBArrayCreateDelete);

          group('TableDBArray Add/Get Tests', () {
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
                'add/remove TableDBArray count = $count batchSize=$batchSize',
                makeTestTableDBArrayAddGetClear(
                    count: count,
                    singles: singles,
                    batchSize: batchSize,
                    crypto: const VeilidCryptoPublic()),
              );
            }
          });

          group('TableDBArray Insert Tests', () {
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
                'insert TableDBArray count=$count singles=$singles batchSize=$batchSize',
                makeTestTableDBArrayInsert(
                    count: count,
                    singles: singles,
                    batchSize: batchSize,
                    crypto: const VeilidCryptoPublic()),
              );
            }
          });

          group('TableDBArray Remove Tests', () {
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
                'remove TableDBArray count=$count singles=$singles batchSize=$batchSize',
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
