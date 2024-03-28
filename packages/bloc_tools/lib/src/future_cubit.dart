import 'dart:async';

import 'package:async_tools/async_tools.dart';
import 'package:bloc/bloc.dart';

abstract class FutureCubit<State> extends Cubit<AsyncValue<State>> {
  FutureCubit(Future<State> fut) : super(const AsyncValue.loading()) {
    unawaited(fut.then((value) {
      emit(AsyncValue.data(value));
      // ignore: avoid_types_on_closure_parameters
    }, onError: (Object e, StackTrace stackTrace) {
      emit(AsyncValue.error(e, stackTrace));
    }));
  }
  FutureCubit.value(State state) : super(AsyncValue.data(state));
}
