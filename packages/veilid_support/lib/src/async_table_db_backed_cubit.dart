import 'dart:async';

import 'package:async_tools/async_tools.dart';
import 'package:bloc/bloc.dart';

import 'table_db.dart';

abstract class AsyncTableDBBackedCubit<State> extends Cubit<AsyncValue<State>>
    with TableDBBacked<State> {
  AsyncTableDBBackedCubit() : super(const AsyncValue.loading()) {
    unawaited(Future.delayed(Duration.zero, _build));
  }

  Future<void> _build() async {
    try {
      emit(AsyncValue.data(await load()));
    } on Exception catch (e, stackTrace) {
      emit(AsyncValue.error(e, stackTrace));
    }
  }

  Future<State> readyData() async {
    final stateStream = stream.distinct();
    await for (final AsyncValue<State> av in stateStream) {
      final d = av.when(
          data: (value) => value, loading: () => null, error: (e, s) => null);
      if (d != null) {
        return d;
      }
      final ef = av.when(
          data: (value) => null,
          loading: () => null,
          error: Future<State>.error);
      if (ef != null) {
        return ef;
      }
    }
    return Future<State>.error(
        StateError("data never became ready in cubit '$runtimeType'"));
  }

  Future<void> setState(State newState) async {
    try {
      emit(AsyncValue.data(await store(newState)));
    } on Exception catch (e, stackTrace) {
      emit(AsyncValue.error(e, stackTrace));
    }
  }
}
