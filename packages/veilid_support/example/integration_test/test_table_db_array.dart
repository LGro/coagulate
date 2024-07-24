import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:veilid_support/veilid_support.dart';

Future<void> testTableDBArrayCreateDelete() async {
  // Close before delete
  {
    final arr =
        TableDBArray(table: 'testArray', crypto: const VeilidCryptoPublic());
    expect(() => arr.length, throwsA(isA<StateError>()));
    expect(arr.isOpen, isTrue);
    await arr.initWait();
    expect(arr.isOpen, isTrue);
    expect(arr.length, isZero);
    await arr.close();
    expect(arr.isOpen, isFalse);
    await arr.delete();
    expect(arr.isOpen, isFalse);
  }

  // Async create with close after delete and then reopen
  {
    final arr = await TableDBArray.make(
        table: 'testArray', crypto: const VeilidCryptoPublic());
    expect(arr.length, isZero);
    expect(arr.isOpen, isTrue);
    await expectLater(() async {
      await arr.delete();
    }, throwsA(isA<StateError>()));
    expect(arr.isOpen, isTrue);
    await arr.close();
    expect(arr.isOpen, isFalse);

    final arr2 = await TableDBArray.make(
        table: 'testArray', crypto: const VeilidCryptoPublic());
    expect(arr2.isOpen, isTrue);
    expect(arr.isOpen, isFalse);
    await arr2.close();
    expect(arr2.isOpen, isFalse);
    await arr2.delete();
  }
}

Uint8List makeData(int n) => utf8.encode('elem $n');
List<Uint8List> makeDataBatch(int n, int batchSize) =>
    List.generate(batchSize, (x) => makeData(n + x));

Future<void> Function() makeTestTableDBArrayAddGetClear(
        {required int count,
        required int singles,
        required int batchSize,
        required VeilidCrypto crypto}) =>
    () async {
      final arr = await TableDBArray.make(table: 'testArray', crypto: crypto);

      print('adding');
      {
        for (var n = 0; n < count;) {
          var toAdd = min(batchSize, count - n);
          for (var s = 0; s < min(singles, toAdd); s++) {
            await arr.add(makeData(n));
            toAdd--;
            n++;
          }

          await arr.addAll(makeDataBatch(n, toAdd));
          n += toAdd;

          print('  $n/$count');
        }
      }

      print('get singles');
      {
        for (var n = 0; n < batchSize; n++) {
          expect(await arr.get(n), equals(makeData(n)));
        }
      }

      print('get batch');
      {
        for (var n = batchSize; n < count; n += batchSize) {
          final toGet = min(batchSize, count - n);
          expect(await arr.getRange(n, n + toGet),
              equals(makeDataBatch(n, toGet)));
        }
      }

      print('clear');
      {
        await arr.clear();
        expect(arr.length, isZero);
      }

      await arr.close(delete: true);
    };

Future<void> Function() makeTestTableDBArrayInsert(
        {required int count,
        required int singles,
        required int batchSize,
        required VeilidCrypto crypto}) =>
    () async {
      final arr = await TableDBArray.make(table: 'testArray', crypto: crypto);

      final match = <Uint8List>[];

      print('inserting');
      {
        for (var n = 0; n < count;) {
          final start = n;
          var toAdd = min(batchSize, count - n);
          for (var s = 0; s < min(singles, toAdd); s++) {
            final data = makeData(n);
            await arr.insert(start, data);
            match.insert(start, data);
            toAdd--;
            n++;
          }

          final data = makeDataBatch(n, toAdd);
          await arr.insertAll(start, data);
          match.insertAll(start, data);
          n += toAdd;

          print('  $n/$count');
        }
      }

      print('get singles');
      {
        for (var n = 0; n < batchSize; n++) {
          expect(await arr.get(n), equals(match[n]));
        }
      }

      print('get batch');
      {
        for (var n = batchSize; n < count; n += batchSize) {
          final toGet = min(batchSize, count - n);
          expect(await arr.getRange(n, n + toGet),
              equals(match.sublist(n, n + toGet)));
        }
      }

      print('clear');
      {
        await arr.clear();
        expect(arr.length, isZero);
      }

      await arr.close(delete: true);
    };

Future<void> Function() makeTestTableDBArrayRemove(
        {required int count,
        required int singles,
        required int batchSize,
        required VeilidCrypto crypto}) =>
    () async {
      final arr = await TableDBArray.make(table: 'testArray', crypto: crypto);

      final match = <Uint8List>[];

      {
        final rems = [
          (0, 0),
          (0, 1),
          (0, batchSize),
          (1, batchSize - 1),
          (batchSize, 1),
          (batchSize + 1, batchSize),
          (batchSize - 1, batchSize + 1)
        ];
        for (final rem in rems) {
          print('adding ');
          {
            for (var n = match.length; n < count;) {
              final toAdd = min(batchSize, count - n);
              final data = makeDataBatch(n, toAdd);
              await arr.addAll(data);
              match.addAll(data);
              n += toAdd;
              print('  $n/$count');
            }
            expect(arr.length, equals(match.length));
          }

          {
            final start = rem.$1;
            final length = rem.$2;
            print('removing start=$start length=$length');

            final out = Output<List<Uint8List>>();
            await arr.removeRange(start, start + length, out: out);
            expect(out.value, equals(match.sublist(start, start + length)));
            match.removeRange(start, start + length);
            expect(arr.length, equals(match.length));

            print('get batch');
            {
              final checkCount = match.length;
              for (var n = 0; n < checkCount;) {
                final toGet = min(batchSize, checkCount - n);
                expect(await arr.getRange(n, n + toGet),
                    equals(match.sublist(n, n + toGet)));
                n += toGet;
                print('  $n/$checkCount');
              }
            }
          }

          {
            final start = match.length - rem.$1 - rem.$2;
            final length = rem.$2;
            print('removing from end start=$start length=$length');

            final out = Output<List<Uint8List>>();
            await arr.removeRange(start, start + length, out: out);
            expect(out.value, equals(match.sublist(start, start + length)));
            match.removeRange(start, start + length);
            expect(arr.length, equals(match.length));

            print('get batch');
            {
              final checkCount = match.length;
              for (var n = 0; n < checkCount;) {
                final toGet = min(batchSize, checkCount - n);
                expect(await arr.getRange(n, n + toGet),
                    equals(match.sublist(n, n + toGet)));
                n += toGet;
                print('  $n/$checkCount');
              }
              expect(arr.length, equals(match.length));
            }
          }
        }
      }

      print('clear');
      {
        await arr.clear();
        expect(arr.length, isZero);
      }

      await arr.close(delete: true);
    };
