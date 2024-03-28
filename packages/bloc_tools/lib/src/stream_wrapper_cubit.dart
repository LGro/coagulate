import 'dart:async';

import 'package:async_tools/async_tools.dart';
import 'package:bloc/bloc.dart';

abstract class StreamWrapperCubit<State> extends Cubit<AsyncValue<State>> {
  StreamWrapperCubit(Stream<State> stream, {State? defaultState})
      : super(defaultState != null
            ? AsyncValue.data(defaultState)
            : const AsyncValue.loading()) {
    _subscription = stream.listen((event) => emit(AsyncValue.data(event)),
        // ignore: avoid_types_on_closure_parameters
        onError: (Object error, StackTrace stackTrace) {
      emit(AsyncValue.error(error, stackTrace));
    });
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await super.close();
  }

  late final StreamSubscription<State> _subscription;
}
