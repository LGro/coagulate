import 'package:collection/collection.dart';
import 'package:indent/indent.dart';

import '../../../veilid_support.dart';

const maxLatencySamples = 100;
const timeoutDuration = 10;

extension LatencyStatsExt on LatencyStats {
  String debugString() => 'fast($fastest)/avg($average)/slow($slowest)/'
      'tm90($tm90)/tm75($tm75)/p90($p90)/p75($p75)';
}

class LatencyStatsAccounting {
  LatencyStatsAccounting({required this.maxSamples});

  LatencyStats record(TimestampDuration dur) {
    _samples.add(dur);
    if (_samples.length > maxSamples) {
      _samples.removeAt(0);
    }

    final sortedList = _samples.sorted();

    final fastest = sortedList.first;
    final slowest = sortedList.last;
    final average = TimestampDuration(
        value: sortedList.fold(BigInt.zero, (acc, x) => acc + x.value) ~/
            BigInt.from(sortedList.length));

    final tm90len = (sortedList.length * 90 + 99) ~/ 100;
    final tm75len = (sortedList.length * 75 + 99) ~/ 100;
    final tm90 = TimestampDuration(
        value: sortedList
                .sublist(0, tm90len)
                .fold(BigInt.zero, (acc, x) => acc + x.value) ~/
            BigInt.from(tm90len));
    final tm75 = TimestampDuration(
        value: sortedList
                .sublist(0, tm75len)
                .fold(BigInt.zero, (acc, x) => acc + x.value) ~/
            BigInt.from(tm90len));
    final p90 = sortedList[tm90len - 1];
    final p75 = sortedList[tm75len - 1];

    final ls = LatencyStats(
        fastest: fastest,
        slowest: slowest,
        average: average,
        tm90: tm90,
        tm75: tm75,
        p90: p90,
        p75: p75);

    return ls;
  }

  /////////////////////////////
  final int maxSamples;
  final _samples = <TimestampDuration>[];
}

class DHTCallStats {
  void record(TimestampDuration dur, Exception? exc) {
    final wasTimeout =
        exc is VeilidAPIExceptionTimeout || dur.toSecs() >= timeoutDuration;

    calls++;
    if (wasTimeout) {
      timeouts++;
    } else {
      successLatency = successLatencyAcct.record(dur);
    }
    latency = latencyAcct.record(dur);
  }

  String debugString() =>
      ' timeouts/calls: $timeouts/$calls (${(timeouts * 100 / calls).toStringAsFixed(3)}%)\n'
      'success latency: ${successLatency?.debugString()}\n'
      '    all latency: ${latency?.debugString()}\n';

  /////////////////////////////
  int calls = 0;
  int timeouts = 0;
  LatencyStats? latency;
  LatencyStats? successLatency;
  final latencyAcct = LatencyStatsAccounting(maxSamples: maxLatencySamples);
  final successLatencyAcct =
      LatencyStatsAccounting(maxSamples: maxLatencySamples);
}

class DHTPerKeyStats {
  DHTPerKeyStats(this.debugName);

  void record(String func, TimestampDuration dur, Exception? exc) {
    final keyFuncStats = _perFuncStats.putIfAbsent(func, DHTCallStats.new);

    _stats.record(dur, exc);
    keyFuncStats.record(dur, exc);
  }

  String debugString() {
    //
    final out = StringBuffer()
      ..write('Name: $debugName\n')
      ..write(_stats.debugString().indent(4))
      ..writeln('Per-Function:');
    for (final entry in _perFuncStats.entries) {
      final funcName = entry.key;
      final funcStats = entry.value.debugString().indent(4);
      out.write('$funcName:\n$funcStats'.indent(4));
    }

    return out.toString();
  }

  //////////////////////////////

  final String debugName;
  final _stats = DHTCallStats();
  final _perFuncStats = <String, DHTCallStats>{};
}

class DHTStats {
  DHTStats();

  Future<T> measure<T>(TypedKey key, String debugName, String func,
      Future<T> Function() closure) async {
    //
    final start = Veilid.instance.now();
    final keyStats =
        _statsPerKey.putIfAbsent(key, () => DHTPerKeyStats(debugName));
    final funcStats = _statsPerFunc.putIfAbsent(func, DHTCallStats.new);

    VeilidAPIException? exc;

    try {
      final res = await closure();

      return res;
    } on VeilidAPIException catch (e) {
      exc = e;
      rethrow;
    } finally {
      final end = Veilid.instance.now();
      final dur = end.diff(start);

      keyStats.record(func, dur, exc);
      funcStats.record(dur, exc);
    }
  }

  String debugString() {
    //
    final out = StringBuffer()..writeln('Per-Function:');
    for (final entry in _statsPerFunc.entries) {
      final funcName = entry.key;
      final funcStats = entry.value.debugString().indent(4);
      out.write('$funcName:\n$funcStats\n'.indent(4));
    }
    out.writeln('Per-Key:');
    for (final entry in _statsPerKey.entries) {
      final keyName = entry.key;
      final keyStats = entry.value.debugString().indent(4);
      out.write('$keyName:\n$keyStats\n'.indent(4));
    }

    return out.toString();
  }

  //////////////////////////////

  final _statsPerKey = <TypedKey, DHTPerKeyStats>{};
  final _statsPerFunc = <String, DHTCallStats>{};
}
