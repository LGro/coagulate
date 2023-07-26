import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Caches a state value which can be changed from anywhere
// Creates a provider interface that notices when the value changes
class ExternalStreamState<T> {
  ExternalStreamState(T initialState)
      : currentState = initialState,
        streamController = StreamController<T>.broadcast();
  T currentState;
  StreamController<T> streamController;
  void add(T newState) {
    currentState = newState;
    streamController.add(newState);
  }

  AutoDisposeStreamProvider<T> provider() =>
      AutoDisposeStreamProvider<T>((ref) async* {
        if (await streamController.stream.isEmpty) {
          yield currentState;
        }
        await for (final value in streamController.stream) {
          yield value;
        }
      });
}
