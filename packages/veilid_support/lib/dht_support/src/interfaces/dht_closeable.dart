import 'dart:async';

import 'package:meta/meta.dart';

abstract class DHTCloseable<D> {
  // Public interface
  Future<void> ref();
  Future<bool> close();

  // Internal implementation
  @protected
  bool get isOpen;
  @protected
  FutureOr<D> scoped();
}

abstract class DHTDeleteable<D> extends DHTCloseable<D> {
  Future<void> delete();
}

extension DHTCloseableExt<D> on DHTCloseable<D> {
  /// Runs a closure that guarantees the DHTCloseable
  /// will be closed upon exit, even if an uncaught exception is thrown
  Future<T> scope<T>(Future<T> Function(D) scopeFunction) async {
    if (!isOpen) {
      throw StateError('not open in scope');
    }
    try {
      return await scopeFunction(await scoped());
    } finally {
      await close();
    }
  }
}

extension DHTDeletableExt<D> on DHTDeleteable<D> {
  /// Runs a closure that guarantees the DHTCloseable
  /// will be closed upon exit, and deleted if an an
  /// uncaught exception is thrown
  Future<T> deleteScope<T>(Future<T> Function(D) scopeFunction) async {
    if (!isOpen) {
      throw StateError('not open in deleteScope');
    }

    try {
      return await scopeFunction(await scoped());
    } on Exception {
      await delete();
      rethrow;
    } finally {
      await close();
    }
  }

  /// Scopes a closure that conditionally deletes the DHTCloseable on exit
  Future<T> maybeDeleteScope<T>(
      bool delete, Future<T> Function(D) scopeFunction) async {
    if (delete) {
      return deleteScope(scopeFunction);
    }
    return scope(scopeFunction);
  }
}
