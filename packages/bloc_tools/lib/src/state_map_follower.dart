import 'dart:async';

import 'package:async_tools/async_tools.dart';
import 'package:bloc/bloc.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';

/// Mixin that automatically keeps two blocs/cubits in sync with each other
/// Useful for having a BlocMapCubit 'follow' the state of another input cubit.
/// As the state of the input cubit changes, the BlocMapCubit can add/remove
/// mapped Cubits that automatically process the input state reactively.
///
/// S = Input state type
/// K = Key derived from elements of input state
/// V = Value derived from elements of input state
mixin StateMapFollower<S extends Object, K, V> on Closable {
  void follow(StateMapFollowable<S, K, V> followable) {
    assert(_following == null, 'can only follow one followable at a time');
    _following = followable;
    _lastInputStateMap = IMap();
    _subscription = followable.registerFollower(this);
  }

  Future<void> unfollow() async {
    await _subscription?.cancel();
    _subscription = null;
    _following?.unregisterFollower(this);
    _following = null;
  }

  @override
  @mustCallSuper
  Future<void> close() async {
    await unfollow();
    await super.close();
  }

  Future<void> removeFromState(K key);
  Future<void> updateState(K key, V value);

  void _updateFollow(IMap<K, V> newInputState) {
    final following = _following;
    if (following == null) {
      return;
    }
    _singleStateProcessor.updateState(newInputState, (newStateMap) async {
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

  StateMapFollowable<S, K, V>? _following;
  late IMap<K, V> _lastInputStateMap;
  late StreamSubscription<IMap<K, V>>? _subscription;
  final SingleStateProcessor<IMap<K, V>> _singleStateProcessor =
      SingleStateProcessor();
}

/// Interface that allows a StateMapFollower to follow some other class's
/// state changes
abstract mixin class StateMapFollowable<S extends Object, K, V>
    implements StateStreamable<S> {
  IMap<K, V> getStateMap(S state);

  StreamSubscription<IMap<K, V>> registerFollower(
      StateMapFollower<S, K, V> follower) {
    final stateMapTransformer = StreamTransformer<S, IMap<K, V>>.fromHandlers(
        handleData: (d, s) => s.add(getStateMap(d)));

    if (_followers.isEmpty) {
      // start transforming stream
      _transformedStream = stream.transform(stateMapTransformer);
    }
    _followers.add(follower);
    follower._updateFollow(getStateMap(state));
    return _transformedStream!.listen((s) => follower._updateFollow(s));
  }

  void unregisterFollower(StateMapFollower<S, K, V> follower) {
    _followers.remove(follower);
    if (_followers.isEmpty) {
      // stop transforming stream
      _transformedStream = null;
    }
  }

  Future<T> syncFollowers<T>(Future<T> Function() closure) async {
    // pause all followers
    await _followers.map((f) => f._singleStateProcessor.pause()).wait;

    // run closure
    final out = await closure();

    // resume all followers and wait for current state map to be updated
    final resumeState = getStateMap(state);
    await _followers.map((f) async {
      // Ensure the latest state has been updated
      try {
        f._updateFollow(resumeState);
      } finally {
        // Resume processing of the follower
        await f._singleStateProcessor.resume();
      }
    }).wait;

    return out;
  }

  Stream<IMap<K, V>>? _transformedStream;
  final List<StateMapFollower<S, K, V>> _followers = [];
}
