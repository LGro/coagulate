import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Caches a state value which can be changed from anywhere
// Creates a provider interface that notices when the value changes
class ExternalStreamState<T> {
  T currentState;
  StreamController<T> streamController;
  ExternalStreamState(T initialState)
      : currentState = initialState,
        streamController = StreamController<T>.broadcast();
  void add(T newState) {
    currentState = newState;
    streamController.add(newState);
  }

  AutoDisposeStreamProvider<T> provider() {
    return AutoDisposeStreamProvider<T>((ref) async* {
      if (await streamController.stream.isEmpty) {
        yield currentState;
      }
      await for (final value in streamController.stream) {
        yield value;
      }
    });
  }
}
