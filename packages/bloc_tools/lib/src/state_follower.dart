import 'dart:async';

import 'package:async_tools/async_tools.dart';
import 'package:bloc/bloc.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

// Mixin that automatically keeps two blocs/cubits in sync with each other
// Useful for having a BlocMapCubit 'follow' the state of another input cubit.
// As the state of the input cubit changes, the BlocMapCubit can add/remove
// mapped Cubits that automatically process the input state reactively.
//
// S = Input state type
// K = Key derived from elements of input state
// V = Value derived from elements of input state
abstract mixin class StateFollower<S extends Object, K, V> {
  void follow({
    required S initialInputState,
    required Stream<S> stream,
  }) {
    //
    _lastInputStateMap = IMap();
    _updateFollow(initialInputState);
    _subscription = stream.listen(_updateFollow);
  }

  void followBloc<B extends BlocBase<S>>(B bloc) =>
      follow(initialInputState: bloc.state, stream: bloc.stream);

  Future<void> close() async {
    await _subscription.cancel();
  }

  IMap<K, V> getStateMap(S state);
  Future<void> removeFromState(K key);
  Future<void> updateState(K key, V value);

  void _updateFollow(S newInputState) {
    _singleStateProcessor.updateState(getStateMap(newInputState),
        (newStateMap) async {
      for (final k in _lastInputStateMap.keys) {
        if (!newStateMap.containsKey(k)) {
          // deleted
          await removeFromState(k);
        }
      }
      for (final newEntry in newStateMap.entries) {
        final v = _lastInputStateMap.get(newEntry.key);
        if (v == null || v != newEntry.value) {
          // added or changed
          await updateState(newEntry.key, newEntry.value);
        }
      }

      // Keep this state map for the next time
      _lastInputStateMap = newStateMap;
    });
  }

  late IMap<K, V> _lastInputStateMap;
  late final StreamSubscription<S> _subscription;
  final SingleStateProcessor<IMap<K, V>> _singleStateProcessor =
      SingleStateProcessor();
}
