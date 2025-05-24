class DHTExceptionOutdated implements Exception {
  const DHTExceptionOutdated(
      [this.cause = 'operation failed due to newer dht value']);
  final String cause;

  @override
  String toString() => 'DHTExceptionOutdated: $cause';
}

class DHTExceptionInvalidData implements Exception {
  const DHTExceptionInvalidData(this.cause);
  final String cause;

  @override
  String toString() => 'DHTExceptionInvalidData: $cause';
}

class DHTExceptionCancelled implements Exception {
  const DHTExceptionCancelled([this.cause = 'operation was cancelled']);
  final String cause;

  @override
  String toString() => 'DHTExceptionCancelled: $cause';
}

class DHTExceptionNotAvailable implements Exception {
  const DHTExceptionNotAvailable(
      [this.cause = 'request could not be completed at this time']);
  final String cause;

  @override
  String toString() => 'DHTExceptionNotAvailable: $cause';
}
