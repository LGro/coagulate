import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:mutex/mutex.dart';

@immutable
class BlocBusyState<S> extends Equatable {
  const BlocBusyState(this.state) : busy = false;
  const BlocBusyState._busy(this.state) : busy = true;
  final bool busy;
  final S state;

  @override
  List<Object?> get props => [busy, state];
}

mixin BlocBusyWrapper<S> on BlocBase<BlocBusyState<S>> {
  Future<T> busyValue<T>(Future<T> Function(void Function(S) emit) closure) =>
      _mutex.protect(() async {
        void busyemit(S state) {
          changedState = state;
        }

        // Turn on busy state
        emit(BlocBusyState._busy(state.state));

        // Run the closure
        final out = await closure(busyemit);

        // If the closure did one or more 'busy emits' then
        // take the most recent one and emit it for real
        final finalState = changedState;
        if (finalState != null && finalState != state.state) {
          emit(BlocBusyState._busy(finalState));
        } else {
          emit(BlocBusyState._busy(state.state));
        }

        return out;
      });

  Future<void> busy(Future<void> Function(void Function(S) emit) closure) =>
      _mutex.protect(() async {
        void busyemit(S state) {
          changedState = state;
        }

        // Turn on busy state
        emit(BlocBusyState._busy(state.state));

        // Run the closure
        await closure(busyemit);

        // If the closure did one or more 'busy emits' then
        // take the most recent one and emit it for real and
        // turn off the busy state
        final finalState = changedState;
        if (finalState != null && finalState != state.state) {
          emit(BlocBusyState(finalState));
        } else {
          emit(BlocBusyState(state.state));
        }
      });
  void changeState(S state) {
    if (_mutex.isLocked) {
      changedState = state;
    } else {
      emit(BlocBusyState(state));
    }
  }

  bool get isBusy => _mutex.isLocked;

  final Mutex _mutex = Mutex();
  S? changedState;
}
