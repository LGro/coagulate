////////////////////////////////////////////////////////////////////////////
// Truncate interface
// ignore: one_member_abstracts
abstract class DHTTruncate {
  /// Remove items from the DHT container to shrink its size to 'newLength'
  /// Throws StateError if newLength < 0
  Future<void> truncate(int newLength);
}
