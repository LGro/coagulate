class DHTExceptionTryAgain implements Exception {
  DHTExceptionTryAgain(
      [this.cause = 'operation failed due to newer dht value']);
  String cause;
}

class DHTExceptionInvalidData implements Exception {
  DHTExceptionInvalidData([this.cause = 'dht data structure is corrupt']);
  String cause;
}
