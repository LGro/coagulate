import 'dart:async';

import '../async_tools.dart';

// Process a single state update at a time ensuring the most
// recent state gets processed asynchronously, possibly skipping
// states that happen while a previous state is still being processed.
//
// Eventually this will always process the most recent state passed to
// updateState.
//
// This is useful for processing state changes asynchronously without waiting
// from a synchronous execution context
class SingleStateProcessor<State> {
  SingleStateProcessor();

  void updateState(State newInputState, Future<void> Function(State) closure) {
    // Use a singlefuture here to ensure we get dont lose any updates
    // If the input stream gives us an update while we are
    // still processing the last update, the most recent input state will
    // be saved and processed eventually.

    singleFuture(this, () async {
      var newState = newInputState;
      var newClosure = closure;
      var done = false;
      while (!done) {
        await newClosure(newState);

        // See if there's another state change to process
        final nextState = _nextState;
        final nextClosure = _nextClosure;
        _nextState = null;
        _nextClosure = null;
        if (nextState != null) {
          newState = nextState;
          newClosure = nextClosure!;
        } else {
          done = true;
        }
      }
    }, onBusy: () {
      // Keep this state until we process again
      _nextState = newInputState;
      _nextClosure = closure;
    });
  }

  Future<void> pause() => singleFuturePause(this);
  Future<void> resume() async {
    // Process any next state before resuming the singlefuture
    try {
      final nextState = _nextState;
      final nextClosure = _nextClosure;
      _nextState = null;
      _nextClosure = null;
      if (nextState != null) {
        await nextClosure!(nextState);
      }
    } finally {
      singleFutureResume(this);
    }
  }

  State? _nextState;
  Future<void> Function(State)? _nextClosure;
}
