import 'package:veilid/veilid.dart';

class DHTSeqChange {
  const DHTSeqChange(this.subkey, this.oldSeq, this.newSeq);
  final int subkey;
  final int? oldSeq;
  final int newSeq;
}

extension DHTReportReportExt on DHTRecordReport {
  List<ValueSubkeyRange> get newerOnlineSubkeys {
    if (networkSeqs.isEmpty || localSeqs.isEmpty || subkeys.isEmpty) {
      return [];
    }

    final currentSubkeys = <ValueSubkeyRange>[];

    var i = 0;
    for (final skr in subkeys) {
      for (var sk = skr.low; sk <= skr.high; sk++) {
        final nseq = networkSeqs[i];
        final lseq = localSeqs[i];

        if (nseq != null && (lseq == null || nseq > lseq)) {
          if (currentSubkeys.isNotEmpty &&
              currentSubkeys.last.high == (sk - 1)) {
            currentSubkeys.add(ValueSubkeyRange(
                low: currentSubkeys.removeLast().low, high: sk));
          } else {
            currentSubkeys.add(ValueSubkeyRange.single(sk));
          }
        }

        i++;
      }
    }

    return currentSubkeys;
  }

  DHTSeqChange? get firstSeqChange {
    if (networkSeqs.isEmpty || localSeqs.isEmpty || subkeys.isEmpty) {
      return null;
    }

    var i = 0;
    for (final skr in subkeys) {
      for (var sk = skr.low; sk <= skr.high; sk++) {
        final nseq = networkSeqs[i];
        final lseq = localSeqs[i];

        if (nseq != null && (lseq == null || nseq > lseq)) {
          return DHTSeqChange(sk, lseq, nseq);
        }
        i++;
      }
    }

    return null;
  }
}
