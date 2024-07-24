////////////////////////////////////////////////////////////////////////////
// Clear interface
// ignore: one_member_abstracts
abstract class DHTClear {
  /// Remove all items in the DHT container.
  Future<void> clear();
}
