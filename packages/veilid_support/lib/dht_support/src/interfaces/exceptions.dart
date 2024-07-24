class DHTExceptionOutdated implements Exception {
  DHTExceptionOutdated(
      [this.cause = 'operation failed due to newer dht value']);
  String cause;
}

class DHTExceptionInvalidData implements Exception {
  DHTExceptionInvalidData([this.cause = 'dht data structure is corrupt']);
  String cause;
}

class DHTExceptionCancelled implements Exception {
  DHTExceptionCancelled([this.cause = 'operation was cancelled']);
  String cause;
}
