import 'dart:async';

import 'package:flutter/foundation.dart';

import 'loggy.dart';

/// Converts a [Stream] into a [Listenable]
///
/// {@tool snippet}
/// Typical usage is as follows:
///
/// ```dart
/// StreamListenable(stream)
/// ```
/// {@end-tool}
class StreamListenable extends ChangeNotifier {
  /// Creates a [StreamListenable].
  ///
  /// Every time the [Stream] receives an event this [ChangeNotifier] will
  /// notify its listeners.
  StreamListenable(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel().onError((error, stackTrace) =>
        log.error('StreamListenable cancel error: $error\n$stackTrace')));
    super.dispose();
  }
}
