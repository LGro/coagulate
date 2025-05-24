import 'dart:async';

import 'package:async_tools/async_tools.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import 'config.dart';
import 'table_db.dart';

abstract class AsyncTableDBBackedCubit<T> extends Cubit<AsyncValue<T?>>
    with TableDBBackedJson<T?> {
  AsyncTableDBBackedCubit() : super(const AsyncValue.loading()) {
    _initWait.add(_build);
  }

  @override
  Future<void> close() async {
    // Ensure the init finished
    await _initWait();
    // Wait for any setStates to finish
    await _mutex.acquire();

    await super.close();
  }

  Future<void> _build(_) async {
    try {
      await _mutex.protect(() async {
        emit(AsyncValue.data(await load()));
      });
    } on Exception catch (e, st) {
      addError(e, st);
      emit(AsyncValue.error(e, st));
    }
  }

  @protected
  Future<void> setState(T? newState) async {
    await _initWait();
    try {
      emit(AsyncValue.data(await store(newState)));
    } on Exception catch (e, st) {
      addError(e, st);
      emit(AsyncValue.error(e, st));
    }
  }

  final WaitSet<void, void> _initWait = WaitSet();
  final Mutex _mutex = Mutex(debugLockTimeout: kIsDebugMode ? 60 : null);
}
