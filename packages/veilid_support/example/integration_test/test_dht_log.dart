import 'dart:convert';

import 'package:test/test.dart';
import 'package:veilid_support/veilid_support.dart';

Future<void> Function() makeTestDHTLogCreateDelete({required int stride}) =>
    () async {
      // Close before delete
      {
        final dlog = await DHTLog.create(
            debugName: 'log_create_delete 1 stride $stride', stride: stride);
        expect(await dlog.operate((r) async => r.length), isZero);
        expect(dlog.isOpen, isTrue);
        await dlog.close();
        expect(dlog.isOpen, isFalse);
        await dlog.delete();
        // Operate should fail
        await expectLater(() async => dlog.operate((r) async => r.length),
            throwsA(isA<StateError>()));
      }

      // Close after delete
      {
        final dlog = await DHTLog.create(
            debugName: 'log_create_delete 2 stride $stride', stride: stride);
        await dlog.delete();
        // Operate should still succeed because things aren't closed
        expect(await dlog.operate((r) async => r.length), isZero);
        await dlog.close();
        // Operate should fail
        await expectLater(() async => dlog.operate((r) async => r.length),
            throwsA(isA<StateError>()));
      }

      // Close after delete multiple
      // Okay to request delete multiple times before close
      {
        final dlog = await DHTLog.create(
            debugName: 'log_create_delete 3 stride $stride', stride: stride);
        await dlog.delete();
        await dlog.delete();
        // Operate should still succeed because things aren't closed
        expect(await dlog.operate((r) async => r.length), isZero);
        await dlog.close();
        await expectLater(() async => dlog.close(), throwsA(isA<StateError>()));
        // Operate should fail
        await expectLater(() async => dlog.operate((r) async => r.length),
            throwsA(isA<StateError>()));
      }
    };

Future<void> Function() makeTestDHTLogAddTruncate({required int stride}) =>
    () async {
      final dlog = await DHTLog.create(
          debugName: 'log_add 1 stride $stride', stride: stride);

      final dataset = Iterable<int>.generate(1000)
          .map((n) => utf8.encode('elem $n'))
          .toList();

      print('adding\n');
      {
        final res = await dlog.operateAppend((w) async {
          const chunk = 25;
          for (var n = 0; n < dataset.length; n += chunk) {
            print('$n-${n + chunk - 1} ');
            await w.addAll(dataset.sublist(n, n + chunk));
          }
        });
        expect(res, isNull);
      }

      print('get all\n');
      {
        final dataset2 = await dlog.operate((r) async => r.getRange(0));
        expect(dataset2, equals(dataset));
      }
      {
        final dataset3 =
            await dlog.operate((r) async => r.getRange(64, length: 128));
        expect(dataset3, equals(dataset.sublist(64, 64 + 128)));
      }
      {
        final dataset4 =
            await dlog.operate((r) async => r.getRange(0, length: 1000));
        expect(dataset4, equals(dataset.sublist(0, 1000)));
      }
      {
        final dataset5 =
            await dlog.operate((r) async => r.getRange(500, length: 499));
        expect(dataset5, equals(dataset.sublist(500, 999)));
      }
      print('truncate\n');
      {
        await dlog.operateAppend((w) async => w.truncate(w.length - 5));
      }
      {
        final dataset6 =
            await dlog.operate((r) async => r.getRange(500 - 5, length: 499));
        expect(dataset6, equals(dataset.sublist(500, 999)));
      }
      print('truncate 2\n');
      {
        await dlog.operateAppend((w) async => w.truncate(w.length - 251));
      }
      {
        final dataset7 =
            await dlog.operate((r) async => r.getRange(500 - 256, length: 499));
        expect(dataset7, equals(dataset.sublist(500, 999)));
      }
      print('clear\n');
      {
        await dlog.operateAppend((w) async => w.clear());
      }
      print('get all\n');
      {
        final dataset8 = await dlog.operate((r) async => r.getRange(0));
        expect(dataset8, isEmpty);
      }
      print('delete and close\n');

      await dlog.delete();
      await dlog.close();
    };
