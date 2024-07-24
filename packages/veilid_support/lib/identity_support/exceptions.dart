/// Identity errors
enum IdentityException implements Exception {
  readError('identity could not be read'),
  noAccount('no account record info'),
  limitExceeded('too many items for the limit'),
  invalid('identity is corrupted or secret is invalid'),
  cancelled('account operation cancelled');

  const IdentityException(this.message);
  final String message;

  @override
  String toString() => 'IdentityException($name): $message';
}
