import 'dart:math';
import 'dart:typed_data';

/// Compares two [Uint8List] contents for equality by comparing words at a time.
/// Returns true if this == other
extension Uint8ListCompare on Uint8List {
  bool equals(Uint8List other) {
    if (identical(this, other)) {
      return true;
    }
    if (length != other.length) {
      return false;
    }

    final words = buffer.asUint32List();
    final otherwords = other.buffer.asUint32List();
    final wordLen = words.length;

    var i = 0;
    for (; i < wordLen; i++) {
      if (words[i] != otherwords[i]) {
        break;
      }
    }
    i <<= 2;
    for (; i < length; i++) {
      if (this[i] != other[i]) {
        return false;
      }
    }
    return true;
  }

  /// Compares two [Uint8List] contents for
  /// numeric ordering by comparing words at a time.
  /// Returns -1 for this < other, 1 for this > other, and 0 for this == other.
  int compare(Uint8List other) {
    if (identical(this, other)) {
      return 0;
    }

    final words = buffer.asUint32List();
    final otherwords = other.buffer.asUint32List();
    final minWordLen = min(words.length, otherwords.length);

    var i = 0;
    for (; i < minWordLen; i++) {
      if (words[i] != otherwords[i]) {
        break;
      }
    }
    i <<= 2;
    final minLen = min(length, other.length);
    for (; i < minLen; i++) {
      final a = this[i];
      final b = other[i];
      if (a < b) {
        return -1;
      }
      if (a > b) {
        return 1;
      }
    }
    if (length < other.length) {
      return -1;
    }
    if (length > other.length) {
      return 1;
    }
    return 0;
  }
}
