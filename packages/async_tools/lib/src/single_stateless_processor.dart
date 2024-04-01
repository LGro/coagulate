import 'dart:async';

import '../async_tools.dart';

// Process a single stateless update at a time ensuring each request
// gets processed asynchronously, and continuously while update is requested.
//
// This is useful for processing updates asynchronously without waiting
// from a synchronous execution context
class SingleStatelessProcessor {
  SingleStatelessProcessor();

  void update(Future<void> Function() closure) {
    singleFuture(this, () async {
      do {
        _more = false;
        await closure();

        // See if another update was requested
      } while (_more);
    }, onBusy: () {
      // Keep this state until we process again
      _more = true;
    });
  }

  // Like update, but with a busy wrapper that
  // clears once the updating is finished
  void busyUpdate<T, S>(
      Future<void> Function(Future<void> Function(void Function(S))) busy,
      Future<void> Function(void Function(S)) closure) {
    singleFuture(
        this,
        () async => busy((emit) async {
              do {
                _more = false;
                await closure(emit);

                // See if another update was requested
              } while (_more);
            }), onBusy: () {
      // Keep this state until we process again
      _more = true;
    });
  }

  bool _more = false;
}
