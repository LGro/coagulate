import 'dart:convert';

import 'package:test/test.dart';
import 'package:veilid_support/veilid_support.dart';

Future<void> Function() makeTestDHTShortArrayCreateDelete(
        {required int stride}) =>
    () async {
      // Close before delete
      {
        final arr = await DHTShortArray.create(
            debugName: 'sa_create_delete 1 stride $stride', stride: stride);
        expect(await arr.operate((r) async => r.length), isZero);
        expect(arr.isOpen, isTrue);
        await arr.close();
        expect(arr.isOpen, isFalse);
        await arr.delete();
        // Operate should fail
        await expectLater(() async => arr.operate((r) async => r.length),
            throwsA(isA<StateError>()));
      }

      // Close after delete
      {
        final arr = await DHTShortArray.create(
            debugName: 'sa_create_delete 2 stride $stride', stride: stride);
        await arr.delete();
        // Operate should still succeed because things aren't closed
        expect(await arr.operate((r) async => r.length), isZero);
        await arr.close();
        // Operate should fail
        await expectLater(() async => arr.operate((r) async => r.length),
            throwsA(isA<StateError>()));
      }

      // Close after delete multiple
      // Okay to request delete multiple times before close
      {
        final arr = await DHTShortArray.create(
            debugName: 'sa_create_delete 3 stride $stride', stride: stride);
        await arr.delete();
        await arr.delete();
        // Operate should still succeed because things aren't closed
        expect(await arr.operate((r) async => r.length), isZero);
        await arr.close();
        await expectLater(() async => arr.close(), throwsA(isA<StateError>()));
        // Operate should fail
        await expectLater(() async => arr.operate((r) async => r.length),
            throwsA(isA<StateError>()));
      }
    };

Future<void> Function() makeTestDHTShortArrayAdd({required int stride}) =>
    () async {
      final arr = await DHTShortArray.create(
          debugName: 'sa_add 1 stride $stride', stride: stride);

      final dataset = Iterable<int>.generate(256)
          .map((n) => utf8.encode('elem $n'))
          .toList();

      print('adding singles\n');
      {
        for (var n = 4; n < 8; n++) {
          await arr.operateWriteEventual((w) async {
            print('$n ');
            await w.add(dataset[n]);
          });
        }
      }

      print('adding batch\n');
      {
        await arr.operateWriteEventual((w) async {
          print('${dataset.length ~/ 2}-${dataset.length}');
          await w.addAll(dataset.sublist(dataset.length ~/ 2, dataset.length));
        });
      }

      print('inserting singles\n');
      {
        for (var n = 0; n < 4; n++) {
          await arr.operateWriteEventual((w) async {
            print('$n ');
            await w.insert(n, dataset[n]);
          });
        }
      }

      print('inserting batch\n');
      {
        await arr.operateWriteEventual((w) async {
          print('8-${dataset.length ~/ 2}');
          await w.insertAll(8, dataset.sublist(8, dataset.length ~/ 2));
        });
      }

      //print('get all\n');
      {
        final dataset2 = await arr.operate((r) async => r.getRange(0));
        expect(dataset2, equals(dataset));
      }
      {
        final dataset3 =
            await arr.operate((r) async => r.getRange(64, length: 128));
        expect(dataset3, equals(dataset.sublist(64, 64 + 128)));
      }

      //print('clear\n');
      {
        await arr.operateWriteEventual((w) async {
          await w.clear();
        });
      }

      //print('get all\n');
      {
        final dataset4 = await arr.operate((r) async => r.getRange(0));
        expect(dataset4, isEmpty);
      }

      await arr.delete();
      await arr.close();
    };
